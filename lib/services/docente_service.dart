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
}
