import 'package:prjectcm/models/evaluation_report.dart';
import 'dart:math';

class Hospital {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String address;
  final int phoneNumber;
  final String email;
  final String district;
  final bool hasEmergency;
  List<EvaluationReport> avaliacoes;

  Hospital(
      {required this.id,
        required this.name,
        required this.latitude,
        required this.longitude,
        required this.address,
        required this.phoneNumber,
        required this.email,
        required this.district,
        required this.hasEmergency,
        List<EvaluationReport>? avaliacoes,
      }) : avaliacoes = avaliacoes ?? [];


  factory Hospital.fromJSON(Map<String, dynamic> json){
    return Hospital(
      id: json['Id'] ?? 0,
      name: json['Name'] ?? 'Sem nome',
      latitude: (json['Latitude'] ?? 0.0).toDouble(),
      longitude: (json['Longitude'] ?? 0.0).toDouble(),
      address: json['Address'] ?? 'Sem morada',
      phoneNumber: json['Phone'] ?? 0,
      email: json['Email'] ?? 'sem@email.pt',
      district: json['District'] ?? 'Desconhecido',
      hasEmergency: json['HasEmergency'] ?? false,
    );
  }

  factory Hospital.fromDB(Map<String, dynamic> db){
    return Hospital(
      id: db['id'] ?? 0,
      name: db['name'] ?? 'Sem nome',
      latitude: (db['latitude'] ?? 0.0).toDouble(),
      longitude: (db['longitude'] ?? 0.0).toDouble(),
      address: db['address'] ?? 'Sem morada',
      phoneNumber: db['phoneNumber'] ?? 0,
      email: db['email'] ?? 'sem@email.pt',
      district: db['district'] ?? 'Desconhecido',
      hasEmergency: (db['hasEmergency'] ?? 0) == 1,
    );
  }


  Map<String, dynamic> toDb() {
    return{
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'phoneNumber': phoneNumber,
      'email': email,
      'district': district,
      'hasEmergency': hasEmergency ? 1 : 0,
    };
  }




  double distanciaDe(double minhaLat , double minhaLon){
    const R = 6371; // raio da Terra em km

    // Diferença de latitude e longitude em radianos
    final dLat = _grausParaRadianos(latitude - minhaLat);
    final dLon = _grausParaRadianos(longitude - minhaLon);

    // Fórmula de Haversine:

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_grausParaRadianos(minhaLat)) * cos(_grausParaRadianos(latitude)) *
            sin(dLon / 2) * sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    final distancia = R * c;

    return distancia;
  }

  double _grausParaRadianos(double graus) {
    return graus * pi / 180;
  }


}