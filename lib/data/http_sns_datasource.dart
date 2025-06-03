import 'dart:convert';

import 'package:prjectcm/data/sns_datasource.dart';
import 'package:prjectcm/models/evaluation_report.dart';
import 'package:prjectcm/models/hospital.dart';
import 'package:prjectcm/models/waiting_time.dart';
import '../http/http_client.dart';

class HttpSnsDataSource extends SnsDataSource {
  final HttpClient _client;

  HttpSnsDataSource({required HttpClient client}) : _client = client;


  @override
  Future<void> attachEvaluation(int hospitalId, EvaluationReport report) {
    throw Exception('Not available');
  }

  @override
  Future<List<Hospital>> getAllHospitals() async {
    final response = await _client.get(
      url: 'https://servicos.min-saude.pt/pds/api/tems/institution',
    );

    if (response.statusCode == 200){
      final reponseJSON = jsonDecode(response.body);
      List hospitaisJSON = reponseJSON['Result'];
      return hospitaisJSON.map((hospitalJSON) => Hospital.fromJSON(hospitalJSON)).toList();
    }else{
      throw Exception('Erro ao obter hospitais:: ${response.statusCode}');
    }
  }

  @override
  Future<Hospital> getHospitalDetailById(int hospitalId) async {
    final allHospitals = await getAllHospitals();
    final hospital = allHospitals.firstWhere(
          (hospital) => hospital.id == hospitalId,
      orElse: () => throw Exception('Hospital com ID $hospitalId não encontrado.'),
    );

    return hospital;
  }

  @override
  Future<List<WaitingTime>> getHospitalWaitingTimes(int hospitalId) {
    // TODO: implement getHospitalWaitingTimes
    throw UnimplementedError();
  }

  @override
  Future<List<Hospital>> getHospitalsByName(String name) async {
    final allHospitals = await getAllHospitals();
    final queryLower = name.toLowerCase();

    final filtrado = allHospitals.where(
          (hospital) => hospital.name.toLowerCase().contains(queryLower),
    ).toList();

    if (filtrado.isEmpty) {
      throw Exception('Nenhum hospital encontrado com nome contendo "$name".');
    }

    return filtrado;
  }

  @override
  Future<void> insertHospital(Hospital hospital) {
    throw Exception('Not available');
  }


// devem apenas implementar aqui só e apenas os métodos da classe abstrata
}