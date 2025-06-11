import 'package:path/path.dart';
import 'package:prjectcm/data/sns_datasource.dart';
import 'package:prjectcm/models/evaluation_report.dart';
import 'package:prjectcm/models/hospital.dart';
import 'package:prjectcm/models/locationIPMA.dart';
import 'package:prjectcm/models/waiting_time.dart';
import 'package:sqflite/sqflite.dart';

class SqfliteSnsDataSource extends SnsDataSource {
  Database? database;

  Future<void> init() async {
    database = await openDatabase(
      join(await getDatabasesPath(), 'hospitals.db'),
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE hospital('
          'id INTEGER PRIMARY KEY, '
          'name TEXT NOT NULL, '
          'latitude REAL NOT NULL, '
          'longitude REAL NOT NULL, '
          'address TEXT NOT NULL, '
          'phoneNumber INTEGER, '
          'email TEXT, '
          'district TEXT, '
          'hasEmergency INTEGER, '
              'isFavorite INTEGER '
          ')',
        );
        print('Tabela hospital criada');

        await db.execute('CREATE TABLE avaliacao('
            'id TEXT PRIMARY KEY,'
            'hospitalId TEXT NOT NULL,'
            'rating INTEGER NOT NULL,'
            'date DATETIME NOT NULL,'
            'notes TEXT,'
            'FOREIGN KEY (hospitalId) REFERENCES hospital(id)'
            ')');
        print('Tabela avaliacao criada');
        await db.execute('''
            CREATE TABLE waitingTime (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              hospitalId INTEGER,
              lastUpdate TEXT NOT NULL,
              emergencyType TEXT NOT NULL,
              emergencyDescription TEXT NOT NULL,
              redTime INTEGER NOT NULL,
              redLength INTEGER NOT NULL,
              orangeTime INTEGER NOT NULL,
              orangeLength INTEGER NOT NULL,
              yellowTime INTEGER NOT NULL,
              yellowLength INTEGER NOT NULL,
              greenTime INTEGER NOT NULL,
              greenLength INTEGER NOT NULL,
              blueTime INTEGER NOT NULL,
              blueLength INTEGER NOT NULL,
              greyTime INTEGER NOT NULL,
              greyLength INTEGER NOT NULL,
              UNIQUE(hospitalId, emergencyType)
            )
            ''');
        print('Tabela Tempos de espera criada');
        await db.execute('''
              CREATE TABLE ultimos_acedidos (
              id INTEGER PRIMARY KEY,
              timestamp INTEGER
            )
            ''');
        await db.execute(
          'CREATE TABLE localidade('
              'local TEXT PRIMARY KEY, '
              'idAreaAviso TEXT NOT NULL, '
              'latitude REAL NOT NULL, '
              'longitude REAL NOT NULL, '
              'idRegiao INTEGER, '
              'idConcelho INTEGER, '
              'globalIdLocal INTEGER, '
              'idDistrito INTEGER, '
              ')',
        );
        print('Tabela Localizações criada');
      },
      version: 1,
    );
  }


  @override
  Future<void> adicionarUltimoAcedido(int hospitalId) async {
    final db = await database;

    if (db == null) {

      return;
    }

    // Apaga o registo se já existir (para o mover para o topo)
    await db.delete(
      'ultimos_acedidos',
      where: 'id = ?',
      whereArgs: [hospitalId],
    );

    // Adiciona novamente com timestamp atual
    await db.insert(
      'ultimos_acedidos',
      {
        'id': hospitalId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );

    // Garante no máximo 2
    await db.rawDelete('''
    DELETE FROM ultimos_acedidos WHERE id NOT IN (
      SELECT id FROM ultimos_acedidos ORDER BY timestamp DESC LIMIT 2
    )
  ''');
  }


  @override
  Future<void> attachEvaluation(int hospitalId, EvaluationReport report) async {
    try {
      print('[DEBUG DB] Inserir avaliação na tabela "avaliacao":');
      print(report.toDb()); // Mostra o mapa a ser inserido na DB

      await database!.insert('avaliacao', report.toDb());
      print('[DEBUG DB] Inserção concluída com sucesso.');
    } catch (e) {
      print('Erro ao inserir avaliação: $e');
      rethrow;
    }
  }


  Future<List<int>> listarUltimosAcedidosIds() async {
    final db = await database!;
    if (database == null) return [];

    final results = await db.query(
      'ultimos_acedidos',
      orderBy: 'timestamp DESC',
    );

    return results.map((e) => e['id'] as int).toList();
  }


  @override
  Future<List<Hospital>> getAllHospitals() async {
    List result = await database!.rawQuery("SELECT * FROM hospital");
    return result.map((entry) => Hospital.fromDB(entry)).toList();
  }

  @override
  Future<Hospital> getHospitalDetailById(int hospitalId) async {
    List result = await database!
        .rawQuery("SELECT * FROM hospital WHERE id = ?", [hospitalId]);
    if (result.isNotEmpty) {
      return Hospital.fromDB(result.first);
    } else {
      throw Exception('Inexistent hospital $hospitalId');
    }
  }

  @override
  Future<List<WaitingTime>> getHospitalWaitingTimes(int hospitalId) async {
    if (database == null) return [];

    final maps = await database!.query(
      'waitingTime',
      where: 'hospitalId = ?',
      whereArgs: [hospitalId],
    );

    return maps.map((map) => WaitingTime.fromDB(map)).toList();
  }

  @override
  Future<void> insertWaitingTime(int hospitalId, waitingTime) async {
    try {
      await database!.insert(
        'waitingTime',
        waitingTime.toDB(hospitalId),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print(
          'Tempo de espera inserido com sucesso para hospital ID: $hospitalId');
    } catch (e) {
      print('Erro ao inserir tempo de espera para hospital ID: $hospitalId');
      print('Dados: ${waitingTime.toDB(hospitalId)}');
      print('Erro: $e');
      rethrow;
    }
  }

  @override
  Future<List<Hospital>> getHospitalsByName(String name) async {
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
    try {
      await database!.insert(
        'hospital',
        hospital.toDb(),
        conflictAlgorithm: ConflictAlgorithm.replace, // Isto garante o replace
      );
      print(
          'Hospital inserido com sucesso (ou substituído): ${hospital.name} (ID: ${hospital.id})');
    } catch (e) {
      print('Erro ao inserir hospital: ${hospital.name} (ID: ${hospital.id})');
      print('Dados: ${hospital.toDb()}');
      print('Erro: $e');
      rethrow;
    }
  }

  @override
  Future<List<EvaluationReport>> getEvaluationsByHospitalId(
      Hospital hospital) async {
    if (database == null) {
      return [];
    }

    final result = await database!.rawQuery(
      'SELECT * FROM avaliacao WHERE hospitalId = ?',
      [hospital.id.toString()],
    );

    return result.map((map) => EvaluationReport.fromDb(map)).toList();
  }

//devem apenas implementar aqui só e apenas os métodos da classe abstrata
  Future<void> apagarBaseDeDados() async {
    final caminho = join(await getDatabasesPath(), 'hospitals.db');
    await deleteDatabase(caminho);
    print('Base de dados apagada com sucesso.');
  }

  @override
  Future<void> toggleFavorite(int hospitalId) async{
    final db = await database!;
    final result = await db.query(
      'hospital',
      columns: ['isFavorite'],
      where: 'id = ?',
      whereArgs: [hospitalId],
    );
    if (result.isNotEmpty) {
      final current = result.first['isFavorite'] == 1;
      final novoValor = current ? 0 : 1;

      await db.update(
        'hospital',
        {'isFavorite': novoValor},
        where: 'id = ?',
        whereArgs: [hospitalId],
      );
    }

  }

  @override
  Future<Set<int>> getHospitalFavouritesIds() async {
    final db = await database!;
    final results = await db.query(
      'hospital',
      columns: ['id'],
      where: 'isFavorite = ?',
      whereArgs: [1],
    );
    return results.map((e) => e['id'] as int).toSet();
  }

  @override
  Future<List<LocalidadeIPMA>> getLocations() {
    // TODO: implement getLocations
    throw UnimplementedError();
  }
}
