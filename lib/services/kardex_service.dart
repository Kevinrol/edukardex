import 'package:supabase_flutter/supabase_flutter.dart';

class KardexService {
  final _client = Supabase.instance.client;

  // ---------- Vista del docente ----------

  /// Id del docente a partir del usuario con sesión.
  Future<String?> docenteIdDeUsuario(String usuarioId) async {
    final r = await _client
        .from('docentes')
        .select('id')
        .eq('usuario_id', usuarioId)
        .maybeSingle();
    return r?['id'] as String?;
  }

  /// Cursos donde el docente da alguna materia.
  Future<List<Map<String, dynamic>>> cursosDelDocente(String docenteId) async {
    final r = await _client
        .from('curso_docente')
        .select('materia, cursos(id, nombre, paralelo, nivel, gestion_id, colegio_id)')
        .eq('docente_id', docenteId);
    return List<Map<String, dynamic>>.from(r as List);
  }

  Future<List<Map<String, dynamic>>> estudiantesDelCurso(String cursoId) async {
    final r = await _client
        .from('curso_estudiante')
        .select('estudiantes(id, ci, nombres, apellido_paterno, apellido_materno)')
        .eq('curso_id', cursoId);
    return List<Map<String, dynamic>>.from(r as List);
  }

  // ---------- Catálogo ----------

  Future<List<Map<String, dynamic>>> tiposFalta() async {
    final r = await _client.from('tipos_falta').select().order('nombre');
    return List<Map<String, dynamic>>.from(r as List);
  }

  // ---------- Kardex ----------

  /// Trimestre que contiene la fecha de hoy (o el más cercano).
  Future<Map<String, dynamic>?> trimestreActual(String gestionId) async {
    final r = await _client
        .from('trimestres')
        .select()
        .eq('gestion_id', gestionId)
        .order('numero');
    final lista = List<Map<String, dynamic>>.from(r as List);
    if (lista.isEmpty) return null;
    final hoy = DateTime.now();
    for (final t in lista) {
      final ini = DateTime.parse(t['fecha_inicio']);
      final fin = DateTime.parse(t['fecha_fin']).add(const Duration(days: 1));
      if (!hoy.isBefore(ini) && hoy.isBefore(fin)) return t;
    }
    // Si hoy cae fuera de todos, usa el último ya iniciado, o el primero.
    final iniciados = lista
        .where((t) => !DateTime.parse(t['fecha_inicio']).isAfter(hoy))
        .toList();
    return iniciados.isNotEmpty ? iniciados.last : lista.first;
  }

  /// Devuelve el id del kardex; lo crea si no existe.
  Future<String> obtenerOCrearKardex({
    required String estudianteId,
    required String cursoId,
    required String trimestreId,
  }) async {
    final existente = await _client
        .from('kardex')
        .select('id')
        .eq('estudiante_id', estudianteId)
        .eq('curso_id', cursoId)
        .eq('trimestre_id', trimestreId)
        .maybeSingle();
    if (existente != null) return existente['id'] as String;

    final nuevo = await _client
        .from('kardex')
        .insert({
          'estudiante_id': estudianteId,
          'curso_id': cursoId,
          'trimestre_id': trimestreId,
        })
        .select('id')
        .single();
    return nuevo['id'] as String;
  }

  // ---------- Incumplimientos ----------

  Future<void> registrarIncumplimiento({
    required String kardexId,
    required String docenteId,
    required String? tipoFaltaId,
    required String descripcion,
    required String gravedad,
    String? accionTomada,
  }) async {
    await _client.from('incumplimientos').insert({
      'kardex_id': kardexId,
      'docente_id': docenteId,
      'tipo_falta_id': tipoFaltaId,
      'descripcion': descripcion,
      'gravedad': gravedad,
      'accion_tomada': accionTomada,
    });
  }

  /// Historial del estudiante en un curso (todos los trimestres).
  Future<List<Map<String, dynamic>>> historial(
      String estudianteId, String cursoId) async {
    final r = await _client
        .from('kardex')
        .select(
            'id, trimestres(numero), incumplimientos(id, fecha, descripcion, gravedad, accion_tomada, tipos_falta(nombre))')
        .eq('estudiante_id', estudianteId)
        .eq('curso_id', cursoId);
    final kardexes = List<Map<String, dynamic>>.from(r as List);
    final out = <Map<String, dynamic>>[];
    for (final k in kardexes) {
      final trim = k['trimestres']?['numero'];
      for (final i in List<Map<String, dynamic>>.from(k['incumplimientos'] ?? [])) {
        out.add({...i, 'trimestre': trim});
      }
    }
    out.sort((a, b) => (b['fecha'] ?? '').toString().compareTo((a['fecha'] ?? '').toString()));
    return out;
  }
}