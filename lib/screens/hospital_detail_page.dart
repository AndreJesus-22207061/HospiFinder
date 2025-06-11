import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:prjectcm/connectivity_module.dart';
import 'package:prjectcm/data/http_sns_datasource.dart';
import 'package:prjectcm/data/sqflite_sns_datasource.dart';
import 'package:prjectcm/location_module.dart';
import 'package:prjectcm/models/evaluation_report.dart';
import 'package:prjectcm/models/hospital.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/sns_repository.dart';
import '../models/waiting_time.dart'; // para formatar data
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
    int currentUrgencyIndex = 0;
    PageController pageController = PageController();
    final httpSnsDataSource = context.read<HttpSnsDataSource>();
    final connectivityModule = context.read<ConnectivityModule>();
    final sqfliteSnsDataSource = context.read<SqfliteSnsDataSource>();
    final locationModule = context.read<LocationModule>();
    snsRepository = SnsRepository(sqfliteSnsDataSource, httpSnsDataSource,
        connectivityModule, locationModule);
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

                final estrelas =
                    snsRepository.gerarEstrelasParaHospital(hospital);
                final media =
                    snsRepository.mediaAvaliacoes(hospital).toStringAsFixed(1);

                return FutureBuilder<List<WaitingTime>>(
                    future: snsRepository
                        .getHospitalWaitingTimes(widget.hospitalId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final hasError = snapshot.hasError ||
                          !snapshot.hasData ||
                          snapshot.data!.isEmpty;
                      final waitingTimes = snapshot.data ?? [];

                      return Scaffold(
                        appBar: AppBar(title: Text(hospital.name)),
                        body: SingleChildScrollView(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Caixa de detalhes do hospital
                              buildDetalhesContainer(context, hospital, userLat, userLon, media, estrelas),

                              SizedBox(height: 16),

                              if (hospital.hasEmergency == true) ...[
                                buildTemposContainer(waitingTimes, hasError, currentUrgencyIndex, pageController),
                              ],

                              SizedBox(height: 16),
                              // Container Avaliacoes
                              buildAvaliacoesSection(context, hospital, snsRepository),
                            ],
                          ),
                        ),
                      );
                    });
              },
            );
          }
        });
  }

  Widget buildDetalhesContainer(BuildContext context, Hospital hospital,
      double? userLat, double? userLon, String media, List<Widget> estrelas) {
    return Container(
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nome
            Text(
              hospital.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                buildDetalhesMorada(context, hospital),
                SizedBox(width: 12),
                buildDetalhesDistancia(context, hospital, userLat, userLon),
              ],
            ),
            SizedBox(height: 12),
            // Email | Telefone
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildDetalhesEmail(context, hospital),
                SizedBox(width: 12),
                buildDetalhesTelefone(context, hospital),
              ],
            ),
            SizedBox(height: 12),

            // Urgência | Média avaliações
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildDetalhesMediaA(context, media, estrelas),
                SizedBox(width: 12),
                buildDetalhesUrgencia(hospital),
              ],
            ),
            SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    await snsRepository.toggleFavorite(hospital.id);
                    setState(() {});
                  },
                  icon: Icon(
                    hospital.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: hospital.isFavorite ? Colors.red : Colors.grey,
                  ),
                  label: Text(
                    hospital.isFavorite ? 'Favorito' : 'Adicionar aos favoritos',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    shadowColor: Colors.black26,
                    elevation: 2,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Expanded buildDetalhesUrgencia(Hospital hospital) {
    return Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: hospital.hasEmergency
                            ? Colors.green.shade100
                            : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
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
              );
  }

  Expanded buildDetalhesMediaA(BuildContext context, String media, List<Widget> estrelas) {
    return Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Média de Avaliações",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      // o Row fica só do tamanho do conteúdo
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          media,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        SizedBox(width: 6),
                        ...estrelas,
                      ],
                    ),
                  ],
                ),
              );
  }

  Expanded buildDetalhesTelefone(BuildContext context, Hospital hospital) {
    return Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Telefone",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      hospital.phoneNumber.toString(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                    ),
                  ],
                ),
              );
  }

  Expanded buildDetalhesEmail(BuildContext context, Hospital hospital) {
    return Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Email",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      hospital.email,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                    ),
                  ],
                ),
              );
  }

  Widget buildDetalhesDistancia(BuildContext context, Hospital hospital,
      double? userLat, double? userLon) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Distância",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          ),
          SizedBox(height: 4),
          _hospitalKmText(context, hospital, userLat, userLon),
        ],
      ),
    );
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

  Widget buildDetalhesMorada(BuildContext context, Hospital hospital) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Morada",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          ),
          SizedBox(height: 4),
          Text(
            hospital.address,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                  color: Colors.white,
                ),
          ),
        ],
      ),
    );
  }

  Widget buildTemposContainer(List<WaitingTime> waitingTimes, bool hasError,
      int currentUrgencyIndex, PageController pageController) {
    return Container(
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
        child: waitingTimes.isEmpty || hasError
            ? buildTemposHeader()
            : buildTemposDeEspera(currentUrgencyIndex, pageController, waitingTimes),
      ),
    );
  }

  Widget buildTemposHeader() {
    return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                SizedBox(height: 8),
                Center(
                  child: Text(
                    'Tempos de Espera',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Não foi possível obter os tempos de espera.',
                  style: TextStyle(fontSize: 14, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ],
            );
  }

  Widget buildTemposDeEspera(int currentUrgencyIndex,
      PageController pageController, List<WaitingTime> waitingTimes) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          children: [
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Tempos de Espera',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Urgência com setas
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Botao Anterior
                IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: currentUrgencyIndex > 0
                      ? () {
                          setState(() {
                            currentUrgencyIndex--;
                            pageController.animateToPage(
                              currentUrgencyIndex,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.ease,
                            );
                          });
                        }
                      : null,
                ),
                // Tipo de urgencia
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    waitingTimes[currentUrgencyIndex].emergency,
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                // Botao Seguinte
                IconButton(
                  icon: Icon(Icons.arrow_forward_ios),
                  onPressed: currentUrgencyIndex < waitingTimes.length - 1
                      ? () {
                          setState(() {
                            currentUrgencyIndex++;
                            pageController.animateToPage(
                              currentUrgencyIndex,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.ease,
                            );
                          });
                        }
                      : null,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Conteúdo da urgência atual
            buildTemposPage(
                pageController, setState, currentUrgencyIndex, waitingTimes),
          ],
        );
      },
    );
  }

  Widget buildTemposPage(PageController pageController, StateSetter setState,
      int currentUrgencyIndex, List<WaitingTime> waitingTimes) {
    return SizedBox(
      height: 380,
      child: PageView.builder(
        controller: pageController,
        onPageChanged: (index) {
          setState(() {
            currentUrgencyIndex = index;
          });
        },
        itemCount: waitingTimes.length,
        itemBuilder: (context, pageIndex) {
          final wt = waitingTimes[pageIndex];
          final colors = ['Red', 'Orange', 'Yellow', 'Green', 'Blue', 'Grey'];
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: colors.length,
                  itemBuilder: (context, index) {
                    final color = colors[index];
                    final tempo = wt.waitTimes[color] ?? 0;
                    final fila = wt.queueLengths[color] ?? 0;

                    final Map<String, String> prioridadesNome = {
                      'Red': 'Emergente',
                      'Orange': 'Muito Urgente',
                      'Yellow': 'Urgente',
                      'Green': 'Pouco Urgente',
                      'Blue': 'Não Urgente',
                      'Grey': 'Não Atribuído',
                    };

                    final Map<String, Color> prioridadesCores = {
                      'Red': Colors.red,
                      'Orange': Colors.orange,
                      'Yellow': Colors.yellow[700]!,
                      'Green': Colors.green,
                      'Blue': Colors.blue,
                      'Grey': Colors.grey,
                    };

                    final prioridadeTexto =
                        prioridadesNome[color] ?? 'Desconhecida';
                    final prioridadeCor =
                        prioridadesCores[color] ?? Colors.black;

                    return buildTempoCard(
                        prioridadeTexto, prioridadeCor, wt, tempo, fila);
                  },
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: Text(
                  'Última atualização: ${wt.getlastUpdatedFormatado()}',
                  style: TextStyle(fontSize: 13, color: Colors.black),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildTempoCard(String prioridadeTexto, Color prioridadeCor,
      WaitingTime wt, int tempo, int fila) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Card(
        color: Colors.grey[100],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                prioridadeTexto,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: prioridadeCor,
                ),
              ),
              Row(
                children: [
                  Text(
                    '⏱ ${wt.formatarTempo(tempo)}',
                    style: TextStyle(color: Colors.black),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '👥 $fila pessoas',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


Widget buildAvaliacoesSection(
    BuildContext context, Hospital hospital, SnsRepository snsRepository) {
  return Container(
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
            child: Text(
              "Avaliações",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

          ),
          Center(
            child: Text(
              "Numero de Avaliações: ${hospital.reports.length}",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

          ),
          const SizedBox(height: 10),
          if (hospital.reports.isNotEmpty)
            ...hospital.reports
                .asMap()
                .entries
                .map((entry) => buildAvaliacaoWidget(
                    context, entry.key, entry.value, snsRepository))
                .toList()
          else
            Center(
              child: Text(
                "Ainda não existem avaliações para este hospital.",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
            )
        ],
      ),
    ),
  );
}

Widget buildAvaliacaoWidget(BuildContext context, int index,
    EvaluationReport avaliacao, SnsRepository snsRepository) {
  final corDeFundo = index.isEven
      ? Theme.of(context).colorScheme.primaryContainer
      : Theme.of(context).colorScheme.secondaryContainer;

  final estrelas = snsRepository.gerarEstrelasParaAvaliacao(avaliacao);

  return Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(vertical: 8),
    padding: const EdgeInsets.all(16.0),
    decoration: BoxDecoration(
      color: corDeFundo,
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
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
            ),
            const SizedBox(width: 6),
            ...estrelas,
          ],
        ),
        const SizedBox(height: 6),
        Text(
          DateFormat('dd/MM/yyyy HH:mm').format(avaliacao.dataHora),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
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
}
