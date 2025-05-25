import 'package:prjectcm/data/sns_datasource.dart';
import 'package:prjectcm/models/evaluation_report.dart';
import 'package:prjectcm/models/hospital.dart';
import 'package:prjectcm/models/waiting_time.dart';

class HttpSnsDataSource extends SnsDataSource {
  @override
  Future<void> attachEvaluation(int hospitalId, EvaluationReport report) {
    // TODO: implement attachEvaluation
    throw UnimplementedError();
  }

  @override
  Future<List<Hospital>> getAllHospitals() {
    // TODO: implement getAllHospitals
    throw UnimplementedError();
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
// devem apenas implementar aqui só e apenas os métodos da classe abstrata
}