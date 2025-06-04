import 'package:flutter/material.dart';
import 'package:prjectcm/connectivity_module.dart';
import 'package:prjectcm/data/http_sns_datasource.dart';
import 'package:prjectcm/data/sqflite_sns_datasource.dart';
import 'package:prjectcm/location_module.dart';
import 'package:prjectcm/models/hospital.dart';
import 'package:prjectcm/screens/hospital_detail_page.dart';
import 'package:provider/provider.dart';

import '../data/sns_repository.dart';


class HospitalBox extends StatefulWidget {
  final Hospital hospital;
  final double userLat;
  final double userLon;
  final Color boxColor;
  final List<Widget> estrelas;
  final String media;
  final VoidCallback onTap;

  const HospitalBox({
    super.key,
    required this.hospital,
    required this.userLat,
    required this.userLon,
    required this.boxColor,
    required this.estrelas,
    required this.media,
    required this.onTap,
  });

  @override
  State<HospitalBox> createState() => _HospitalBoxState();
}


class _HospitalBoxState extends State<HospitalBox> {
  late SnsRepository snsRepository;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final httpSnsDataSource = Provider.of<HttpSnsDataSource>(context);
    final connectivityModule = Provider.of<ConnectivityModule>(context);
    final sqfliteSnsDataSource = Provider.of<SqfliteSnsDataSource>(context);
    final locationModule = Provider.of<LocationModule>(context);
    snsRepository = SnsRepository(sqfliteSnsDataSource, httpSnsDataSource, connectivityModule,locationModule);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.boxColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
        border: Border.all(
          color: Colors.black.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
            left: 8.0, right: 0.0, top: 6.0, bottom: 6.0),
        child: _hospitalListTile(context, widget.hospital, widget.userLat, widget.userLon , widget.estrelas , widget.media , snsRepository),
      ),
    );
  }
}

Widget _hospitalListTile(
    BuildContext context,
    Hospital hospital,
    double userLat,
    double userLon,
    List<Widget> estrelas,
    String media,
    SnsRepository snsRepository, // NOVO parâmetro
    ) {
  return ListTile(
    title: Text(
      hospital.name,
      style: Theme.of(context).textTheme.bodyLarge,
    ),
    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 4),
        Row(
          children: [
            Text(
              media,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 6),
            ...estrelas,
          ],
        ),
        SizedBox(height: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 2), // Espaço reduzido
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _hospitalKmText(context, hospital, userLat, userLon),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: hospital.hasEmergency ? Colors.green.shade100 : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    hospital.hasEmergency ? 'Com Urgência' : 'Sem Urgência',
                    style: TextStyle(
                      color: hospital.hasEmergency ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        )
      ],
    ),
    trailing: Icon(
      Icons.arrow_forward_ios_rounded,
      color: Colors.white,
      size: 34,
    ),
    onTap: () {
      snsRepository.adicionarUltimoAcedido(hospital.id); // Atualiza os últimos acessados

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HospitalDetailPage(hospitalId: hospital.id),
        ),
      );
    },
  );
}

Widget _hospitalAddressText(BuildContext context, String district, String address) {
  return Text(
    "$district - $address",
    style: Theme.of(context).textTheme.bodyMedium,
  );
}

Widget _hospitalKmText(BuildContext context, Hospital hospital, double userLat, double userLon) {
  return Text(
    hospital.distanciaFormatada(userLat, userLon),
    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
  );
}

Widget _hospitalUrgencyWidget(BuildContext context, bool hasEmergency) {
  return Text(
    hasEmergency ? "Com Urgência" : "Sem Urgência",
    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
  );
}