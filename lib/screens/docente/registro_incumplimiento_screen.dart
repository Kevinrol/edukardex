import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/kardex_service.dart';
import '../../theme/app_theme.dart';

class RegistroIncumplimientoScreen extends StatefulWidget {
  final String estudianteId;
  final String nombre;
  final Map<String, dynamic> curso;
  final String docenteId;
  const RegistroIncumplimientoScreen({
    super.key,
    required this.estudianteId,
    required this.nombre,
    required this.curso,
    required this.docenteId,
  });

  @override
  State<RegistroIncumplimientoScreen> createState() =>
      _RegistroIncumplimientoScreenState();
}

class _RegistroIncumplimientoScreenState
    extends State<RegistroIncumplimientoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = KardexService();
  final _descCtrl = TextEditingController();
  final _accionCtrl = TextEditingController();

  List<Map<String, dynamic>> _tipos = [];
  String? _tipoId;
  String _gravedad = 'leve';
  bool _cargando = true;
  bool _guardando = false;

  static const _gravedades = {
    'leve': 'Leve',
    'grave': 'Grave',
    'muy_grave': 'Muy grave',
  };

  @override
  void initState() {
    super.initState();
    _cargarTipos();
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _accionCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarTipos() async {
    try {
      final t = await _service.tiposFalta();
      if (!mounted) return;
      setState(() {
        _tipos = t;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _cargando = false);
      _aviso('Error al cargar tipos de falta: $e', error: true);
    }
  }

  void _aviso(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? AppColors.rojoError : AppColors.verdeExito,
    ));
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    try {
      final trimestre = await _service.trimestreActual(widget.curso['gestion_id']);
      if (trimestre == null) {
        throw Exception('La gestión de este curso no tiene trimestres.');
      }
      final kardexId = await _service.obtenerOCrearKardex(
        estudianteId: widget.estudianteId,
        cursoId: widget.curso['id'],
        trimestreId: trimestre['id'],
      );
      await _service.registrarIncumplimiento(
        kardexId: kardexId,
        docenteId: widget.docenteId,
        tipoFaltaId: _tipoId,
        descripcion: _descCtrl.text.trim(),
        gravedad: _gravedad,
        accionTomada: _accionCtrl.text.trim().isEmpty ? null : _accionCtrl.text.trim(),
      );
      if (!mounted) return;
      _aviso('Incumplimiento registrado');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _aviso('Error: ${e.toString().replaceAll('Exception: ', '')}', error: true);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grisFondo,
      appBar: AppBar(title: const Text('Registrar incumplimiento')),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.nombre,
                            style: GoogleFonts.poppins(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          decoration:
                              const InputDecoration(labelText: 'Tipo de falta'),
                          items: _tipos
                              .map((t) => DropdownMenuItem(
                                    value: t['id'] as String,
                                    child: Text(t['nombre'],
                                        overflow: TextOverflow.ellipsis),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            final tipo = _tipos.firstWhere((t) => t['id'] == v);
                            setState(() {
                              _tipoId = v;
                              _gravedad = tipo['gravedad_default'];
                            });
                          },
                          validator: (v) => v == null ? 'Elige un tipo de falta' : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _gravedad,
                          decoration: const InputDecoration(labelText: 'Gravedad'),
                          items: _gravedades.entries
                              .map((e) => DropdownMenuItem(
                                  value: e.key, child: Text(e.value)))
                              .toList(),
                          onChanged: (v) => setState(() => _gravedad = v!),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descCtrl,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Descripción *',
                            hintText: 'Qué ocurrió',
                            alignLabelWithHint: true,
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Campo requerido'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _accionCtrl,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Acción tomada',
                            hintText: 'Ej. Llamada de atención verbal',
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _guardando ? null : _guardar,
                            child: _guardando
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white))
                                : Text('REGISTRAR',
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}