import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:prjectcm/connectivity_module.dart';
import 'package:prjectcm/data/http_sns_datasource.dart';
import 'package:prjectcm/data/sqflite_sns_datasource.dart';
import 'package:prjectcm/location_module.dart';
import 'package:provider/provider.dart';

import '../data/sns_repository.dart';
import '../models/evaluation_report.dart';
import '../models/hospital.dart';
import 'package:prjectcm/widgets/hospitalBox.dart';

import 'hospital_detail_page.dart';

class Nortesulpage extends StatefulWidget {
  @override
  _NortesulpageState createState() => _NortesulpageState();
}

class _NortesulpageState extends State<Nortesulpage> {
  late TextEditingController _searchController;
  late FocusNode _focusNode;
  late Future<Map<String, dynamic>> _dataFuture;
  late SnsRepository snsRepository;


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final httpSnsDataSource = context.read<HttpSnsDataSource>();
    final connectivityModule = context.read<ConnectivityModule>();
    final sqfliteSnsDataSource = context.read<SqfliteSnsDataSource>();
    final locationModule = context.read<LocationModule>();
    snsRepository = SnsRepository(
        sqfliteSnsDataSource, httpSnsDataSource, connectivityModule,
        locationModule);
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
    // Obter localização (aguarda o primeiro valor do stream)
    final locationData =
    await snsRepository.locationModule
        .onLocationChanged()
        .first;
    final userLat = locationData.latitude;
    final userLon = locationData.longitude;

    if (userLat == null || userLon == null) {
      throw Exception('Localização inválida');
    }

    // Obter hospitais
    final hospitais = await snsRepository.getAllHospitals();


    return {
      'userLat': userLat,
      'userLon': userLon,
      'hospitais': hospitais,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          buildCabecalho(context),
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
              final todosHospitais = snapshot.data!['hospitais'] as List<
                  Hospital>;

              final hospitaisNorte = todosHospitais.where((hospital) =>
                  hospital.isNorth()).toList();
              final hospitaisSul = todosHospitais.where((hospital) =>
              !hospital.isNorth()).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Norte',
                            style: Theme
                                .of(context)
                                .textTheme
                                .titleMedium),
                      ],
                    ),
                  ),
                  buildHospitalList(
                    context: context,
                    hospitais: hospitaisNorte,
                    userLat: userLat,
                    userLon: userLon,
                    snsRepository: snsRepository,
                    key: Key("last-visited-key"),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 1),
                    child: Text('Sul',
                        style: Theme
                            .of(context)
                            .textTheme
                            .titleMedium),
                  ),
                  buildHospitalList(
                    context: context,
                    hospitais: hospitaisSul,
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Norte/Sul',
                    style: Theme
                        .of(context)
                        .textTheme
                        .titleLarge),
                SizedBox(height: 2),
              ],
            ),
          ),
        ],
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
    double? height, // <-- nova opção
  }) {
    return SizedBox(
      height: height ?? 300, // altura padrão
      child: ListView.builder(
        key: key,
        shrinkWrap: true,
        physics: AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 0, right: 0, top: 2.0),
        itemCount: hospitais.length,
        itemBuilder: (context, index) {
          final hospital = hospitais[index];
          final Color boxColor = index.isEven
              ? Theme
              .of(context)
              .colorScheme
              .primaryContainer
              : Theme
              .of(context)
              .colorScheme
              .secondaryContainer;

          return FutureBuilder<List<EvaluationReport>>(
            future: snsRepository.getEvaluationsByHospitalId(hospital),
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

              hospital.reports = snapshot.data ?? [];

              final estrelas =
              snsRepository.gerarEstrelasParaHospital(hospital);
              final media = snsRepository
                  .mediaAvaliacoes(hospital)
                  .toStringAsFixed(1);

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
        },
      ),
    );
  }
}
