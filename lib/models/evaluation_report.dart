class EvaluationReport {
  final int rating;
  final DateTime dataHora;
  final String? notas;

  EvaluationReport({
    required this.rating,
    required this.dataHora,
    this.notas,
  });

}