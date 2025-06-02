import 'package:flutter/material.dart';
import 'package:prjectcm/data/http_sns_datasource.dart';
import 'package:prjectcm/data/sns_repository.dart';
import 'package:prjectcm/main_screen.dart';
import 'package:prjectcm/models/hospital.dart';
import 'package:prjectcm/service/connectivity_service.dart';
import 'package:prjectcm/theme.dart';
import 'package:provider/provider.dart';

import 'data/sqflite_sns_datasource.dart';
import 'gps_location_module.dart';
import 'http/http_client.dart';
import 'location_module.dart';


void main() async{
//  WidgetsFlutterBinding.ensureInitialized();
  //final db = SqfliteSnsDataSource();
  //await db.apagarBaseDeDados();

  final snsService = HttpSnsDataSource(client: HttpClient());
  final snsDataBase = SqfliteSnsDataSource();
  final locationModule = GPSLocationModule();

  runApp(
    MultiProvider(
      providers: [
        Provider<HttpSnsDataSource>(create: (_) => snsService),
        Provider<SqfliteSnsDataSource>(create: (_) => snsDataBase),
        Provider<LocationModule>(create: (_) => locationModule),
        Provider<SnsRepository>(
            create: (_) => SnsRepository(
                snsDataBase,
                snsService,
                ConnectivityService(),
                locationModule,
            ),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {

  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final hospitalDatabase = context.read<SqfliteSnsDataSource>();

    return FutureBuilder(
        future: hospitalDatabase.init(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.done){
            return MaterialApp(
              home: MainPage(),
              theme: themeLight(),
            );
          }
          else{
            return MaterialApp(
              home: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
    );
  }
}