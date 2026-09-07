import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/curso.dart';

class CursoService {
  final _client = Supabase.instance.client;

  Future<List<Curso>> listarPorGestion(String gestionId) async {
    final response = await _client
        .from('cursos')
        .select()
        .eq('gestion_id', gestionId)
        .order('created_at', ascending: true);
    
    return (response as List<dynamic>)
        .map((e) => Curso.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Curso>> listarPorColegio(String colegioId) async {
    final response = await _client
        .from('cursos')
        .select()
        .eq('colegio_id', colegioId)
        .order('created_at', ascending: true);
    
    return (response as List<dynamic>)
        .map((e) => Curso.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> agregar(Curso curso) async {
    await _client.from('cursos').insert(curso.toJson());
  }

  Future<void> eliminar(String id) async {
    await _client.from('cursos').delete().eq('id', id);
  }
}
