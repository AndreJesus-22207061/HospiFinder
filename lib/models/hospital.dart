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
  final List<EvaluationReport> avaliacoes;

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


  double distanciaDe(double minhaLat , double minhaLon){
    const R = 6371; // raio da Terra em km

    // Diferença de latitude e longitude em radianos
    final dLat = _grausParaRadianos(latitude - minhaLat);
    final dLon = _grausParaRadianos(longitude - minhaLon);

    // Fórmula de Haversine:
    // ( a ) representa o quadrado do semiverso do ângulo central entre os dois pontos
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_grausParaRadianos(minhaLat)) * cos(_grausParaRadianos(latitude)) *
            sin(dLon / 2) * sin(dLon / 2);

    // ( c ) é o ângulo central em radianos (distância angular)
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    // Distância final = raio da Terra * ângulo central
    final distancia = R * c;

    return distancia;
  }

  double _grausParaRadianos(double graus) {
    return graus * pi / 180;
  }
}