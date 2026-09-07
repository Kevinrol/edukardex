class Trimestre {
  final String id;
  final String gestionId;
  final int numero;
  final DateTime fechaInicio;
  final DateTime fechaFin;

  Trimestre({
    required this.id,
    required this.gestionId,
    required this.numero,
    required this.fechaInicio,
    required this.fechaFin,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'gestion_id': gestionId,
        'numero': numero,
        'fecha_inicio': fechaInicio.toIso8601String().split('T')[0],
        'fecha_fin': fechaFin.toIso8601String().split('T')[0],
      };

  factory Trimestre.fromJson(Map<String, dynamic> json) => Trimestre(
        id: json['id'],
        gestionId: json['gestion_id'],
        numero: json['numero'],
        fechaInicio: DateTime.parse(json['fecha_inicio']),
        fechaFin: DateTime.parse(json['fecha_fin']),
      );
}
