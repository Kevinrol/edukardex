import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/estudiante.dart';

class EstudianteService {
  final _client = Supabase.instance.client;

  Future<List<Estudiante>> listar() async {
    final response = await _client
        .from('estudiantes')
        .select()
        .order('created_at', ascending: false);
    
    return (response as List<dynamic>)
        .map((e) => Estudiante.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> agregar(Estudiante estudiante) async {
    await _client.from('estudiantes').insert(estudiante.toJson());
  }

  Future<void> eliminar(String id) async {
    await _client.from('estudiantes').delete().eq('id', id);
  }

  Future<bool> ciYaRegistrado(String ci) async {
    final response = await _client
        .from('estudiantes')
        .select('id')
        .eq('ci', ci)
        .limit(1);
    
    return (response as List).isNotEmpty;
  }
}
