import 'package:supabase_flutter/supabase_flutter.dart';
import 'usuario_service.dart';

class ResponsableService {
  final _client = Supabase.instance.client;

  /// Responsables vinculados a un estudiante.
  Future<List<Map<String, dynamic>>> listarPorEstudiante(String estudianteId) async {
    final r = await _client
        .from('estudiante_responsable')
        .select('id, es_principal, responsables(*)')
        .eq('estudiante_id', estudianteId);
    return List<Map<String, dynamic>>.from(r as List);
  }

  /// Todos los responsables de un colegio.
  Future<List<Map<String, dynamic>>> listarPorColegio(String colegioId) async {
    final r = await _client
        .from('responsables')
        .select()
        .eq('colegio_id', colegioId)
        .order('nombre_completo');
    return List<Map<String, dynamic>>.from(r as List);
  }

  /// Vincula un responsable a un estudiante. El primero queda como principal.
  Future<void> vincular(String estudianteId, String responsableId) async {
    final existentes = await _client
        .from('estudiante_responsable')
        .select('id')
        .eq('estudiante_id', estudianteId);
    final esPrincipal = (existentes as List).isEmpty;

    await _client.from('estudiante_responsable').insert({
      'estudiante_id': estudianteId,
      'responsable_id': responsableId,
      'es_principal': esPrincipal,
    });
  }

  Future<void> desvincular(String vinculoId) async {
    await _client.from('estudiante_responsable').delete().eq('id', vinculoId);
  }

  /// Crea cuenta de login + usuario + responsable y lo vincula al estudiante.
  Future<void> crearConUsuarioYVincular({
    required String colegioId,
    required String estudianteId,
    required String nombreCompleto,
    required String email,
    required String password,
    required String telefono,
    String? ci,
    String? parentesco,
  }) async {
    final usuarios = UsuarioService();
    final uid = await usuarios.crearUsuario(
      colegioId: colegioId,
      rol: 'responsable',
      nombreCompleto: nombreCompleto,
      email: email,
      password: password,
      telefono: telefono,
    );

    try {
      final fila = await _client
          .from('responsables')
          .insert({
            'usuario_id': uid,
            'colegio_id': colegioId,
            'nombre_completo': nombreCompleto,
            'ci': ci,
            'telefono': telefono,
            'email': email,
            'parentesco': parentesco,
          })
          .select('id')
          .single();

      await vincular(estudianteId, fila['id'] as String);
    } catch (e) {
      await usuarios.eliminarFilaUsuario(uid); // limpieza parcial
      rethrow;
    }
  }
}