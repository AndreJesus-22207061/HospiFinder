import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/sns_repository.dart';
import '../models/evaluation_report.dart';
import '../models/hospital.dart';
import 'package:prjectcm/widgets/hospitalBox.dart';

import 'hospital_detail_page.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _searchQuery = '';
  late TextEditingController _searchController;
  late FocusNode _focusNode;
  late Future<Map<String, dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _focusNode = FocusNode();
    _dataFuture = _loadAllData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _loadAllData() async {
    final snsRepository = Provider.of<SnsRepository>(context, listen: false);

    // Obter localização (aguarda o primeiro valor do stream)
    final locationData =
        await snsRepository.locationModule.onLocationChanged().first;
    final userLat = locationData.latitude;
    final userLon = locationData.longitude;

    if (userLat == null || userLon == null) {
      throw Exception('Localização inválida');
    }

    // Obter hospitais
    final hospitais = await snsRepository.getAllHospitals();

    // Obter últimos acedidos
    final ultimosAcedidos = await snsRepository.listarUltimosAcedidos();

    return {
      'userLat': userLat,
      'userLon': userLon,
      'hospitais': hospitais,
      'ultimosAcedidos': ultimosAcedidos,
    };
  }

  @override
  Widget build(BuildContext context) {
    final snsRepository = Provider.of<SnsRepository>(context, listen: false);

    return GestureDetector(
      onTap: () {
        _focusNode.unfocus();
        setState(() {
          _searchQuery = '';
          _searchController.clear();
        });
      },
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            buildCabecalho(context),
            buildSearchBar(context),
            FutureBuilder<Map<String, dynamic>>(
              future: _dataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                        child:
                            Text('Erro ao carregar dados: ${snapshot.error}')),
                  );
                } else if (!snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(child: Text('Dados indisponíveis')),
                  );
                }

                final userLat = snapshot.data!['userLat'] as double;
                final userLon = snapshot.data!['userLon'] as double;
                final todosHospitais =
                    snapshot.data!['hospitais'] as List<Hospital>;
                final ultimosAcedidos =
                    snapshot.data!['ultimosAcedidos'] as List<Hospital>;

                final hospitaisFiltrados = _searchQuery.isEmpty
                    ? todosHospitais
                    : todosHospitais
                        .where((hospital) => hospital.name
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()))
                        .toList();

                final hospitaisMaisProximos = snsRepository
                    .ordenarListaPorDistancia(todosHospitais, userLat, userLon);
                final hospitaisMaisProximosTop3 =
                    hospitaisMaisProximos.take(3).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_searchQuery.isNotEmpty)
                      buildSearchResults(
                          context, hospitaisFiltrados, userLat, userLon),
                    if (_searchQuery.isEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Últimos Acedidos',
                                style: Theme.of(context).textTheme.titleMedium),
                            tuturialButton(
                              context: context,
                              onPressed: () => setState(() {}),
                            ),
                          ],
                        ),
                      ),
                      buildHospitalList(
                        context: context,
                        hospitais: ultimosAcedidos,
                        userLat: userLat,
                        userLon: userLon,
                        snsRepository: snsRepository,
                        key: Key("last-visited-key"),
                      ),
                    ],
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 1),
                      child: Text('Mais Próximos',
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    buildHospitalList(
                      context: context,
                      hospitais: hospitaisMaisProximosTop3,
                      userLat: userLat,
                      userLon: userLon,
                      snsRepository: snsRepository,
                      key: Key("Nearest-hospital-key"),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget tuturialButton({
    required BuildContext context,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 1),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSecondary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.secondary,
            width: 2,
          ),
        ),
        child: Text(
          'Tutorial',
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget buildCabecalho(BuildContext context) {
    print('[DEBUG] Desenhei o cabeçalho');
    return Padding(
      padding: const EdgeInsets.only(left: 22.0, right: 24.0, top: 32.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bem vindo ao HospiFinder',
                    style: Theme.of(context).textTheme.titleLarge),
                SizedBox(height: 2),
                Container(
                  padding: EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Aqui pode obter informações sobre os hospitais mais próximos de si',
                    style: Theme.of(context).textTheme.titleSmall,
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 2),
          Image.asset('assets/images/HospifinderSemFundo.png',
              width: 70, height: 70),
        ],
      ),
    );
  }

  Widget buildSearchBar(BuildContext context) {
    print('[DEBUG] Desenhei a barra de pesquisa');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: TextField(
        key: Key('search-hospital-field'),
        controller: _searchController,
        focusNode: _focusNode,
        style: TextStyle(fontSize: 15, color: Colors.black),
        decoration: InputDecoration(
          labelText: 'Procure Pelo Hospital',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
          suffixIcon: Icon(Icons.search),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget buildSearchResults(BuildContext context,
      List<Hospital> hospitaisFiltrados, double userLat, double userLon) {
    print('[DEBUG] Desenhei os resultados da pesquisa');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        key: Key('search-results-container'),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: hospitaisFiltrados.length,
          itemBuilder: (context, index) {
            final hospital = hospitaisFiltrados[index];
            final distancia = hospital.distanciaDe(userLat, userLon);
            return GestureDetector(
              onTap: () {
                final snsRepository =
                    Provider.of<SnsRepository>(context, listen: false);
                snsRepository.adicionarUltimoAcedido(hospital.id);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HospitalDetailPage(hospitalId: hospital.id),
                  ),
                ).then((_) {
                  setState(() {});
                  _focusNode.unfocus();
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        hospital.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          overflow: TextOverflow.ellipsis,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      '${distancia.toStringAsFixed(1)} km',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildHospitalList({
    required BuildContext context,
    required List<Hospital> hospitais,
    required double userLat,
    required double userLon,
    required SnsRepository snsRepository,
    Key? key,
  }) {
    print('[DEBUG] Desenhei lista de hospitais com ${hospitais.length} itens');
    return ListView.builder(
        key: key,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 0, right: 0, top: 2.0),
        itemCount: hospitais.length,
        itemBuilder: (context, index) {
          final hospital = hospitais[index];
          final Color boxColor = index.isEven
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.secondaryContainer;
          final estrelas = snsRepository.gerarEstrelasParaHospital(hospital);
          final media =
              snsRepository.mediaAvaliacoes(hospital).toStringAsFixed(1);

          return FutureBuilder<List<EvaluationReport>>(
            future: snsRepository.getEvaluationsByHospitalId(hospital.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              } else if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Text('Erro ao carregar avaliações'),
                );
              }

              // Attach avaliações dinamicamente
              hospital.avaliacoes = snapshot.data ?? [];

              final estrelas =
                  snsRepository.gerarEstrelasParaHospital(hospital);
              final media =
                  snsRepository.mediaAvaliacoes(hospital).toStringAsFixed(1);

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
                child: HospitalBox(
                  hospital: hospital,
                  userLat: userLat,
                  userLon: userLon,
                  boxColor: boxColor,
                  estrelas: estrelas,
                  media: media,
                  onTap: () {
                    snsRepository.adicionarUltimoAcedido(hospital.id);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            HospitalDetailPage(hospitalId: hospital.id),
                      ),
                    ).then((_) => setState(() {}));
                  },
                ),
              );
            },
          );
        });
  }
}
