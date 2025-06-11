class LocalidadeIPMA {
  final int idRegiao;
  final String idAreaAviso;
  final int idConcelho;
  final int globalIdLocal;
  final double latitude;
  final int idDistrito;
  final String local;
  final double longitude;

  LocalidadeIPMA({
    required this.idRegiao,
    required this.idAreaAviso,
    required this.idConcelho,
    required this.globalIdLocal,
    required this.latitude,
    required this.idDistrito,
    required this.local,
    required this.longitude,
  });

  factory LocalidadeIPMA.fromJSON(Map<String, dynamic> json) {
    return LocalidadeIPMA(
      idRegiao: json['idRegiao'],
      idAreaAviso: json['idAreaAviso'],
      idConcelho: json['idConcelho'],
      globalIdLocal: json['globalIdLocal'],
      latitude: double.parse(json['latitude']),
      idDistrito: json['idDistrito'],
      local: json['local'],
      longitude: double.parse(json['longitude']),
    );
  }

  Map<String, dynamic> toDb() {
    return {
      'idRegiao': idRegiao,
      'idAreaAviso': idAreaAviso,
      'idConcelho': idConcelho,
      'globalIdLocal': globalIdLocal,
      'latitude': latitude,
      'idDistrito': idDistrito,
      'local': local,
      'longitude': longitude,
    };
  }

  factory LocalidadeIPMA.fromDB(Map<String, dynamic> db) {
    return LocalidadeIPMA(
      idRegiao: db['idRegiao'],
      idAreaAviso: db['idAreaAviso'],
      idConcelho: db['idConcelho'],
      globalIdLocal: db['globalIdLocal'],
      latitude: db['latitude'],
      idDistrito: db['idDistrito'],
      local: db['local'],
      longitude: db['longitude'],
    );
  }
}