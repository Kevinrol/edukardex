import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class UsuarioService {
  final _client = Supabase.instance.client;

  /// Crea la cuenta de login SIN tocar la sesión actual de la app.
  Future<String> _crearCuentaAuth(String email, String password) async {
    final url = dotenv.env['SUPABASE_URL']!;
    final key = dotenv.env['SUPABASE_ANON_KEY']!;

    final res = await http.post(
      Uri.parse('$url/auth/v1/signup'),
      headers: {'apikey': key, 'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 400) {
      throw Exception(body['msg'] ??
          body['error_description'] ??
          body['message'] ??
          'No se pudo crear la cuenta');
    }
    final user = (body['user'] as Map<String, dynamic>?) ?? body;
    return user['id'] as String;
  }

  /// Crea cuenta de login + fila en `usuarios`. Devuelve el id del usuario.
  /// rol: administrativo | director | docente | responsable
  Future<String> crearUsuario({
    required String colegioId,
    required String rol,
    required String nombreCompleto,
    required String email,
    required String password,
    String? telefono,
  }) async {
    final uid = await _crearCuentaAuth(email, password);
    await _client.from('usuarios').insert({
      'id': uid,
      'colegio_id': colegioId,
      'rol': rol,
      'nombre_completo': nombreCompleto,
      'email': email,
      'telefono': telefono,
    });
    return uid;
  }

  Future<void> eliminarFilaUsuario(String id) async {
    await _client.from('usuarios').delete().eq('id', id);
  }
}