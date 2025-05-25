import 'package:flutter/material.dart';
import 'package:prjectcm/models/hospital.dart';
import 'package:prjectcm/screens/hospital_detail_page.dart';
import 'package:provider/provider.dart';

import '../data/sns_repository.dart';


class HospitalBox extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: boxColor,
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
        child: _hospitalListTile(context, hospital, userLat, userLon , estrelas , media),
      ),
    );
  }
}

Widget _hospitalListTile(BuildContext context, Hospital hospital, double userLat, double userLon , List<Widget> estrelas , String media ) {
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
        SizedBox(height: 4),
        _hospitalAddressText(context, hospital.district, hospital.address),
        SizedBox(height: 4),
        _hospitalKmText(context, hospital, userLat, userLon),
        SizedBox(height: 4),
        _hospitalUrgencyText(context, hospital.hasEmergency),
      ],
    ),
    trailing: Icon(
      Icons.arrow_forward_ios_rounded,
      color: Colors.white,
      size: 34,
    ),
    onTap: () {
      final snsRepository = Provider.of<SnsRepository>(context, listen: false);
      snsRepository.adicionarUltimoAcedido(hospital); // Atualiza os últimos acessados

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
    "${hospital.distanciaDe(userLat, userLon).toStringAsFixed(1)} km",
    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
  );
}

Widget _hospitalUrgencyText(BuildContext context, bool hasEmergency) {
  return Text(
    hasEmergency ? "Com Urgência" : "Sem Urgência",
    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
  );
}