import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:prjectcm/data/sns_datasource.dart';
import 'package:prjectcm/data/sqflite_sns_datasource.dart';
import 'package:prjectcm/location_module.dart';
import 'package:prjectcm/models/evaluation_report.dart';
import 'package:prjectcm/models/hospital.dart';
import 'package:flutter/material.dart';
import 'package:prjectcm/models/waiting_time.dart';
import 'package:prjectcm/service/connectivity_service.dart';
import 'http_sns_datasource.dart';


class SnsRepository extends SnsDataSource {

  final SqfliteSnsDataSource local;
  final HttpSnsDataSource remote;
  final ConnectivityService connectivityService;
  final LocationModule locationModule;

  SnsRepository(this.local, this.remote, this.connectivityService, this.locationModule);

  List<int> ultimosAcedidosIds = [];


  @override
  Future<void> attachEvaluation(int hospitalId, EvaluationReport report) async {
    await local.attachEvaluation(hospitalId, report);
  }

  @override
  Future<List<Hospital>> getAllHospitals() async {
    if (await connectivityService.checkConnectivity()) {
      var hospitais = await remote.getAllHospitals();

      for (var hospital in hospitais) {
        local.insertHospital(hospital);
      }
      return hospitais;
    } else {
      return await local.getAllHospitals();
    }
  }

  @override
  Future<Hospital> getHospitalDetailById(int hospitalId) async {
    if(await connectivityService.checkConnectivity()){
      return await remote.getHospitalDetailById(hospitalId);
    }else{
      return await local.getHospitalDetailById(hospitalId);
    }
  }

  @override
  Future<List<WaitingTime>> getHospitalWaitingTimes(int hospitalId) {
    // TODO: implement getHospitalWaitingTimes
    throw UnimplementedError();
  }

  @override
  Future<List<Hospital>> getHospitalsByName(String name) async {
    if(await connectivityService.checkConnectivity()){
      return await remote.getHospitalsByName(name);
    }else{
      return await local.getHospitalsByName(name);
    }
  }


  @override
  Future<void> insertHospital(Hospital hospital) {
    throw Exception('Not available');
  }

  Future<List<EvaluationReport>> getEvaluationsByHospitalId(int hospitalId) async {
    final db = local.database;

    if (db == null) {
      throw Exception('Forgot to initialize the database?');
    }

    final result = await db.rawQuery(
      'SELECT * FROM avaliacao WHERE hospitalId = ?',
      [hospitalId.toString()],
    );

    return result.map((map) => EvaluationReport.fromDb(map)).toList();
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



  List<Widget> _gerarEstrelas(double rating, {double size = 20}) {
    final List<Widget> stars = [];
    final rounded = (rating * 2).round() / 2;
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


  List<Widget> gerarEstrelasParaHospital(Hospital hospital, {double size = 20}) {
    double media = mediaAvaliacoes(hospital);
    return _gerarEstrelas(media, size: size);
  }

  List<Widget> gerarEstrelasParaAvaliacao(EvaluationReport avaliacao, {double size = 20}) {
    return _gerarEstrelas(avaliacao.rating.toDouble(), size: size);
  }



}
