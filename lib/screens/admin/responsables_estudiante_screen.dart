import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/estudiante.dart';
import '../../services/responsable_service.dart';
import '../../theme/app_theme.dart';
import 'registro_responsable_screen.dart';

class ResponsablesEstudianteScreen extends StatefulWidget {
  final Estudiante estudiante;
  const ResponsablesEstudianteScreen({super.key, required this.estudiante});

  @override
  State<ResponsablesEstudianteScreen> createState() => _ResponsablesEstudianteScreenState();
}

class _ResponsablesEstudianteScreenState extends State<ResponsablesEstudianteScreen> {
  final _service = ResponsableService();
  List<Map<String, dynamic>> _vinculos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    try {
      final lista = await _service.listarPorEstudiante(widget.estudiante.id);
      if (!mounted) return;
      setState(() {
        _vinculos = lista;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _cargando = false);
      _aviso('Error al cargar: $e', error: true);
    }
  }

  void _aviso(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? AppColors.rojoError : AppColors.verdeExito,
      ),
    );
  }

  Future<void> _crearNuevo() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegistroResponsableScreen(
          colegioId: widget.estudiante.colegioId,
          estudianteId: widget.estudiante.id,
        ),
      ),
    );
    _cargar();
  }

  Future<void> _seleccionarExistente() async {
    try {
      final todos = await _service.listarPorColegio(widget.estudiante.colegioId);
      final yaVinculados = _vinculos
          .map((v) => (v['responsables'] as Map<String, dynamic>)['id'])
          .toSet();
      final disponibles = todos.where((r) => !yaVinculados.contains(r['id'])).toList();

      if (!mounted) return;
      if (disponibles.isEmpty) {
        _aviso('No hay otros responsables en este colegio. Crea uno nuevo.', error: true);
        return;
      }

      final elegido = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (ctx) => SimpleDialog(
          title: const Text('Seleccionar responsable'),
          children: disponibles
              .map((r) => SimpleDialogOption(
                    onPressed: () => Navigator.pop(ctx, r),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(r['nombre_completo'] ?? ''),
                      subtitle: Text('${r['parentesco'] ?? '-'} | Tel: ${r['telefono'] ?? '-'}'),
                    ),
                  ))
              .toList(),
        ),
      );

      if (elegido == null) return;
      await _service.vincular(widget.estudiante.id, elegido['id'] as String);
      _aviso('Responsable vinculado');
      _cargar();
    } catch (e) {
      if (!mounted) return;
      _aviso('Error: $e', error: true);
    }
  }

  Future<void> _desvincular(Map<String, dynamic> v) async {
    final r = v['responsables'] as Map<String, dynamic>;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quitar responsable'),
        content: Text('¿Quitar a ${r['nombre_completo']} de este estudiante?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Quitar')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _service.desvincular(v['id'] as String);
      _cargar();
    } catch (e) {
      if (!mounted) return;
      _aviso('Error: $e', error: true);
    }
  }

  void _opcionesAgregar() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_add_alt_1),
              title: const Text('Crear responsable nuevo'),
              onTap: () {
                Navigator.pop(ctx);
                _crearNuevo();
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Seleccionar uno existente'),
              onTap: () {
                Navigator.pop(ctx);
                _seleccionarExistente();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Responsables de ${widget.estudiante.nombres}')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _opcionesAgregar,
        backgroundColor: AppColors.azulPrimario,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Agregar responsable'),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _vinculos.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'Este estudiante aún no tiene responsables.\nSin ellos no se podrán enviar avisos.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                  itemCount: _vinculos.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final v = _vinculos[i];
                    final r = v['responsables'] as Map<String, dynamic>;
                    final principal = v['es_principal'] == true;
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.azulClaro,
                          child: Icon(Icons.family_restroom_rounded, color: AppColors.azulPrimario),
                        ),
                        title: Text(r['nombre_completo'] ?? '',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                            '${r['parentesco'] ?? '-'} | Tel: ${r['telefono'] ?? '-'}'
                            '${principal ? '\nResponsable principal' : ''}'),
                        isThreeLine: principal,
                        trailing: IconButton(
                          icon: const Icon(Icons.link_off, color: AppColors.rojoError),
                          tooltip: 'Quitar',
                          onPressed: () => _desvincular(v),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}