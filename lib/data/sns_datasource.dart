import 'package:prjectcm/models/evaluation_report.dart';

import '../models/hospital.dart';
import '../models/locationIPMA.dart';
import '../models/waiting_time.dart';

abstract class SnsDataSource {

  Future<void> insertHospital(Hospital hospital);

  Future<List<Hospital>> getAllHospitals();

  Future<List<Hospital>> getHospitalsByName(String name);

  Future<Hospital> getHospitalDetailById(int hospitalId);

  Future<void> attachEvaluation(int hospitalId, EvaluationReport report);

  Future<List<WaitingTime>> getHospitalWaitingTimes(int hospitalId);

  Future<void> insertWaitingTime(int hospitalId, dynamic waitingTime);

  Future<List<EvaluationReport>> getEvaluationsByHospitalId(Hospital hospital);

  Future<void> adicionarUltimoAcedido(int hospitalId);

  Future<Set<int>> getHospitalFavouritesIds();

  Future<void> toggleFavorite(int hospitalId);

  Future<List<LocalidadeIPMA>> getLocations();


}
