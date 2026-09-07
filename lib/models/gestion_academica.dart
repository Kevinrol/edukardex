class GestionAcademica {
  final String id;
  final String colegioId;
  final int anio;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final bool activa;
  final DateTime createdAt;

  GestionAcademica({
    required this.id,
    required this.colegioId,
    required this.anio,
    required this.fechaInicio,
    required this.fechaFin,
    this.activa = true,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'colegio_id': colegioId,
        'anio': anio,
        'fecha_inicio': fechaInicio.toIso8601String().split('T')[0],
        'fecha_fin': fechaFin.toIso8601String().split('T')[0],
        'activa': activa,
      };

  factory GestionAcademica.fromJson(Map<String, dynamic> json) => GestionAcademica(
        id: json['id'],
        colegioId: json['colegio_id'],
        anio: json['anio'],
        fechaInicio: DateTime.parse(json['fecha_inicio']),
        fechaFin: DateTime.parse(json['fecha_fin']),
        activa: json['activa'] ?? true,
        createdAt: DateTime.parse(json['created_at']),
      );
}
