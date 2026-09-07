class Docente {
  final String id;
  final String usuarioId;
  final String colegioId;
  final String? itemCodigo;
  final String? especialidad;
  final String? tipoContrato;
  final DateTime createdAt;

  Docente({
    required this.id,
    required this.usuarioId,
    required this.colegioId,
    this.itemCodigo,
    this.especialidad,
    this.tipoContrato,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'usuario_id': usuarioId,
        'colegio_id': colegioId,
        'item_codigo': itemCodigo,
        'especialidad': especialidad,
        'tipo_contrato': tipoContrato,
        // Supabase maneja created_at
      };

  factory Docente.fromJson(Map<String, dynamic> json) => Docente(
        id: json['id'],
        usuarioId: json['usuario_id'],
        colegioId: json['colegio_id'],
        itemCodigo: json['item_codigo'],
        especialidad: json['especialidad'],
        tipoContrato: json['tipo_contrato'],
        createdAt: DateTime.parse(json['created_at']),
      );
}
