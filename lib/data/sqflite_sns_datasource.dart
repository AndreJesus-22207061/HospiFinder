import 'package:path/path.dart';
import 'package:prjectcm/data/sns_datasource.dart';
import 'package:prjectcm/models/evaluation_report.dart';
import 'package:prjectcm/models/hospital.dart';
import 'package:prjectcm/models/waiting_time.dart';
import 'package:sqflite/sqflite.dart';


class SqfliteSnsDataSource extends SnsDataSource {

  Database? _database;

  Future<void> init() async{
    _database = await openDatabase(
      join(await getDatabasesPath(), 'hospitals.db'),
      onCreate: (db, version) async{
        await db.execute(
          'CREATE TABLE hospital('
              'id TEXT PRIMARY KEY, '
              'name TEXT NOT NULL, '
              'latitude REAL NOT NULL, '
              'longitude REAL NOT NULL, '
              'address TEXT NOT NULL, '
              'phoneNumber TEXT, '
              'email TEXT, '
              'district TEXT, '
              'hasEmergency INTEGER '
              ')',
        );

        await db.execute(
            '''
        CREATE TABLE avaliacao (
          id TEXT PRIMARY KEY,
          hospitalId TEXT NOT NULL,
          rating INTEGER NOT NULL,
          date DATETIME NOT NULL,
          notes TEXT
        )
        '''
        );
      },
      version: 1,
    );
  }





  @override
  Future<void> attachEvaluation(int hospitalId, EvaluationReport report) async{
    if(_database == null){
      throw Exception('Forgot to initialize the database?');
    }


  }

  @override
  Future<List<Hospital>> getAllHospitals() async{
    if(_database == null){
      throw Exception('Forgot to initialize the database?');
    }
    List result = await _database!.rawQuery("SELECT * FROM hospital");
    return result.map((entry) => Hospital.fromDB(entry)).toList();

    throw UnimplementedError();
  }

  @override
  Future<Hospital> getHospitalDetailById(int hospitalId) async{
    if(_database == null){
      throw Exception('Forgot to initialize the database?');
    }
    List result = await _database!.rawQuery("SELECT * FROM hospital WHERE id = ?", [hospitalId]);
    if(result.isNotEmpty){
      return Hospital.fromDB(result.first);
    }else{
      throw Exception('Inexistent hospital $hospitalId');
    }
  }

  @override
  Future<List<WaitingTime>> getHospitalWaitingTimes(int hospitalId) {
    // TODO: implement getHospitalWaitingTimes
    throw UnimplementedError();
  }

  @override
  Future<List<Hospital>> getHospitalsByName(String name) async{

    if(_database == null){
      throw Exception('Forgot to initialize the database?');
    }
    final queryLower = name.toLowerCase();

    final result = await _database!.rawQuery(
      "SELECT * FROM hospital WHERE LOWER(name) LIKE ?",
      [queryLower],
    );

    if (result.isEmpty) {
      throw Exception('Nenhum hospital encontrado com nome contendo "$name".');
    }

    return result.map((map) => Hospital.fromDB(map)).toList();

  }

  @override
  Future<void> insertHospital(Hospital hospital) async{

    if(_database == null){
      throw Exception('Forgot to initialize the database?');
    }
    await _database!.insert('hospital' , hospital.toDb());

  }

  Future<void> insertAvaliacao(EvaluationReport avaliacao) async{

    if(_database == null){
      throw Exception('Forgot to initialize the database?');
    }
    await _database!.insert('avaliacao' , avaliacao.toDb());

  }


// devem apenas implementar aqui só e apenas os métodos da classe abstrata
  Future<void> apagarBaseDeDados() async {
    final caminho = join(await getDatabasesPath(), 'hospitals.db');
    await deleteDatabase(caminho);
    print('Base de dados apagada com sucesso.');
  }

  Future<void> deleteAll() async{
    if(_database == null){
      throw Exception('Forgot to initialize the database?');
    }
    await _database!.rawDelete('DELETE FROM hospital');

  }

}