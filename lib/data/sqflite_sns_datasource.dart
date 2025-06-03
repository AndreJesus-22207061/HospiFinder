import 'package:path/path.dart';
import 'package:prjectcm/data/sns_datasource.dart';
import 'package:prjectcm/models/evaluation_report.dart';
import 'package:prjectcm/models/hospital.dart';
import 'package:prjectcm/models/waiting_time.dart';
import 'package:sqflite/sqflite.dart';


class SqfliteSnsDataSource extends SnsDataSource {

  Database? database;

  Future<void> init() async{
    database = await openDatabase(
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
        print('Tabela hospital criada');

        await db.execute(
            'CREATE TABLE avaliacao('
                'id TEXT PRIMARY KEY,'
                'hospitalId TEXT NOT NULL,'
                'rating INTEGER NOT NULL,'
                'date DATETIME NOT NULL,'
                'notes TEXT,'
                'FOREIGN KEY (hospitalId) REFERENCES hospital(id)'
                ')'
        );
        print('Tabela avaliacao criada');
      },
      version: 1,
    );
  }





  @override
  Future<void> attachEvaluation(int hospitalId, EvaluationReport report) async {
    if (database == null) {
      throw Exception('Forgot to initialize the database?');
    }
    try {
      await database!.insert('avaliacao', report.toDb());
    } catch (e) {
      print('Erro ao inserir avaliação: $e');
      rethrow;
    }
  }

  @override
  Future<List<Hospital>> getAllHospitals() async{
    if(database == null){
      throw Exception('Forgot to initialize the database?');
    }
    List result = await database!.rawQuery("SELECT * FROM hospital");
    return result.map((entry) => Hospital.fromDB(entry)).toList();

    throw UnimplementedError();
  }




  @override
  Future<Hospital> getHospitalDetailById(int hospitalId) async{
    if(database == null){
      throw Exception('Forgot to initialize the database?');
    }
    List result = await database!.rawQuery("SELECT * FROM hospital WHERE id = ?", [hospitalId]);
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

    if(database == null){
      throw Exception('Forgot to initialize the database?');
    }
    final queryLower = name.toLowerCase();

    final result = await database!.rawQuery(
      "SELECT * FROM hospital WHERE LOWER(name) LIKE ?",
      [queryLower],
    );

    if (result.isEmpty) {
      throw Exception('Nenhum hospital encontrado com nome contendo "$name".');
    }

    return result.map((map) => Hospital.fromDB(map)).toList();

  }

  @override
  Future<void> insertHospital(Hospital hospital) async {
    if (database == null) {
      throw Exception('Database not initialized');
    }

    try {
      await database!.insert('hospital', hospital.toDb());
      print('Hospital inserido com sucesso: ${hospital.name} (ID: ${hospital.id})');
    } catch (e) {
      print('Erro ao inserir hospital: ${hospital.name} (ID: ${hospital.id})');
      print('Dados: ${hospital.toDb()}');
      print('Erro: $e');
      rethrow;
    }
  }




// devem apenas implementar aqui só e apenas os métodos da classe abstrata
  Future<void> apagarBaseDeDados() async {
    final caminho = join(await getDatabasesPath(), 'hospitals.db');
    await deleteDatabase(caminho);
    print('Base de dados apagada com sucesso.');
  }

  Future<void> deleteAll() async{
    if(database == null){
      throw Exception('Forgot to initialize the database?');
    }
    await database!.rawDelete('DELETE FROM hospital');

  }

}