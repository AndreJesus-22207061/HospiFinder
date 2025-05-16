import 'package:flutter/material.dart';
import 'package:prjectcm/data/sns_repository.dart';
import 'package:prjectcm/main_screen.dart';
import 'package:prjectcm/models/hospital.dart';
import 'package:prjectcm/theme.dart';
import 'package:provider/provider.dart';


void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider(
          create: (context) {
            final repo = SnsRepository();
            // Inicializa a localização (ex: Sintra)
            repo.atualizarLocalizacao(38.762007, -9.261847);

            // Inserção de hospitais
            repo.insertHospital(
              Hospital(
                id: 1,
                name: 'Hospital Santa Cruz',
                latitude: 38.72703797110443,
                longitude: -9.233886985245663,
                address: 'Av. Professor Reinaldo dos Santos',
                phoneNumber: 214431000,
                email: 'gabcidadao@ulslo.min-saude.pt',
                district: 'Carnaxide',
                hasEmergency: true,
              ),
            );

            repo.insertHospital(
              Hospital(
                id: 2,
                name: 'Hospital Fernando Fonseca',
                latitude: 38.74461928643091,
                longitude: -9.245638490086609,
                address: 'Hospital Prof. Doutor Fernando Fonseca E.P.E . IC 19',
                phoneNumber: 214348200,
                email: 'sec.geral@hff.min-saude.pt',
                district: 'Amadora',
                hasEmergency: true,
              ),
            );

            repo.insertHospital(
              Hospital(
                id: 3,
                name: 'Hospital Lusiadas Lisboa',
                latitude: 38.74949611422005,
                longitude: -9.179496003027165,
                address: 'Rua Abílio Mendes',
                phoneNumber: 217704040,
                email: 'geral@lusiadas.pt',
                district: 'Lisboa',
                hasEmergency: false,
              ),
            );

            repo.insertHospital(
              Hospital(
                id: 4,
                name: 'Hospital São Francisco Xavier',
                latitude: 38.70720965586393,
                longitude: -9.21831641837078,
                address: 'Estrada do Forte do Alto do Duque ',
                phoneNumber: 210431000,
                email: 'hsfxavier@chlo.min-saude.pt',
                district: 'Lisboa',
                hasEmergency: true,
              ),
            );

            repo.insertHospital(
              Hospital(
                id: 5,
                name: 'Hospital Santa Maria',
                latitude: 38.74856538318247,
                longitude: -9.160678247204888,
                address: 'Av. Professor Egas Moniz',
                phoneNumber: 217805000,
                email: 'administracao@chln.min-saude.pt',
                district: 'Lisboa',
                hasEmergency: true,
              ),
            );

            repo.insertHospital(
              Hospital(
                id: 6,
                name: 'Hospital Egas Moniz',
                latitude: 38.69993069260152,
                longitude: -9.188368689535462,
                address: 'Rua da Junqueira',
                phoneNumber: 210431000,
                email: 'hem@chlo.min-saude.pt',
                district: 'Lisboa',
                hasEmergency: false,
              ),
            );

            return repo;
          },
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