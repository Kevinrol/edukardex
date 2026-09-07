import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/gestion_academica.dart';
import '../models/trimestre.dart';

class GestionService {
  final _client = Supabase.instance.client;

  Future<List<GestionAcademica>> listarPorColegio(String colegioId) async {
    final response = await _client
        .from('gestiones_academicas')
        .select()
        .eq('colegio_id', colegioId)
        .order('anio', ascending: false);
    
    return (response as List<dynamic>)
        .map((e) => GestionAcademica.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> agregar(GestionAcademica gestion) async {
    await _client.from('gestiones_academicas').insert(gestion.toJson());
  }

  Future<void> agregarTrimestres(List<Trimestre> trimestres) async {
    if (trimestres.isEmpty) return;
    final data = trimestres.map((t) => t.toJson()).toList();
    await _client.from('trimestres').insert(data);
  }

  Future<List<Trimestre>> listarTrimestres(String gestionId) async {
    final response = await _client
        .from('trimestres')
        .select()
        .eq('gestion_id', gestionId)
        .order('numero', ascending: true);
    
    return (response as List<dynamic>)
        .map((e) => Trimestre.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
