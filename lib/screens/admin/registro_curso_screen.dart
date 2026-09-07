import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/curso.dart';
import '../../models/gestion_academica.dart';
import '../../services/curso_service.dart';
import '../../theme/app_theme.dart';

class RegistroCursoScreen extends StatefulWidget {
  final String colegioId;
  final List<GestionAcademica> gestiones;

  const RegistroCursoScreen({
    super.key,
    required this.colegioId,
    required this.gestiones,
  });

  @override
  State<RegistroCursoScreen> createState() => _RegistroCursoScreenState();
}

class _RegistroCursoScreenState extends State<RegistroCursoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = CursoService();
  bool _guardando = false;

  final _nombreCtrl = TextEditingController();
  final _paraleloCtrl = TextEditingController();
  String? _nivelSeleccionado;
  String? _gestionIdSeleccionada;

  final List<String> _niveles = ['Inicial', 'Primaria', 'Secundaria'];

  @override
  void initState() {
    super.initState();
    // Seleccionar por defecto la gestión activa más reciente
    if (widget.gestiones.isNotEmpty) {
      final activas = widget.gestiones.where((g) => g.activa).toList();
      if (activas.isNotEmpty) {
        _gestionIdSeleccionada = activas.first.id;
      } else {
        _gestionIdSeleccionada = widget.gestiones.first.id;
      }
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _paraleloCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_gestionIdSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seleccione una gestión')));
      return;
    }

    setState(() => _guardando = true);

    final curso = Curso(
      id: const Uuid().v4(),
      colegioId: widget.colegioId,
      gestionId: _gestionIdSeleccionada!,
      nombre: _nombreCtrl.text.trim(),
      paralelo: _paraleloCtrl.text.trim().isEmpty ? null : _paraleloCtrl.text.trim().toUpperCase(),
      nivel: _nivelSeleccionado,
      createdAt: DateTime.now(),
    );

    try {
      await _service.agregar(curso);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Curso guardado exitosamente'), backgroundColor: AppColors.verdeExito),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.rojoError),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grisFondo,
      appBar: AppBar(title: const Text('Nuevo Curso')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _gestionIdSeleccionada,
                decoration: const InputDecoration(labelText: 'Gestión Académica'),
                items: widget.gestiones.map((g) {
                  return DropdownMenuItem(
                    value: g.id,
                    child: Text(
                      'Gestión ${g.anio} ${g.activa ? "(Activa)" : "(Cerrada)"}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _gestionIdSeleccionada = val),
                validator: (val) => val == null ? 'Seleccione una gestión' : null,
              ),
              const SizedBox(height: 20),
              
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Curso',
                  hintText: 'Ej. 1ro de Secundaria, Kínder...',
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 20),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _paraleloCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Paralelo',
                        hintText: 'A, B, C...',
                      ),
                      textCapitalization: TextCapitalization.characters,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _nivelSeleccionado,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Nivel'),
                      items: _niveles.map((n) => DropdownMenuItem(
                        value: n,
                        child: Text(n, overflow: TextOverflow.ellipsis),
                      )).toList(),
                      onChanged: (val) => setState(() => _nivelSeleccionado = val),
                      validator: (val) => val == null ? 'Requerido' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _guardando ? null : _guardar,
                  icon: _guardando ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.save),
                  label: Text(_guardando ? 'Guardando...' : 'Guardar Curso'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
