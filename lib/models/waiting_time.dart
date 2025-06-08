import 'package:flutter/material.dart';

class WaitingTime {
  final String emergency;
  final Map<String, int> waitTimes;
  final Map<String, int> queueLengths;
  final DateTime lastUpdate;

  WaitingTime({
    required this.emergency,
    required this.waitTimes,
    required this.queueLengths,
    required this.lastUpdate,
  });

  factory WaitingTime.fromJSON(Map<String, dynamic> json) {
    final waitTimes = <String, int>{};
    final queueLengths = <String, int>{};

    for (var color in ['Red', 'Orange', 'Yellow', 'Green', 'Blue', 'Grey']) {
      final data = json[color];
      if (data != null) {
        waitTimes[color] = data['Time'] ?? 0;
        queueLengths[color] = data['Length'] ?? 0;
      }
    }

    return WaitingTime(
     emergency: json['Emergency']['Description'] ?? '',
     waitTimes: waitTimes,
     queueLengths: queueLengths,
     lastUpdate: DateTime.parse(json['LastUpdate']),
    );
  }

  factory WaitingTime.fromDB(Map<String, dynamic> map) {
    return WaitingTime(
      emergency: map['emergencyDescription'] ?? '',
      lastUpdate: DateTime.parse(map['lastUpdate']),
      waitTimes: {
        'Red': map['redTime'],
        'Orange': map['orangeTime'],
        'Yellow': map['yellowTime'],
        'Green': map['greenTime'],
        'Blue': map['blueTime'],
        'Grey': map['greyTime'],
      },
      queueLengths: {
        'Red': map['redLength'],
        'Orange': map['orangeLength'],
        'Yellow': map['yellowLength'],
        'Green': map['greenLength'],
        'Blue': map['blueLength'],
        'Grey': map['greyLength'],
      },
    );
  }


  Map<String, dynamic> toDB(int hospitalId) {
    return {
      'hospitalId': hospitalId,
      'lastUpdate': lastUpdate.toIso8601String(),
      'emergencyType': emergency,
      'emergencyDescription': emergency,
      'redTime': waitTimes['Red'] ?? 0,
      'redLength': queueLengths['Red'] ?? 0,
      'orangeTime': waitTimes['Orange'] ?? 0,
      'orangeLength': queueLengths['Orange'] ?? 0,
      'yellowTime': waitTimes['Yellow'] ?? 0,
      'yellowLength': queueLengths['Yellow'] ?? 0,
      'greenTime': waitTimes['Green'] ?? 0,
      'greenLength': queueLengths['Green'] ?? 0,
      'blueTime': waitTimes['Blue'] ?? 0,
      'blueLength': queueLengths['Blue'] ?? 0,
      'greyTime': waitTimes['Grey'] ?? 0,
      'greyLength': queueLengths['Grey'] ?? 0,
    };
  }



  String formatarTempo(int segundos) {
    if (segundos <= 0) return '0min';

    final minutos = segundos ~/ 60;

    final dias = minutos ~/ 1440; // 1440 = 24 * 60
    final horas = (minutos % 1440) ~/ 60;
    final restoMin = minutos % 60;

    if (dias > 0) {
      if (horas > 0) {
        return '${dias}d ${horas}h';
      } else {
        return '${dias}d';
      }
    } else if (horas > 0 && restoMin > 0) {
      return '${horas}h${restoMin}min';
    } else if (horas > 0) {
      return '${horas}h';
    } else {
      return '${restoMin}min';
    }
  }

  String getlastUpdatedFormatado() {
    return '${lastUpdate.day.toString().padLeft(2, '0')}/${lastUpdate.month.toString().padLeft(2, '0')}/${lastUpdate.year} '
        '${lastUpdate.hour.toString().padLeft(2, '0')}:${lastUpdate.minute.toString().padLeft(2, '0')}';
  }
}