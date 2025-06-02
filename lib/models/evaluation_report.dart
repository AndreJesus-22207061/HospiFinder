class EvaluationReport {
  final String id;
  final int hospitalId;
  final int rating;
  final DateTime dataHora;
  final String? notas;

  EvaluationReport({
    required this.id,
    required this.hospitalId,
    required this.rating,
    required this.dataHora,
    this.notas,
  });



  Map<String, dynamic> toDb() {
    return {
      'id': id,
      'hospitalId': hospitalId,
      'rating': rating,
      'date': dataHora.toIso8601String(),  // converte para string ISO8601
      'notes': notas,
    };
  }

  factory EvaluationReport.fromDb(Map<String, dynamic> map) {
    return EvaluationReport(
      id: map['id'] as String,
      hospitalId: int.parse(map['hospitalId'].toString()),
      rating: map['rating'] as int,
      dataHora: DateTime.parse(map['date'] as String),
      notas: map['notes'] as String?,
    );
  }



}