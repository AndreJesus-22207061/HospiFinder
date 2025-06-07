import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:prjectcm/connectivity_module.dart';
import 'package:prjectcm/data/http_sns_datasource.dart';
import 'package:prjectcm/data/sqflite_sns_datasource.dart';
import 'package:prjectcm/location_module.dart';
import 'package:prjectcm/models/hospital.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/sns_repository.dart';
import '../models/evaluation_report.dart'; // para formatar data
//import 'package:prjectcm/theme.dart';

class HospitalDetailPage extends StatefulWidget {
  final int hospitalId;

  const HospitalDetailPage({required this.hospitalId, super.key});

  @override
  State<HospitalDetailPage> createState() => _HospitalDetailPageState();
}

class _HospitalDetailPageState extends State<HospitalDetailPage> {
  late SnsRepository snsRepository;

  @override
  Widget build(BuildContext context) {
    final httpSnsDataSource = context.read<HttpSnsDataSource>();
    final connectivityModule = context.read<ConnectivityModule>();
    final sqfliteSnsDataSource = context.read<SqfliteSnsDataSource>();
    final locationModule = context.read<LocationModule>();
    snsRepository = SnsRepository(sqfliteSnsDataSource, httpSnsDataSource, connectivityModule,locationModule);
    return FutureBuilder<LocationData?>(
        future: snsRepository.obterLocation(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Erro a obter localização');
          } else {
            print(
                '[DEBUG] FutureBuilder (localização): estado = ${snapshot.connectionState}');
            if (snapshot.hasError) {
              print('[DEBUG] Erro ao obter localização: ${snapshot.error}');
            }

            final location = snapshot.data; // Pode ser null
            final double? userLat = location?.latitude;
            final double? userLon = location?.longitude;

            return FutureBuilder<Hospital>(
              future: snsRepository.getHospitalDetailById(widget.hospitalId),
              builder: (context, snapshot) {
                print(
                    '[DEBUG] FutureBuilder hospital: estado=${snapshot.connectionState}');
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  return Scaffold(
                    appBar: AppBar(title: const Text('Erro')),
                    body: Center(child: Text('Erro: ${snapshot.error}')),
                  );
                } else if (!snapshot.hasData) {
                  return Scaffold(
                    appBar: AppBar(title: const Text('Erro')),
                    body: const Center(child: Text('Hospital não encontrado.')),
                  );
                }

                final hospital = snapshot.data!;
                print('[DEBUG] Hospital obtido: ${hospital.name}');

                print('[DEBUG] Avaliações obtidas: ${hospital.reports.length}');
                for (var i = 0; i < hospital.reports.length; i++) {
                  print(
                      '[DEBUG] Avaliação #$i: rating=${hospital.reports[i].rating}, data=${hospital.reports[i].dataHora}, notas=${hospital.reports[i].notas}');
                }

                final estrelas = snsRepository.gerarEstrelasParaHospital(hospital);
                final media = snsRepository.mediaAvaliacoes(hospital).toStringAsFixed(1);
                return Scaffold(
                  appBar: AppBar(title: Text(hospital.name)),
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Caixa de detalhes do hospital
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(2, 2),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.black.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Nome
                                Text(
                                  hospital.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                ),
                                SizedBox(height: 16),

                                // Morada | Distância
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Morada",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            hospital.address,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  fontSize: 13,
                                                  color: Colors.white,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Distância",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                          ),
                                          SizedBox(height: 4),
                                          _hospitalKmText(context, hospital,
                                              userLat, userLon),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),

                                // Email | Telefone
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Email",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            hospital.email,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  fontSize: 15,
                                                  color: Colors.white,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Telefone",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            hospital.phoneNumber.toString(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  fontSize: 15,
                                                  color: Colors.white,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),

                                // Urgência | Média avaliações
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Média de Avaliações",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                          ),
                                          SizedBox(height: 4),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            // o Row fica só do tamanho do conteúdo
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                media,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                              SizedBox(width: 6),
                                              ...estrelas,
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: hospital.hasEmergency
                                                  ? Colors.green.shade100
                                                  : Colors.red.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              hospital.hasEmergency
                                                  ? 'Com Urgência'
                                                  : 'Sem Urgência',
                                              style: TextStyle(
                                                color: hospital.hasEmergency
                                                    ? Colors.green
                                                    : Colors.red,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 16),

                        // Caixa branca para avaliações
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                    child: Text("Avaliações",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black))),
                                SizedBox(height: 10),
                                ...hospital.reports.isNotEmpty
                                    ? hospital.reports
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                        final index = entry.key;
                                        final avaliacao = entry.value;
                                        print(
                                            'Número de avaliações: ${hospital.reports.length}');
                                        print(
                                            'Avaliacao #$index: rating=${avaliacao.rating}, date=${avaliacao.dataHora}, notas=${avaliacao.notas}');
                                        final corDeFundo = index.isEven
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primaryContainer
                                            : Theme.of(context)
                                                .colorScheme
                                                .secondaryContainer;

                                        final estrelas = snsRepository
                                            .gerarEstrelasParaAvaliacao(
                                                avaliacao);

                                        return Container(
                                          width: double.infinity,
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 8),
                                          padding: const EdgeInsets.all(16.0),
                                          decoration: BoxDecoration(
                                            color: corDeFundo,
                                            // ou outra cor personalizada
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 6,
                                                offset: Offset(2, 2),
                                              ),
                                            ],
                                            border: Border.all(
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              width: 1,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    avaliacao.rating
                                                        .toStringAsFixed(1),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge
                                                        ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.black),
                                                  ),
                                                  SizedBox(width: 6),
                                                  ...estrelas,
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                DateFormat('dd/MM/yyyy HH:mm')
                                                    .format(avaliacao.dataHora),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                "${avaliacao.notas}",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color: Colors.black,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList()
                                    : [
                                        Center(
                                            child: Text(
                                                "Ainda não existem avaliações para este hospital.",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black)))
                                      ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          ;
        });
  }
}

Widget _hospitalKmText(
    BuildContext context, Hospital hospital, double? userLat, double? userLon) {
  if (userLat == null || userLon == null) {
    // Pode retornar um texto vazio, ou um placeholder pequeno
    return Text(
      '-', // ou 'Localização indisponível'
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 14,
            color: Colors.white,
          ),
    );
  }
  return Text(
    hospital.distanciaFormatada(userLat, userLon),
    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 14,
          color: Colors.white,
        ),
  );
}
