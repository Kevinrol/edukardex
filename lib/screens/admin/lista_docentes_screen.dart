import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/docente_service.dart';
import '../../theme/app_theme.dart';
import 'registro_docente_screen.dart';

class ListaDocentesScreen extends StatefulWidget {
  final String colegioId;
  const ListaDocentesScreen({super.key, required this.colegioId});

  @override
  State<ListaDocentesScreen> createState() => _ListaDocentesScreenState();
}

class _ListaDocentesScreenState extends State<ListaDocentesScreen> {
  final _service = DocenteService();
  List<Map<String, dynamic>> _docentes = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    try {
      final lista = await _service.listarConUsuario(widget.colegioId);
      if (!mounted) return;
      setState(() {
        _docentes = lista;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _cargando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Docentes')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RegistroDocenteScreen(colegioId: widget.colegioId),
            ),
          );
          _cargar();
        },
        backgroundColor: AppColors.azulPrimario,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Nuevo docente'),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _docentes.isEmpty
              ? Center(
                  child: Text('No hay docentes en este colegio',
                      style: GoogleFonts.poppins(color: Colors.grey)),
                )
              : RefreshIndicator(
                  onRefresh: _cargar,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                    itemCount: _docentes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final d = _docentes[i];
                      final u = d['usuarios'] as Map<String, dynamic>?;
                      final nombre = u?['nombre_completo'] ?? 'Sin nombre';
                      final email = u?['email'] ?? '-';
                      final esp = d['especialidad'] ?? 'Sin especialidad';
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.azulClaro,
                            child: Text(
                              nombre.toString().isNotEmpty
                                  ? nombre.toString()[0].toUpperCase()
                                  : '?',
                              style: GoogleFonts.poppins(
                                  color: AppColors.azulPrimario,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(nombre,
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                          subtitle: Text('$esp\n$email'),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}