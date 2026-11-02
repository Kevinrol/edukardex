import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../services/kardex_service.dart';
import '../../theme/app_theme.dart';
import '../login_screen.dart';
import 'docente_curso_screen.dart';

class DocenteHomeScreen extends StatefulWidget {
  final PerfilUsuario perfil;
  const DocenteHomeScreen({super.key, required this.perfil});

  @override
  State<DocenteHomeScreen> createState() => _DocenteHomeScreenState();
}

class _DocenteHomeScreenState extends State<DocenteHomeScreen> {
  final _service = KardexService();
  List<Map<String, dynamic>> _cursos = [];
  String? _docenteId;
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
      final id = await _service.docenteIdDeUsuario(widget.perfil.id);
      if (id == null) {
        throw Exception('Tu usuario no tiene registro de docente.');
      }
      final cursos = await _service.cursosDelDocente(id);
      if (!mounted) return;
      setState(() {
        _docenteId = id;
        _cursos = cursos;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grisFondo,
      appBar: AppBar(
        title: Text('Hola, ${widget.perfil.nombreCompleto}'),
        actions: [
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
              : _cursos.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Aún no tienes cursos asignados.\nPide al administrador que te asigne uno.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(color: Colors.grey),
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _cargar,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _cursos.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) {
                          final v = _cursos[i];
                          final c = v['cursos'] as Map<String, dynamic>;
                          final nombre =
                              '${c['nombre']} ${c['paralelo'] ?? ''}'.trim();
                          return Card(
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: AppColors.azulClaro,
                                child: Icon(Icons.class_rounded,
                                    color: AppColors.azulPrimario),
                              ),
                              title: Text(nombre,
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600)),
                              subtitle: Text('Materia: ${v['materia']}'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DocenteCursoScreen(
                                    curso: c,
                                    docenteId: _docenteId!,
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