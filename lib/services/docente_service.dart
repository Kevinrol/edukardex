import 'usuario_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/docente.dart';

class DocenteService {
  final _client = Supabase.instance.client;

  Future<List<Docente>> listar() async {
    final response = await _client
        .from('docentes')
        .select()
        .order('created_at', ascending: false);
    
    return (response as List<dynamic>)
        .map((e) => Docente.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> agregar(Docente docente) async {
    await _client.from('docentes').insert(docente.toJson());
  }

  Future<void> actualizar(Docente docente) async {
    await _client
        .from('docentes')
        .update(docente.toJson())
        .eq('id', docente.id);
  }

  Future<void> eliminar(String id) async {
    await _client.from('docentes').delete().eq('id', id);
  }

  Future<List<Docente>> listarPorColegio(String colegioId) async {
    final response = await _client
        .from('docentes')
        .select()
        .eq('colegio_id', colegioId)
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((e) => Docente.fromJson(e as Map<String, dynamic>))
        .toList();
  }

    /// Docentes con nombre y correo (une con la tabla usuarios).
  Future<List<Map<String, dynamic>>> listarConUsuario(String colegioId) async {
    final response = await _client
        .from('docentes')
        .select('*, usuarios(nombre_completo, email, telefono)')
        .eq('colegio_id', colegioId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response as List);
  }

  /// Crea cuenta de login + usuario + docente.
  Future<void> crearConUsuario({
    required String colegioId,
    required String nombreCompleto,
    required String email,
    required String password,
    String? telefono,
    String? itemCodigo,
    String? especialidad,
    String? tipoContrato,
  }) async {
    final usuarios = UsuarioService();
    final uid = await usuarios.crearUsuario(
      colegioId: colegioId,
      rol: 'docente',
      nombreCompleto: nombreCompleto,
      email: email,
      password: password,
      telefono: telefono,
    );
    try {
      await _client.from('docentes').insert({
        'usuario_id': uid,
        'colegio_id': colegioId,
        'item_codigo': itemCodigo,
        'especialidad': especialidad,
        'tipo_contrato': tipoContrato,
      });
    } catch (e) {
      await usuarios.eliminarFilaUsuario(uid); // limpieza parcial
      rethrow;
    }
  }
}
