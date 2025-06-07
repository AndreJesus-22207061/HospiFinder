import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:prjectcm/connectivity_module.dart';
import 'package:prjectcm/data/http_sns_datasource.dart';
import 'package:prjectcm/data/sns_repository.dart';
import 'package:prjectcm/data/sqflite_sns_datasource.dart';
import 'package:prjectcm/location_module.dart';
import 'package:prjectcm/models/hospital.dart';
import 'package:provider/provider.dart';
import 'package:prjectcm/widgets/hospitalBox.dart';

import 'hospital_detail_page.dart';

class ListaPage extends StatefulWidget {
  @override
  _ListaPageState createState() => _ListaPageState();
}

class _ListaPageState extends State<ListaPage> {
  late TextEditingController _searchController;
  late FocusNode _focusNode;
  String _searchQuery = '';
  bool filtrarurgenciaAtiva = false;
  String? _ordenarPorSelecionado;
  final List<String> _opcoesOrdenacao = ['Distância', 'Avaliação'];
  late SnsRepository snsRepository;



  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _searchController = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }


  Future<List<Hospital>> _carregarHospitaisComFiltros(
      double? userLat, double? userLon) async {

    List<Hospital> hospitais = await snsRepository.getAllHospitals();

    /*
    for (var hospital in hospitais) {
      hospital.reports = await snsRepository.getEvaluationsByHospitalId(hospital);
    }
    */

    if (filtrarurgenciaAtiva) {
      hospitais = snsRepository.filtrarHospitaisComUrgencia(hospitais);
    }

    if (_ordenarPorSelecionado == 'Distância') {
      // Só ordena se userLat e userLon NÃO forem nulos
      if (userLat != null && userLon != null) {
        hospitais = snsRepository.ordenarListaPorDistancia(hospitais, userLat, userLon);
      }
    } else if (_ordenarPorSelecionado == 'Avaliação') {
      hospitais = snsRepository.ordenarListaPorAvaliacao(hospitais);
    }

    if (_searchQuery.isNotEmpty) {
      final normalizedQuery = removeDiacritics(_searchQuery.toLowerCase());
      hospitais = hospitais.where((hospital) {
        final normalizedName = removeDiacritics(hospital.name.toLowerCase());
        return normalizedName.contains(normalizedQuery);
      }).toList();
    }

    return hospitais;
  }


  void _atualizarLista() {
    setState(() {});
  }

  void _aoMudarPesquisa(String query) {
    _searchQuery = query;
    _atualizarLista();
  }

  void _filtrarUrgencia() {
    filtrarurgenciaAtiva = !filtrarurgenciaAtiva;
    _atualizarLista();
  }

  void _mostrarDropdownMenu(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final theme = Theme.of(context);
    //final screenWidth = MediaQuery.of(context).size.width;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        26,
        offset.dy + 122,
        26,
        offset.dy,
      ),
      color: theme.colorScheme.onSecondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.secondary,
          width: 2,
        ),
      ),
      items: _opcoesOrdenacao.map((String value) {
        final bool selecionado = _ordenarPorSelecionado == value;
        return PopupMenuItem<String>(
          value: value,
          onTap: () {
            setState(() {
              if (_ordenarPorSelecionado == value) {
                _ordenarPorSelecionado = null;
              } else {
                _ordenarPorSelecionado = value;
              }
            });
            Future.delayed(Duration(milliseconds: 150), _atualizarLista);
          },
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: selecionado
                        ? theme.colorScheme.secondary
                        : theme.colorScheme.onSecondary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.secondary,
                      width: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final httpSnsDataSource = context.read<HttpSnsDataSource>();
    final connectivityModule = context.read<ConnectivityModule>();
    final sqfliteSnsDataSource = context.read<SqfliteSnsDataSource>();
    final locationModule = context.read<LocationModule>();
    snsRepository = SnsRepository(sqfliteSnsDataSource, httpSnsDataSource, connectivityModule,locationModule);
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 15,
              right: 15,
              top: 35.0,
              bottom: 5,
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              style: TextStyle(fontSize: 15, color: Colors.black),
              decoration: InputDecoration(
                labelText: 'Procure Pelo Hospital',
                labelStyle: TextStyle(fontSize: 14, color: Colors.black),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                suffixIcon: Icon(Icons.search),
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              ),
              onChanged: _aoMudarPesquisa,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () => _mostrarDropdownMenu(context),
                  child: Container(
                    height: 31,
                    padding: EdgeInsets.symmetric(horizontal: 35),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSecondary,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.secondary,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          _ordenarPorSelecionado ?? 'Ordenar por',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                _urgenciaFilterButton(),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<LocationData?>(
              future: snsRepository.obterLocation(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Erro a obter localização');
                } else {
                  print('[DEBUG] FutureBuilder (localização): estado = ${snapshot.connectionState}');
                  if (snapshot.hasError) {
                    print('[DEBUG] Erro ao obter localização: ${snapshot.error}');
                  }

                  final location = snapshot.data; // Pode ser null
                  final double? userLat = location?.latitude;
                  final double? userLon = location?.longitude;

                  return FutureBuilder<List<Hospital>>(
                    future: _carregarHospitaisComFiltros(userLat, userLon),
                    builder: (_, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        print(snapshot.error);
                        return Center(
                          child: Text('Erro ao carregar hospitais: ${snapshot.error}'),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('Não foi possível obter os hospitais. Verifique a conectividade e volte a tentar'));
                      }

                      print('[DEBUG] FutureBuilder (hospitais): estado = ${snapshot.connectionState}');
                      if (snapshot.hasError) {
                        print('[DEBUG] Erro ao carregar hospitais: ${snapshot.error}');
                      }

                      final hospitais = snapshot.data!;

                      return buildList(
                        hospitais: hospitais,
                        snsRepository: snsRepository,
                        userLat: userLat,
                        userLon: userLon,
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _urgenciaFilterButton() {
    return GestureDetector(
      onTap: _filtrarUrgencia,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 43, vertical: 3),
        decoration: BoxDecoration(
          color: filtrarurgenciaAtiva
              ? Theme.of(context).colorScheme.secondaryContainer
              : Theme.of(context).colorScheme.onSecondary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.secondary,
            width: 2,
          ),
        ),
        child: Text(
          "Urgência Ativa",
          style: TextStyle(
            color: filtrarurgenciaAtiva
                ? Theme.of(context).colorScheme.onSecondary
                : Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class buildList extends StatelessWidget {
  const buildList({
    super.key,
    required this.hospitais,
    required this.snsRepository,
    required this.userLat,
    required this.userLon,
  });

  final List<Hospital> hospitais;
  final SnsRepository snsRepository;
  final double? userLat;
  final double? userLon;

  @override
  Widget build(BuildContext context) {
    print('[DEBUG] Desenhei lista de hospitais com ${hospitais.length} itens');
    return ListView.builder(
      key: Key("list-view"),
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: hospitais.length,
      itemBuilder: (context, index) {
        final hospital = hospitais[index];
        final Color boxColor = index.isEven
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.secondaryContainer;


       // final estrelas = snsRepository.gerarEstrelasParaHospital(hospital);
       // final media = snsRepository.mediaAvaliacoes(hospital).toStringAsFixed(1);
        print('[DEBUG LISTAPAGE] A desenhar HospitalBox para: ${hospital.name}');
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
          child: HospitalBox(
            hospital: hospital,
            userLat: userLat,
            userLon: userLon,
            boxColor: boxColor,
            //estrelas: estrelas,
            //media: media,
            onTap: () {
              snsRepository.adicionarUltimoAcedido(hospital.id);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HospitalDetailPage(hospitalId: hospital.id),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
