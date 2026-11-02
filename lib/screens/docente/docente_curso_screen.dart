import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/kardex_service.dart';
import '../../theme/app_theme.dart';
import 'registro_incumplimiento_screen.dart';
import 'historial_estudiante_screen.dart';

class DocenteCursoScreen extends StatefulWidget {
  final Map<String, dynamic> curso;
  final String docenteId;
  const DocenteCursoScreen({super.key, required this.curso, required this.docenteId});

  @override
  State<DocenteCursoScreen> createState() => _DocenteCursoScreenState();
}

class _DocenteCursoScreenState extends State<DocenteCursoScreen> {
  final _service = KardexService();
  List<Map<String, dynamic>> _estudiantes = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final lista = await _service.estudiantesDelCurso(widget.curso['id']);
      if (!mounted) return;
      setState(() {
        _estudiantes = lista;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _cargando = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  String _nombre(Map<String, dynamic> e) =>
      '${e['nombres']} ${e['apellido_paterno']} ${e['apellido_materno'] ?? ''}'.trim();

  @override
  Widget build(BuildContext context) {
    final c = widget.curso;
    return Scaffold(
      backgroundColor: AppColors.grisFondo,
      appBar: AppBar(title: Text('${c['nombre']} ${c['paralelo'] ?? ''}'.trim())),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _estudiantes.isEmpty
              ? Center(
                  child: Text('No hay estudiantes inscritos',
                      style: GoogleFonts.poppins(color: Colors.grey)))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _estudiantes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final e = _estudiantes[i]['estudiantes'] as Map<String, dynamic>;
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
                        subtitle: Text('CI: ${e['ci']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Historial',
                              icon: const Icon(Icons.history,
                                  color: AppColors.azulPrimario),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => HistorialEstudianteScreen(
                                    estudianteId: e['id'],
                                    nombre: _nombre(e),
                                    cursoId: widget.curso['id'],
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Registrar incumplimiento',
                              icon: const Icon(Icons.report_gmailerrorred_rounded,
                                  color: AppColors.rojoError),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RegistroIncumplimientoScreen(
                                    estudianteId: e['id'],
                                    nombre: _nombre(e),
                                    curso: widget.curso,
                                    docenteId: widget.docenteId,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}