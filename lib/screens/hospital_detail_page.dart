import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:prjectcm/models/hospital.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/sns_repository.dart';
import '../models/evaluation_report.dart'; // para formatar data
//import 'package:prjectcm/theme.dart';

class HospitalDetailPage extends StatelessWidget {
  final int hospitalId;

  const HospitalDetailPage({required this.hospitalId, super.key});

  @override
  Widget build(BuildContext context) {
    //  final theme = Theme.of(context);
    final snsRepository = context.read<SnsRepository>();

    return FutureBuilder<LocationData>(
      future: snsRepository.locationModule.onLocationChanged().first,
      builder: (context, locationSnapshot) {
        if (locationSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (locationSnapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Erro')),
            body: Center(
                child: Text(
                    'Erro ao obter localização: ${locationSnapshot.error}')),
          );
        } else if (!locationSnapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Erro')),
            body: const Center(child: Text('Localização não disponível')),
          );
        }

        final location = locationSnapshot.data!;
        final userLat = location.latitude ?? 0;
        final userLon = location.longitude ?? 0;

        return FutureBuilder<Hospital>(
          future: snsRepository.getHospitalDetailById(hospitalId),
          builder: (context, snapshot) {
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
                                          Text(
                                            "${hospital.distanciaDe(userLat, userLon).toStringAsFixed(1)} km",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  fontSize: 14,
                                                  color: Colors.white,
                                                ),
                                          ),
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
                                ...hospital.avaliacoes.isNotEmpty
                                    ? hospital.avaliacoes
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                        final index = entry.key;
                                        final avaliacao = entry.value;
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
          },
        );
      },
    );
  }
}
