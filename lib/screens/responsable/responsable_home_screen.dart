import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../services/responsable_portal_service.dart';
import '../../theme/app_theme.dart';
import '../login_screen.dart';
import 'kardex_hijo_screen.dart';
import 'notificaciones_screen.dart';

class ResponsableHomeScreen extends StatefulWidget {
  final PerfilUsuario perfil;
  const ResponsableHomeScreen({super.key, required this.perfil});

  @override
  State<ResponsableHomeScreen> createState() => _ResponsableHomeScreenState();
}

class _ResponsableHomeScreenState extends State<ResponsableHomeScreen> {
  final _service = ResponsablePortalService();
  List<Map<String, dynamic>> _hijos = [];
  String? _responsableId;
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final id = await _service.responsableIdDeUsuario(widget.perfil.id);
      if (id == null) {
        throw Exception('Tu usuario no tiene registro de responsable.');
      }
      final hijos = await _service.hijos(id);
      if (!mounted) return;
      setState(() {
        _responsableId = id;
        _hijos = hijos;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _cargando = false;
      });
    }
  }

  Future<void> _salir() async {
    await AuthService().cerrarSesion();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  String _nombre(Map<String, dynamic> e) =>
      '${e['nombres']} ${e['apellido_paterno']} ${e['apellido_materno'] ?? ''}'.trim();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grisFondo,
      appBar: AppBar(
        title: Text('Hola, ${widget.perfil.nombreCompleto}'),
        actions: [
          if (_responsableId != null)
            IconButton(
              tooltip: 'Notificaciones',
              icon: const Icon(Icons.notifications_rounded),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NotificacionesScreen(responsableId: _responsableId!),
                ),
              ),
            ),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout_rounded),
            onPressed: _salir,
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(_error!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(color: AppColors.rojoError)),
                  ),
                )
              : _hijos.isEmpty
                  ? Center(
                      child: Text('No tienes estudiantes vinculados',
                          style: GoogleFonts.poppins(color: Colors.grey)))
                  : RefreshIndicator(
                      onRefresh: _cargar,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _hijos.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) {
                          final e = _hijos[i]['estudiantes'] as Map<String, dynamic>;
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.azulClaro,
                                child: Text(e['nombres'].toString()[0].toUpperCase(),
                                    style: GoogleFonts.poppins(
                                        color: AppColors.azulPrimario,
                                        fontWeight: FontWeight.bold)),
                              ),
                              title: Text(_nombre(e),
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                              subtitle: const Text('Ver kardex'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => KardexHijoScreen(
                                    estudianteId: e['id'],
                                    nombre: _nombre(e),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}