import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../../models/gestion_academica.dart';
import '../../models/trimestre.dart';
import '../../services/gestion_service.dart';
import '../../theme/app_theme.dart';

class RegistroGestionScreen extends StatefulWidget {
  final String colegioId;
  const RegistroGestionScreen({super.key, required this.colegioId});

  @override
  State<RegistroGestionScreen> createState() => _RegistroGestionScreenState();
}

class _RegistroGestionScreenState extends State<RegistroGestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = GestionService();
  bool _guardando = false;

  final _anioCtrl = TextEditingController(text: DateTime.now().year.toString());
  DateTime? _fechaInicioGestion;
  DateTime? _fechaFinGestion;

  // Fechas de los 3 trimestres
  final List<DateTime?> _iniciosTrimestre = [null, null, null];
  final List<DateTime?> _finesTrimestre = [null, null, null];

  @override
  void dispose() {
    _anioCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha(BuildContext context, DateTime? inicial, Function(DateTime) onSeleccion) async {
    final seleccion = await showDatePicker(
      context: context,
      initialDate: inicial ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (seleccion != null) {
      onSeleccion(seleccion);
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_fechaInicioGestion == null || _fechaFinGestion == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Debe seleccionar las fechas de la gestión')));
      return;
    }

    if (_iniciosTrimestre.contains(null) || _finesTrimestre.contains(null)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Debe completar las fechas de todos los trimestres')));
      return;
    }

    setState(() => _guardando = true);

    final gestionId = const Uuid().v4();
    final anio = int.tryParse(_anioCtrl.text) ?? DateTime.now().year;

    final gestion = GestionAcademica(
      id: gestionId,
      colegioId: widget.colegioId,
      anio: anio,
      fechaInicio: _fechaInicioGestion!,
      fechaFin: _fechaFinGestion!,
      activa: true,
      createdAt: DateTime.now(),
    );

    final trimestres = [
      Trimestre(id: const Uuid().v4(), gestionId: gestionId, numero: 1, fechaInicio: _iniciosTrimestre[0]!, fechaFin: _finesTrimestre[0]!),
      Trimestre(id: const Uuid().v4(), gestionId: gestionId, numero: 2, fechaInicio: _iniciosTrimestre[1]!, fechaFin: _finesTrimestre[1]!),
      Trimestre(id: const Uuid().v4(), gestionId: gestionId, numero: 3, fechaInicio: _iniciosTrimestre[2]!, fechaFin: _finesTrimestre[2]!),
    ];

    try {
      await _service.agregar(gestion);
      await _service.agregarTrimestres(trimestres);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gestión creada exitosamente'), backgroundColor: AppColors.verdeExito));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.rojoError));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grisFondo,
      appBar: AppBar(
        title: const Text('Nueva Gestión Académica'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _anioCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Año Lectivo',
                  icon: Icon(Icons.calendar_today_rounded),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 20),
              
              Row(
                children: [
                  Expanded(
                    child: _buildDatePicker(
                      label: 'Inicio de Gestión',
                      fecha: _fechaInicioGestion,
                      onTap: () => _seleccionarFecha(context, _fechaInicioGestion, (f) => setState(() => _fechaInicioGestion = f)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDatePicker(
                      label: 'Fin de Gestión',
                      fecha: _fechaFinGestion,
                      onTap: () => _seleccionarFecha(context, _fechaFinGestion, (f) => setState(() => _fechaFinGestion = f)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              Text('Trimestres', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.azulPrimario)),
              const SizedBox(height: 16),
              
              for (int i = 0; i < 3; i++) ...[
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Trimestre ${i + 1}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDatePicker(
                                label: 'Inicio',
                                fecha: _iniciosTrimestre[i],
                                onTap: () => _seleccionarFecha(context, _iniciosTrimestre[i], (f) => setState(() => _iniciosTrimestre[i] = f)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildDatePicker(
                                label: 'Fin',
                                fecha: _finesTrimestre[i],
                                onTap: () => _seleccionarFecha(context, _finesTrimestre[i], (f) => setState(() => _finesTrimestre[i] = f)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _guardando ? null : _guardar,
                  icon: _guardando ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.save),
                  label: Text(_guardando ? 'Guardando...' : 'Guardar Gestión'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker({required String label, required DateTime? fecha, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: Text(
          fecha != null ? "${fecha.day}/${fecha.month}/${fecha.year}" : 'Seleccionar',
          style: GoogleFonts.poppins(color: fecha != null ? AppColors.grisTexto : Colors.grey),
        ),
      ),
    );
  }
}
