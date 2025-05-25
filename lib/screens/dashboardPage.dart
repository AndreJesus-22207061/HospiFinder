import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/sns_repository.dart';
import '../models/hospital.dart';
import 'package:prjectcm/widgets/hospitalBox.dart';

import 'hospital_detail_page.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late List<Hospital> hospitais;
  late List<Hospital> _hospitaisFiltrados;
  String _searchQuery = '';
  late TextEditingController _searchController;
  late FocusNode _focusNode;
  late List<Hospital> ultimosAcedidos;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _focusNode = FocusNode();
    final snsRepository = Provider.of<SnsRepository>(context, listen: false);
    hospitais = snsRepository.listarHospitais();
    _hospitaisFiltrados = hospitais; // inicialmente mostra todos
    ultimosAcedidos = snsRepository.listarUltimosAcedidos();
  }

  @override
  void dispose() {
    _searchController.dispose(); // Limpar o controlador quando o widget for destruído
    _focusNode.dispose();
    super.dispose();
  }

  void atualizarUltimosAcedidos() {
    final snsRepository = Provider.of<SnsRepository>(context, listen: false);
    setState(() {
      ultimosAcedidos = snsRepository.listarUltimosAcedidos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final snsRepository = Provider.of<SnsRepository>(context);
    final userLat = snsRepository.latitude;
    final userLon = snsRepository.longitude;
    final List<Hospital> hospitais = snsRepository.listarHospitais();
    final List<Hospital> hospitaisMaisProximos = snsRepository.ordenarPorDistancia(userLat, userLon).take(3).toList();
    final List<Hospital> ultimosAcedidos = snsRepository.listarUltimosAcedidos();

    return GestureDetector(
      onTap: () {
        // Quando o usuário clica fora da barra de pesquisa, remove o foco e fecha a caixa de sugestões
        if (!_focusNode.hasFocus) {
          setState(() {
            _searchQuery = ''; // Limpa a pesquisa
            _hospitaisFiltrados = hospitais; // Restaura todos os hospitais
          });
        }
        _focusNode.unfocus(); // Remove o foco da barra de pesquisa
      },
      child: Scaffold(
        body: Stack(
          children: [
            ListView(
              padding: EdgeInsets.zero,
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 22.0, right: 24.0, top: 32.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bem vindo ao HospiFinder',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
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
                      Image.asset(
                        'assets/images/HospifinderSemFundo.png',
                        width: 70,
                        height: 70,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15, top: 10.0 , bottom: 10),
                  child: TextField(
                    key: Key('search-hospital-field'),
                    controller: _searchController,
                    focusNode: _focusNode,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Procure Pelo Hospital',
                      labelStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      suffixIcon: Icon(Icons.search),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    ),
                    onChanged: pesquisarHospitais,
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15, top: 0 , bottom: 10),
                    child: Container(
                      key: Key('search-results-container'),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _hospitaisFiltrados.length,
                        itemBuilder: (context, index) {
                          final hospital = _hospitaisFiltrados[index];
                          final distancia = hospital.distanciaDe(userLat, userLon);

                          return GestureDetector(
                            onTap: () {
                              final snsRepository = Provider.of<SnsRepository>(context, listen: false);
                              snsRepository.adicionarUltimoAcedido(hospital);

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => HospitalDetailPage(hospital: hospital),
                                ),
                              ).then((_) {
                                // Reseta a pesquisa ao voltar
                                setState(() {
                                  _searchQuery = '';
                                  _searchController.clear();
                                  _hospitaisFiltrados = hospitais;
                                });
                                _focusNode.unfocus();
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.grey.shade300, width: 1),
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
                  ),
                // Últimos acedidos
                Padding(
                  padding: const EdgeInsets.only(left: 18.0, right: 20.0, top: 4.0 , bottom: 2.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (ultimosAcedidos.isNotEmpty)
                        Text('Últimos Acedidos', style: Theme.of(context).textTheme.titleMedium),
                      tuturialButton(
                        context: context,
                        onPressed: () {
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
                if (ultimosAcedidos.isNotEmpty)
                  ListView.builder(
                    key: Key("last-visited-key"),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 0.0),
                    itemCount: ultimosAcedidos.length,
                    itemBuilder: (context, index) {
                      final hospital = ultimosAcedidos[index];
                      final Color boxColor = index.isEven
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.secondaryContainer;

                      final estrelas = snsRepository.gerarEstrelasParaHospital(hospital);
                      final media = snsRepository.mediaAvaliacoes(hospital).toStringAsFixed(1);

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
                        child: HospitalBox(
                          hospital: hospital,
                          userLat: userLat,
                          userLon: userLon,
                          boxColor: boxColor,
                          estrelas: estrelas,
                          media: media,
                          onTap: () {
                            final snsRepository = Provider.of<SnsRepository>(context, listen: false);
                            snsRepository.adicionarUltimoAcedido(hospital);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => HospitalDetailPage(hospital: hospital),
                              ),
                            ).then((_) {
                              atualizarUltimosAcedidos();
                            });
                          },
                        ),
                      );
                    },
                  ),

                Padding(
                  padding: const EdgeInsets.only(left: 18.0, right: 12.0, top: 2.0 , bottom: 1.0),
                  child: Text('Mais Próximos', style: Theme.of(context).textTheme.titleMedium),
                ),
                hospitaisMaisProximos.isEmpty
                    ? Center(child: Text('Nenhum hospital registado.'))
                    : ListView.builder(
                  key: Key("Nearest-hospítal-key"),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  itemCount: hospitaisMaisProximos.length,
                  itemBuilder: (context, index) {
                    final hospital = hospitaisMaisProximos[index];
                    final Color boxColor = index.isEven
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.secondaryContainer;

                    final estrelas = snsRepository.gerarEstrelasParaHospital(hospital);
                    final media = snsRepository.mediaAvaliacoes(hospital).toStringAsFixed(1);

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
                      child: HospitalBox(
                        hospital: hospital,
                        userLat: userLat,
                        userLon: userLon,
                        boxColor: boxColor,
                        estrelas: estrelas,
                        media: media,
                        onTap: () {
                          final snsRepository = Provider.of<SnsRepository>(context, listen: false);
                          snsRepository.adicionarUltimoAcedido(hospital);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HospitalDetailPage(hospital: hospital),
                            ),
                          ).then((_) {
                            atualizarUltimosAcedidos();
                          });
                        },
                      ),
                    );
                  },
                ),
              ],
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
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 1), // Ajuste o padding aqui
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


  void pesquisarHospitais(String query) {
    final sugestoes = hospitais.where((hospital) {
      final nomeHospital = hospital.name.toLowerCase();
      final input = query.toLowerCase();
      return nomeHospital.contains(input);
    }).toList();

    setState(() {
      _searchQuery = query;
      _hospitaisFiltrados = query.isEmpty ? hospitais : sugestoes;
    });
  }
}




