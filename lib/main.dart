import 'package:flutter/material.dart';
import 'package:prjectcm/data/sns_repository.dart';
import 'package:prjectcm/main_screen.dart';
import 'package:prjectcm/models/hospital.dart';
import 'package:prjectcm/theme.dart';
import 'package:provider/provider.dart';

import 'http/http_client.dart';


void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider(
          create: (_) => SnsRepository(client: HttpClient()),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainPage(),
      theme: themeLight(),
    );
  }
}