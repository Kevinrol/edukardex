import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/curso.dart';
import '../../services/inscripcion_service.dart';
import '../../theme/app_theme.dart';

class CursoDetailScreen extends StatefulWidget {
  final Curso curso;
  const CursoDetailScreen({super.key, required this.curso});

  @override
  State<CursoDetailScreen> createState() => _CursoDetailScreenState();
}

class _CursoDetailScreenState extends State<CursoDetailScreen>
    with SingleTickerProviderStateMixin {
  final _service = InscripcionService();
  late TabController _tab;

  List<Map<String, dynamic>> _estudiantes = [];
  List<Map<String, dynamic>> _docentes = [];
  String? _guiaId;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(() => setState(() {}));
    _cargar();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    try {
      final e = await _service.estudiantesDelCurso(widget.curso.id);
      final d = await _service.docentesDelCurso(widget.curso.id);
      final g = await _service.docenteGuiaId(widget.curso.id);
      if (!mounted) return;
      setState(() {
        _estudiantes = e;
        _docentes = d;
        _guiaId = g;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _cargando = false);
      _aviso('Error al cargar: $e', error: true);
    }
  }

  void _aviso(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? AppColors.rojoError : AppColors.verdeExito,
    ));
  }

  String _nombreEst(Map<String, dynamic> e) =>
      '${e['nombres']} ${e['apellido_paterno']} ${e['apellido_materno'] ?? ''}'.trim();

  // ---------- Inscribir estudiante ----------
  Future<void> _inscribir() async {
    try {
      final disp = await _service.estudiantesDisponibles(
          widget.curso.colegioId, widget.curso.gestionId);
      if (!mounted) return;
      if (disp.isEmpty) {
        _aviso('No hay estudiantes disponibles en esta gestión', error: true);
        return;
      }
      final elegido = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (ctx) => SimpleDialog(
          title: const Text('Inscribir estudiante'),
          children: [
            SizedBox(
              width: 400,
              height: 350,
              child: ListView(
                children: disp
                    .map((e) => ListTile(
                          title: Text(_nombreEst(e)),
                          subtitle: Text('CI: ${e['ci']}'),
                          onTap: () => Navigator.pop(ctx, e),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      );
      if (elegido == null) return;
      await _service.inscribir(
          widget.curso.id, elegido['id'] as String, widget.curso.gestionId);
      _aviso('Estudiante inscrito');
      _cargar();
    } catch (e) {
      if (!mounted) return;
      _aviso('Error: $e', error: true);
    }
  }

  Future<void> _quitarEstudiante(Map<String, dynamic> v) async {
    final est = v['estudiantes'] as Map<String, dynamic>;
    final ok = await _confirmar('¿Quitar a ${_nombreEst(est)} de este curso?');
    if (ok != true) return;
    try {
      await _service.quitarEstudiante(v['id'] as String);
      _cargar();
    } catch (e) {
      if (!mounted) return;
      _aviso('Error: $e', error: true);
    }
  }

  // ---------- Asignar docente ----------
  Future<void> _asignarDocente() async {
    try {
      final docs = await _service.docentesDelColegio(widget.curso.colegioId);
      if (!mounted) return;
      if (docs.isEmpty) {
        _aviso('No hay docentes en este colegio', error: true);
        return;
      }
      String? docenteId;
      final materiaCtrl = TextEditingController();
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => StatefulBuilder(
          builder: (ctx, setD) => AlertDialog(
            title: const Text('Asignar docente'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Docente'),
                  items: docs
                      .map((d) => DropdownMenuItem(
                            value: d['id'] as String,
                            child: Text(
                                (d['usuarios']?['nombre_completo'] ?? 'Sin nombre')
                                    .toString(),
                                overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged: (v) => setD(() => docenteId = v),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: materiaCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Materia', hintText: 'Ej. Matemáticas'),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancelar')),
              TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Asignar')),
            ],
          ),
        ),
      );
      if (ok != true) return;
      if (docenteId == null || materiaCtrl.text.trim().isEmpty) {
        _aviso('Elige un docente y escribe la materia', error: true);
        return;
      }
      await _service.asignarDocente(
          widget.curso.id, docenteId!, materiaCtrl.text.trim());
      _aviso('Docente asignado');
      _cargar();
    } catch (e) {
      if (!mounted) return;
      _aviso('Error: $e', error: true);
    }
  }

  Future<void> _quitarDocente(Map<String, dynamic> v) async {
    final ok = await _confirmar('¿Quitar esta asignación (${v['materia']})?');
    if (ok != true) return;
    try {
      await _service.quitarDocente(v['id'] as String);
      _cargar();
    } catch (e) {
      if (!mounted) return;
      _aviso('Error: $e', error: true);
    }
  }

  Future<void> _alternarGuia(String docenteId) async {
    try {
      final nuevo = _guiaId == docenteId ? null : docenteId;
      await _service.definirGuia(widget.curso.id, nuevo);
      setState(() => _guiaId = nuevo);
      _aviso(nuevo == null ? 'Docente guía quitado' : 'Docente guía definido');
    } catch (e) {
      if (!mounted) return;
      _aviso('Error: $e', error: true);
    }
  }

  Future<bool?> _confirmar(String texto) => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          content: Text(texto),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar')),
            TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Quitar')),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final c = widget.curso;
    return Scaffold(
      backgroundColor: AppColors.grisFondo,
      appBar: AppBar(
        title: Text('${c.nombre} ${c.paralelo ?? ''}'.trim()),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'Estudiantes (${_estudiantes.length})'),
            Tab(text: 'Docentes (${_docentes.length})'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _tab.index == 0 ? _inscribir : _asignarDocente,
        backgroundColor: AppColors.azulPrimario,
        foregroundColor: Colors.white,
        icon: Icon(_tab.index == 0 ? Icons.person_add_alt_1 : Icons.menu_book_rounded),
        label: Text(_tab.index == 0 ? 'Inscribir estudiante' : 'Asignar docente'),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tab,
              children: [_tabEstudiantes(), _tabDocentes()],
            ),
    );
  }

  Widget _vacio(String texto) => Center(
      child: Text(texto, style: GoogleFonts.poppins(color: Colors.grey)));

  Widget _tabEstudiantes() {
    if (_estudiantes.isEmpty) return _vacio('No hay estudiantes inscritos');
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      itemCount: _estudiantes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final v = _estudiantes[i];
        final e = v['estudiantes'] as Map<String, dynamic>;
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.azulClaro,
              child: Text(e['nombres'].toString()[0].toUpperCase(),
                  style: GoogleFonts.poppins(
                      color: AppColors.azulPrimario, fontWeight: FontWeight.bold)),
            ),
            title: Text(_nombreEst(e),
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            subtitle: Text('CI: ${e['ci']}'),
            trailing: IconButton(
              icon: const Icon(Icons.person_remove, color: AppColors.rojoError),
              tooltip: 'Quitar del curso',
              onPressed: () => _quitarEstudiante(v),
            ),
          ),
        );
      },
    );
  }

  Widget _tabDocentes() {
    if (_docentes.isEmpty) return _vacio('No hay docentes asignados');
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      itemCount: _docentes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final v = _docentes[i];
        final docenteId = v['docente_id'] as String;
        final nombre = v['docentes']?['usuarios']?['nombre_completo'] ?? 'Sin nombre';
        final esGuia = _guiaId == docenteId;
        return Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: AppColors.azulClaro,
              child: Icon(Icons.menu_book_rounded, color: AppColors.azulPrimario),
            ),
            title: Text(nombre.toString(),
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            subtitle: Text('${v['materia']}${esGuia ? '\nDocente guía' : ''}'),
            isThreeLine: esGuia,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: esGuia ? 'Quitar como guía' : 'Marcar como guía',
                  icon: Icon(esGuia ? Icons.star : Icons.star_border,
                      color: Colors.amber[700]),
                  onPressed: () => _alternarGuia(docenteId),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.rojoError),
                  onPressed: () => _quitarDocente(v),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}