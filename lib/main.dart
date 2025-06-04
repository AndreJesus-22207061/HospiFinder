import 'package:flutter/material.dart';
import 'package:prjectcm/connectivity_module.dart';
import 'package:prjectcm/data/http_sns_datasource.dart';
import 'package:prjectcm/data/sns_repository.dart';
import 'package:prjectcm/main_screen.dart';
import 'package:prjectcm/service/connectivity_service.dart';
import 'package:prjectcm/theme.dart';
import 'package:provider/provider.dart';

import 'data/sqflite_sns_datasource.dart';
import 'service/gps_location_service.dart';
import 'http/http_client.dart';
import 'location_module.dart';


void main() async{

  WidgetsFlutterBinding.ensureInitialized();



  runApp(
    MultiProvider(
      providers: [
        Provider<HttpSnsDataSource>.value(value: HttpSnsDataSource()),
        Provider<ConnectivityModule>.value(value: ConnectivityService()),
        Provider<SqfliteSnsDataSource>.value(value: SqfliteSnsDataSource()),
        Provider<LocationModule>.value(value: GPSLocationService())
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
  late Future<void> _initialization;

  @override
  void initState() {
    super.initState();
    final db = context.read<SqfliteSnsDataSource>();
    _initialization = db.apagarBaseDeDados().then((_) => db.init());
  }
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