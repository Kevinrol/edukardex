class Curso {
  final String id;
  final String colegioId;
  final String gestionId;
  final String nombre;
  final String? paralelo;
  final String? nivel;
  final DateTime createdAt;

  Curso({
    required this.id,
    required this.colegioId,
    required this.gestionId,
    required this.nombre,
    this.paralelo,
    this.nivel,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'colegio_id': colegioId,
        'gestion_id': gestionId,
        'nombre': nombre,
        'paralelo': paralelo,
        'nivel': nivel,
        // Supabase maneja created_at
      };

  factory Curso.fromJson(Map<String, dynamic> json) => Curso(
        id: json['id'],
        colegioId: json['colegio_id'],
        gestionId: json['gestion_id'],
        nombre: json['nombre'],
        paralelo: json['paralelo'],
        nivel: json['nivel'],
        createdAt: DateTime.parse(json['created_at']),
      );
}
