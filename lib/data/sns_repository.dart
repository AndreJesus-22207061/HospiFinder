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
  List<Hospital> ultimosAcedidos = [];

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
      url: 'https://api-qa.pds.min-saude.pt/api/tems/institution',
      headers: {
        'Authorization': 'Bearer VUhlT2tISVdGNmdiNEgwa3I4ZXZGZWloWHNQUXo4SktHYmVRYVR6OHpocz0=',
      },
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
  Future<Hospital> getHospitalDetailById(int hospitalId) {
    // TODO: implement getHospitalDetailById
    throw UnimplementedError();
  }

  @override
  Future<List<WaitingTime>> getHospitalWaitingTimes(int hospitalId) {
    // TODO: implement getHospitalWaitingTimes
    throw UnimplementedError();
  }

  @override
  Future<List<Hospital>> getHospitalsByName(String name) {
    // TODO: implement getHospitalsByName
    throw UnimplementedError();
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

  void adicionarUltimoAcedido(Hospital hospital) {
    if (!ultimosAcedidos.contains(hospital)) {
      if (ultimosAcedidos.length == 2) {
        ultimosAcedidos.removeLast(); // Remove o hospital mais antigo (FIFO)
      }
      ultimosAcedidos.insert(0, hospital); // Adiciona o hospital atual
    }
  }

  List<Hospital> listarUltimosAcedidos(){
    return ultimosAcedidos;
  }


  List<Hospital> ordenarPorDistancia(double minhaLat, double minhaLon) {
    final copia = hospitalList
        .map((h) => MapEntry(h, h.distanciaDe(minhaLat, minhaLon)))
        .toList();

    copia.sort((a, b) => a.value.compareTo(b.value));

    return copia.map((e) => e.key).toList();
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
    final copia = [...lista]; // Cria uma cópia para não modificar a lista original
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
