import 'package:supabase_flutter/supabase_flutter.dart';

class InscripcionService {
  final _client = Supabase.instance.client;

  // ---------- ESTUDIANTES ----------

  /// Estudiantes inscritos en un curso: [{id (vínculo), estudiantes: {...}}]
  Future<List<Map<String, dynamic>>> estudiantesDelCurso(String cursoId) async {
    final r = await _client
        .from('curso_estudiante')
        .select('id, estudiantes(id, ci, nombres, apellido_paterno, apellido_materno)')
        .eq('curso_id', cursoId);
    return List<Map<String, dynamic>>.from(r as List);
  }

  /// Estudiantes activos del colegio que NO tienen curso en esa gestión.
  Future<List<Map<String, dynamic>>> estudiantesDisponibles(
      String colegioId, String gestionId) async {
    final todos = await _client
        .from('estudiantes')
        .select('id, ci, nombres, apellido_paterno, apellido_materno')
        .eq('colegio_id', colegioId)
        .eq('activo', true)
        .order('apellido_paterno');
    final inscritos = await _client
        .from('curso_estudiante')
        .select('estudiante_id')
        .eq('gestion_id', gestionId);
    final ids = (inscritos as List).map((e) => e['estudiante_id']).toSet();
    return List<Map<String, dynamic>>.from(todos as List)
        .where((e) => !ids.contains(e['id']))
        .toList();
  }

  Future<void> inscribir(String cursoId, String estudianteId, String gestionId) async {
    await _client.from('curso_estudiante').insert({
      'curso_id': cursoId,
      'estudiante_id': estudianteId,
      'gestion_id': gestionId,
    });
  }

  Future<void> quitarEstudiante(String vinculoId) async {
    await _client.from('curso_estudiante').delete().eq('id', vinculoId);
  }

  // ---------- DOCENTES ----------

  Future<List<Map<String, dynamic>>> docentesDelCurso(String cursoId) async {
    final r = await _client
        .from('curso_docente')
        .select('id, materia, docente_id, docentes(id, usuarios(nombre_completo))')
        .eq('curso_id', cursoId);
    return List<Map<String, dynamic>>.from(r as List);
  }

  Future<List<Map<String, dynamic>>> docentesDelColegio(String colegioId) async {
    final r = await _client
        .from('docentes')
        .select('id, especialidad, usuarios(nombre_completo)')
        .eq('colegio_id', colegioId);
    return List<Map<String, dynamic>>.from(r as List);
  }

  Future<void> asignarDocente(String cursoId, String docenteId, String materia) async {
    await _client.from('curso_docente').insert({
      'curso_id': cursoId,
      'docente_id': docenteId,
      'materia': materia,
    });
  }

  Future<void> quitarDocente(String vinculoId) async {
    await _client.from('curso_docente').delete().eq('id', vinculoId);
  }

  // ---------- DOCENTE GUÍA ----------

  Future<String?> docenteGuiaId(String cursoId) async {
    final r = await _client
        .from('cursos')
        .select('docente_guia_id')
        .eq('id', cursoId)
        .single();
    return r['docente_guia_id'] as String?;
  }

  Future<void> definirGuia(String cursoId, String? docenteId) async {
    await _client.from('cursos').update({'docente_guia_id': docenteId}).eq('id', cursoId);
  }
}