import 'package:supabase_flutter/supabase_flutter.dart';

class ResponsablePortalService {
  final _client = Supabase.instance.client;

  Future<String?> responsableIdDeUsuario(String usuarioId) async {
    final r = await _client
        .from('responsables')
        .select('id')
        .eq('usuario_id', usuarioId)
        .maybeSingle();
    return r?['id'] as String?;
  }

  /// Hijos vinculados al responsable.
  Future<List<Map<String, dynamic>>> hijos(String responsableId) async {
    final r = await _client
        .from('estudiante_responsable')
        .select('es_principal, estudiantes(id, ci, nombres, apellido_paterno, apellido_materno)')
        .eq('responsable_id', responsableId);
    return List<Map<String, dynamic>>.from(r as List);
  }

  /// Incumplimientos de un estudiante (todos los cursos y trimestres).
  Future<List<Map<String, dynamic>>> kardexDelHijo(String estudianteId) async {
    final r = await _client
        .from('kardex')
        .select(
            'trimestres(numero), cursos(nombre, paralelo), incumplimientos(id, fecha, descripcion, gravedad, accion_tomada, tipos_falta(nombre))')
        .eq('estudiante_id', estudianteId);
    final out = <Map<String, dynamic>>[];
    for (final k in List<Map<String, dynamic>>.from(r as List)) {
      final curso = k['cursos'];
      final cursoNombre = curso == null
          ? ''
          : '${curso['nombre']} ${curso['paralelo'] ?? ''}'.trim();
      for (final i in List<Map<String, dynamic>>.from(k['incumplimientos'] ?? [])) {
        out.add({
          ...i,
          'trimestre': k['trimestres']?['numero'],
          'curso': cursoNombre,
        });
      }
    }
    out.sort((a, b) =>
        (b['fecha'] ?? '').toString().compareTo((a['fecha'] ?? '').toString()));
    return out;
  }

  /// Notificaciones del responsable con el detalle del incumplimiento.
  Future<List<Map<String, dynamic>>> notificaciones(String responsableId) async {
    final r = await _client
        .from('notificaciones')
        .select(
            'id, estado, canal, created_at, incumplimientos(descripcion, gravedad, fecha, tipos_falta(nombre), kardex(estudiantes(nombres, apellido_paterno)))')
        .eq('responsable_id', responsableId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(r as List);
  }
}