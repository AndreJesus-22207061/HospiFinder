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

}