import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:prjectcm/data/sns_datasource.dart';
import 'package:prjectcm/models/evaluation_report.dart';
import 'package:prjectcm/models/hospital.dart';
import 'package:flutter/material.dart';
import 'package:prjectcm/models/waiting_time.dart';

import '../http/http_client.dart';


class SnsRepository extends SnsDataSource {

  final HttpClient _client;

  SnsRepository({required HttpClient client}) : _client = client;

  List<Hospital> hospitalList = [];
  double _latitude = 0.0;
  double _longitude = 0.0;
  List<int> ultimosAcedidosIds = [];

  double get latitude => _latitude;
  double get longitude => _longitude;

  @override
  Future<void> attachEvaluation(int hospitalId, EvaluationReport report) {
    // TODO: implement attachEvaluation
    throw UnimplementedError();
  }

  @override
  Future<List<Hospital>> getAllHospitals() async {
    final response = await _client.get(
      url: 'https://servicos.min-saude.pt/pds/api/tems/institution',
    );

    if (response.statusCode == 200){
      final reposndeJSON = jsonDecode(response.body);
      List hospitaisJSON = reposndeJSON['Result'];

      List<Hospital> hospitais = hospitaisJSON.map((hospitalJSON) => Hospital.fromMap(hospitalJSON)).toList();

      return hospitais;
    }else{
      throw Exception('status code: ${response.statusCode}');
    }
  }

  @override
  Future<Hospital> getHospitalDetailById(int hospitalId) async {
    final response = await _client.get(
      url: 'https://servicos.min-saude.pt/pds/api/tems/institution/',
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List hospitaisJSON = data['Result'];

      final hospitalMap = hospitaisJSON.firstWhere(
            (element) => element['Id'] == hospitalId,
        orElse: () => null,
      );

      if (hospitalMap == null) {
        throw Exception('Hospital com ID $hospitalId não encontrado.');
      }

      return Hospital.fromMap(hospitalMap);
    } else {
      throw Exception('Erro ao obter hospital: ${response.statusCode}');
    }
  }

  @override
  Future<List<WaitingTime>> getHospitalWaitingTimes(int hospitalId) {
    // TODO: implement getHospitalWaitingTimes
    throw UnimplementedError();
  }

  @override
  Future<List<Hospital>> getHospitalsByName(String name) async {
    final response = await _client.get(
      url: 'https://servicos.min-saude.pt/pds/api/tems/institution/',
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List hospitaisJSON = data['Result'];

      final hospitaisFiltrados = hospitaisJSON.where((element) {
        final nomeHospital = (element['Name'] as String).toLowerCase();
        return nomeHospital.contains(name.toLowerCase());
      }).toList();

      if (hospitaisFiltrados.isEmpty) {
        throw Exception('Nenhum hospital encontrado com nome contendo "$name".');
      }

      // Converter para List<Hospital>
      return hospitaisFiltrados.map<Hospital>((e) => Hospital.fromMap(e)).toList();
    } else {
      throw Exception('Erro ao obter hospitais: ${response.statusCode}');
    }
  }

  @override
  Future<void> insertHospital(Hospital hospital) {
    // TODO: implement insertHospital
    throw UnimplementedError();
  }



  void atualizarLocalizacao(double novaLat, double novaLon) {
    _latitude = novaLat;
    _longitude = novaLon;
  }

  void adicionarUltimoAcedido(int hospitalId) {
    if (!ultimosAcedidosIds.contains(hospitalId)) {
      if (ultimosAcedidosIds.length == 2) {
        ultimosAcedidosIds.removeLast(); // Remove o mais antigo
      }
      ultimosAcedidosIds.insert(0, hospitalId); // Adiciona no início
    }
  }

  Future<List<Hospital>> listarUltimosAcedidos() async {
    List<Hospital> hospitais = [];

    for (var id in ultimosAcedidosIds) {
      try {
        Hospital hospital = await getHospitalDetailById(id);
        hospitais.add(hospital);
      } catch (e) {
        print('Erro ao buscar hospital com ID $id: $e');
      }
    }

    return hospitais;
  }


  List<Hospital> filtrarHospitaisComUrgencia(List<Hospital> lista) {
    return lista.where((hospital) => hospital.hasEmergency).toList();
  }

  List<Hospital> ordenarListaPorDistancia(List<Hospital> lista, double minhaLat, double minhaLon) {
    final copia = lista
        .map((h) => MapEntry(h, h.distanciaDe(minhaLat, minhaLon)))
        .toList();

    copia.sort((a, b) => a.value.compareTo(b.value));

    return copia.map((e) => e.key).toList();
  }

  List<Hospital> pesquisarHospitais(List<Hospital> lista, String query) {
    final lowerQuery = query.toLowerCase();
    return lista.where((hospital) => hospital.name.toLowerCase().contains(lowerQuery)).toList();
  }

  List<Hospital> listarHospitais(){
    return hospitalList;
  }

  void addAvaliacao(EvaluationReport avaliacao, Hospital hospital1){
    hospital1.avaliacoes.add(avaliacao);
  }


  double mediaAvaliacoes(Hospital hospital){
    double soma =0.0;
    double media = 0.0;
    int cont = 0;
    if(hospital.avaliacoes.isNotEmpty){
      for(var h in hospital.avaliacoes){
        soma += h.rating;
        cont  ++;
      }
      if(cont > 0){
        media = soma / cont;
      }
    }
    return media;
  }

  List<Hospital> ordenarListaPorAvaliacao(List<Hospital> lista) {
    final copia = [...lista];
    copia.sort((a, b) => mediaAvaliacoes(b).compareTo(mediaAvaliacoes(a)));
    return copia;
  }

  List<Widget> gerarEstrelasParaHospital(Hospital hospital, {double size = 20}) {
    double media = mediaAvaliacoes(hospital);
    final List<Widget> stars = [];
    final rounded = (media * 2).round() / 2;
    final fullStars = rounded.floor();
    final hasHalfStar = (rounded - fullStars) == 0.5;


    for (int i = 0; i < 5; i++) {
      if (i < fullStars) {
        stars.add(Icon(Icons.star, color: Colors.white, size: size));
      } else if (i == fullStars && hasHalfStar) {
        stars.add(Icon(Icons.star_half, color: Colors.white, size: size));
      } else {
        stars.add(Icon(Icons.star_border, color: Colors.white, size: size));
      }
    }

    return stars;
  }

  List<Widget> gerarEstrelasParaAvaliacao(EvaluationReport avaliacao, {double size = 20}) {
    final List<Widget> stars = [];
    final rounded = (avaliacao.rating * 2).round() / 2;
    final fullStars = rounded.floor();
    final hasHalfStar = (rounded - fullStars) == 0.5;


    for (int i = 0; i < 5; i++) {
      if (i < fullStars) {
        stars.add(Icon(Icons.star, color: Colors.white, size: size));
      } else if (i == fullStars && hasHalfStar) {
        stars.add(Icon(Icons.star_half, color: Colors.white, size: size));
      } else {
        stars.add(Icon(Icons.star_border, color: Colors.white, size: size));
      }
    }

    return stars;
  }



}
