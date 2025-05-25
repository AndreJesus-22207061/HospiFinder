import 'package:flutter/material.dart';
import 'package:prjectcm/models/hospital.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/sns_repository.dart'; // para formatar data
//import 'package:prjectcm/theme.dart';

class HospitalDetailPage extends StatelessWidget {
  final Hospital hospital;

  const HospitalDetailPage({required this.hospital, super.key});

  @override
  Widget build(BuildContext context) {
  //  final theme = Theme.of(context);
    final snsRepository = Provider.of<SnsRepository>(context, listen: false);
    final userLat = snsRepository.latitude;
    final userLon = snsRepository.longitude;
    final estrelas =
    snsRepository.gerarEstrelasParaHospital(hospital);
    final media =
    snsRepository.mediaAvaliacoes(hospital).toStringAsFixed(1);

    return Scaffold(
      appBar: AppBar(title: Text(hospital.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Caixa de detalhes do hospital
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
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
                padding: const EdgeInsets.only(
                    left: 20.0, right: 45.0, top: 16.0, bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8),
                    Text("ID: ${hospital.id}"),
                    SizedBox(height: 8),
                    Text(hospital.name , style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 19 )),
                    SizedBox(height: 8),
                    Text("Localização:" ,  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 15 , fontWeight: FontWeight.bold ,color: Colors.black)),
                    SizedBox(height: 8),
                    Text(hospital.address, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13, fontWeight: FontWeight.normal)),
                    SizedBox(height: 8),
                    Text(hospital.district , style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13 , fontWeight: FontWeight.normal) ),
                    SizedBox(height: 8),
                    Text("Contactos:" ,  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 15 , fontWeight: FontWeight.bold ,color: Colors.black)),
                    SizedBox(height: 8),
                    Text("${hospital.phoneNumber}" ,  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13, fontWeight: FontWeight.normal)),
                    SizedBox(height: 8),
                    Text(hospital.email,  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13, fontWeight: FontWeight.normal)),
                    SizedBox(height: 8),
                    Text(hospital.hasEmergency ? "Com Urgência" : "Sem Urgência" , style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 17, fontWeight: FontWeight.bold , color: Colors.black)),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Text("Distancia:" ,  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 15 , fontWeight: FontWeight.bold ,color: Colors.black)),
                        SizedBox(width: 5),
                        Text(
                          " ${hospital.distanciaDe(userLat, userLon).toStringAsFixed(1)} km",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Text("Media Avaliações:" ,  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 15 , fontWeight: FontWeight.bold ,color: Colors.black)),
                        SizedBox(width: 6),
                        Text(
                          media,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 6),
                        ...estrelas,
                      ],
                    ),
                    SizedBox(height: 8),
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
                    Center(child: Text("Avaliações", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold , color: Colors.black))),
                    SizedBox(height: 10),
                    ...hospital.avaliacoes.isNotEmpty
                        ? hospital.avaliacoes.asMap().entries.map((entry) {
                          final index = entry.key;
                          final avaliacao = entry.value;
                          final corDeFundo = index.isEven
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(context).colorScheme.secondaryContainer;

                          final estrelas = snsRepository.gerarEstrelasParaAvaliacao(avaliacao);

              return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: corDeFundo, // ou outra cor personalizada
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(2, 2),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.black.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  avaliacao.rating.toStringAsFixed(1),
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight:  FontWeight.bold, color: Colors.black
                                  ),
                                ),
                                SizedBox(width: 6),
                                ...estrelas,
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              DateFormat('dd/MM/yyyy HH:mm').format(avaliacao.dataHora),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white, fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "${avaliacao.notas}",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList()
                        : [
                          Center(child: Text("Ainda não existem avaliações para este hospital.", style: TextStyle(fontSize: 15 , color: Colors.black)))
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

