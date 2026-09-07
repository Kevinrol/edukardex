import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/colegio.dart';

class ColegioService {
  final _client = Supabase.instance.client;

  Future<List<Colegio>> listar() async {
    final response = await _client
        .from('colegios')
        .select()
        .order('created_at', ascending: false);
    
    return (response as List<dynamic>)
        .map((e) => Colegio.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> agregar(Colegio colegio) async {
    await _client.from('colegios').insert(colegio.toJson());
  }

  Future<void> actualizar(Colegio colegio) async {
    await _client
        .from('colegios')
        .update(colegio.toJson())
        .eq('id', colegio.id);
  }

  Future<void> eliminar(String id) async {
    await _client.from('colegios').delete().eq('id', id);
  }
}
