class Estudiante {
  final String id;
  final String colegioId;
  final String ci;
  final String nombres;
  final String apellidoPaterno;
  final String? apellidoMaterno;
  final String? fechaNacimiento;
  final bool activo;
  final DateTime createdAt;

  Estudiante({
    required this.id,
    required this.colegioId,
    required this.ci,
    required this.nombres,
    required this.apellidoPaterno,
    this.apellidoMaterno,
    this.fechaNacimiento,
    this.activo = true,
    required this.createdAt,
  });

  String get nombreCompleto => '$nombres $apellidoPaterno ${apellidoMaterno ?? ''}'.trim();

  Map<String, dynamic> toJson() => {
        'id': id,
        'colegio_id': colegioId,
        'ci': ci,
        'nombres': nombres,
        'apellido_paterno': apellidoPaterno,
        'apellido_materno': apellidoMaterno,
        'fecha_nacimiento': fechaNacimiento,
        'activo': activo,
        // Supabase maneja el created_at en la DB, pero podemos mandarlo si queremos
      };

  factory Estudiante.fromJson(Map<String, dynamic> json) => Estudiante(
        id: json['id'],
        colegioId: json['colegio_id'],
        ci: json['ci'],
        nombres: json['nombres'],
        apellidoPaterno: json['apellido_paterno'],
        apellidoMaterno: json['apellido_materno'],
        fechaNacimiento: json['fecha_nacimiento'],
        activo: json['activo'] ?? true,
        createdAt: DateTime.parse(json['created_at']),
      );
}
