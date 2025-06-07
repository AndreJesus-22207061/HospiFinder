import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:prjectcm/connectivity_module.dart';
import 'package:prjectcm/data/sns_datasource.dart';
import 'package:prjectcm/data/sqflite_sns_datasource.dart';
import 'package:prjectcm/location_module.dart';
import 'package:prjectcm/models/evaluation_report.dart';
import 'package:prjectcm/models/hospital.dart';
import 'package:prjectcm/models/waiting_time.dart';
import 'http_sns_datasource.dart';


class SnsRepository extends SnsDataSource {

  final SqfliteSnsDataSource local;
  final HttpSnsDataSource remote;
  final ConnectivityModule connectivityModule;
  final LocationModule locationModule;

  SnsRepository(this.local, this.remote, this.connectivityModule, this.locationModule);

  List<int> ultimosAcedidosIds = [];


  @override
  Future<void> attachEvaluation(int hospitalId, EvaluationReport report) async {
    print('[DEBUG REPO] Chamada attachEvaluation no repositório');
    await local.attachEvaluation(hospitalId, report);
  }

  @override
  Future<List<Hospital>> getAllHospitals() async {
    print('[DEBUG] Verificando conectividade...');
    bool online = await connectivityModule.checkConnectivity();
    print('[DEBUG] Está online? $online');

    if (online) {
      print('[DEBUG] Obtendo hospitais do remoto...');
      var hospitais = await remote.getAllHospitals();
      print('[DEBUG] Hospitais recebidos do remoto: ${hospitais.length}');

      for (var hospital in hospitais) {
        await local.insertHospital(hospital);
      }
      return hospitais;
    } else {
      print('[DEBUG] Offline, obtendo hospitais do local...');
      var hospitaisLocais = await local.getAllHospitals();
      print('[DEBUG] Hospitais recebidos do local: ${hospitaisLocais.length}');
      return hospitaisLocais;
    }
  }

  @override
  Future<Hospital> getHospitalDetailById(int hospitalId) async {
    Hospital hospital;

    if (await connectivityModule.checkConnectivity()) {
      hospital = await remote.getHospitalDetailById(hospitalId);
    } else {
      hospital = await local.getHospitalDetailById(hospitalId);
    }

    final avaliacoes = await getEvaluationsByHospitalId(hospital);
    hospital.reports = avaliacoes;

    return hospital;
  }

  @override
  Future<List<WaitingTime>> getHospitalWaitingTimes(int hospitalId) {
    // TODO: implement getHospitalWaitingTimes
    throw UnimplementedError();
  }

  @override
  Future<void> insertWaitingTime(int hospitalId, waitingTime) {
    // TODO: implement insertWaitingTime
    throw UnimplementedError();
  }

  @override
  Future<List<Hospital>> getHospitalsByName(String name) async {
    if(await connectivityModule.checkConnectivity()){
      return await remote.getHospitalsByName(name);
    }else{
      return await local.getHospitalsByName(name);
    }
  }


  @override
  Future<void> insertHospital(Hospital hospital) {
    throw Exception('Not available');
  }

  @override
  Future<List<EvaluationReport>> getEvaluationsByHospitalId(Hospital hospital) async {
    if(local.database == null){
      return hospital.reports;
    }
      return local.getEvaluationsByHospitalId(hospital);
  }

  Future<LocationData?> obterLocation() async {
    try {
      print('[DEBUG] A obter localização...');

      final stream = locationModule.onLocationChanged().timeout(Duration(seconds: 3));

      // Usar await for para tentar pegar o primeiro valor se existir
      await for (final location in stream) {
        if (location.latitude != null && location.longitude != null) {
          print('[DEBUG] Localização recebida: ${location.latitude}, ${location.longitude}');
          return location;
        } else {
          print('[DEBUG] Localização inválida (lat/lon nulos)');
          return null;
        }
      }

      // Se sair do for sem emitir valores (stream vazia)
      print('[DEBUG] Stream de localização vazia');
      return null;
    } catch (e) {
      print('[DEBUG] Erro ao obter localização: $e');
      return null;
    }
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
        .map((h) => MapEntry(h, h.distanciaKm(minhaLat, minhaLon)))
        .toList();

    copia.sort((a, b) => a.value.compareTo(b.value));

    return copia.map((e) => e.key).toList();
  }




  double mediaAvaliacoes(Hospital hospital){
    double soma =0.0;
    double media = 0.0;
    int cont = 0;
    if(hospital.reports.isNotEmpty){
      for(var h in hospital.reports){
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
