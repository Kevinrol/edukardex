import 'package:supabase_flutter/supabase_flutter.dart';

class PerfilUsuario {
  final String id;
  final String colegioId;
  final String rol; // administrativo | director | docente | responsable
  final String nombreCompleto;
  final String email;

  PerfilUsuario({
    required this.id,
    required this.colegioId,
    required this.rol,
    required this.nombreCompleto,
    required this.email,
  });

  bool get esAdministrador => rol == 'administrativo' || rol == 'director';

  factory PerfilUsuario.fromJson(Map<String, dynamic> json) => PerfilUsuario(
        id: json['id'],
        colegioId: json['colegio_id'],
        rol: json['rol'],
        nombreCompleto: json['nombre_completo'],
        email: json['email'],
      );
}

class AuthService {
  final _client = Supabase.instance.client;

  Future<PerfilUsuario> iniciarSesion(String email, String password) async {
    await _client.auth.signInWithPassword(email: email, password: password);
    final perfil = await obtenerPerfil();
    if (perfil == null) {
      await _client.auth.signOut();
      throw Exception('Tu cuenta no tiene un perfil asignado. Contacta al administrador.');
    }
    return perfil;
  }

  Future<PerfilUsuario?> obtenerPerfil() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final data = await _client
        .from('usuarios')
        .select()
        .eq('id', user.id)
        .maybeSingle();
    if (data == null) return null;
    return PerfilUsuario.fromJson(data);
  }

  Future<void> cerrarSesion() => _client.auth.signOut();
}