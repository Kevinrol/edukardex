class Colegio {
  final String id;
  final String nombre;
  final String? direccion;
  final String? telefono;
  final String? directorNombre;
  final bool activo;
  final DateTime createdAt;

  Colegio({
    required this.id,
    required this.nombre,
    this.direccion,
    this.telefono,
    this.directorNombre,
    this.activo = true,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'direccion': direccion,
        'telefono': telefono,
        'director_nombre': directorNombre,
        'activo': activo,
        // Supabase maneja created_at
      };

  factory Colegio.fromJson(Map<String, dynamic> json) => Colegio(
        id: json['id'],
        nombre: json['nombre'],
        direccion: json['direccion'],
        telefono: json['telefono'],
        directorNombre: json['director_nombre'],
        activo: json['activo'] ?? true,
        createdAt: DateTime.parse(json['created_at']),
      );
}
