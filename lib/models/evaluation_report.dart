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
    return{
      'id': id,
      'hospitalId': hospitalId,
      'rating': rating,
      'date' : dataHora,
      'notes': notas
    };
  }


  factory EvaluationReport.fromDb(Map<String, dynamic> map) {
    return EvaluationReport(
      id: map['id'] as String,
      hospitalId: int.parse(map['hospitalId'].toString()), // pode vir como String
      rating: map['rating'] as int,
      dataHora: DateTime.parse(map['date'].toString()),
      notas: map['notes'] as String?,
    );
  }



}