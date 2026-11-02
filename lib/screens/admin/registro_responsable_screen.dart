import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/responsable_service.dart';
import '../../theme/app_theme.dart';

class RegistroResponsableScreen extends StatefulWidget {
  final String colegioId;
  final String estudianteId;
  const RegistroResponsableScreen({
    super.key,
    required this.colegioId,
    required this.estudianteId,
  });

  @override
  State<RegistroResponsableScreen> createState() => _RegistroResponsableScreenState();
}

class _RegistroResponsableScreenState extends State<RegistroResponsableScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = ResponsableService();
  bool _guardando = false;

  final _nombreCtrl = TextEditingController();
  final _ciCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String? _parentesco;

  static const _parentescos = ['Padre', 'Madre', 'Tutor', 'Abuelo/a', 'Tío/a', 'Hermano/a', 'Otro'];

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _ciCtrl.dispose();
    _telefonoCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    try {
      await _service.crearConUsuarioYVincular(
        colegioId: widget.colegioId,
        estudianteId: widget.estudianteId,
        nombreCompleto: _nombreCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        telefono: _telefonoCtrl.text.trim(),
        ci: _ciCtrl.text.trim().isEmpty ? null : _ciCtrl.text.trim(),
        parentesco: _parentesco,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Responsable registrado y vinculado'),
          backgroundColor: AppColors.verdeExito,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: AppColors.rojoError,
        ),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  InputDecoration _deco(String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar responsable')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nombreCtrl,
                    decoration: _deco('Nombre completo *', Icons.person_rounded),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: _parentesco,
                    decoration: _deco('Parentesco', Icons.family_restroom_rounded),
                    items: _parentescos
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (v) => setState(() => _parentesco = v),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _ciCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _deco('Cédula de identidad', Icons.credit_card_rounded),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _telefonoCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: _deco('Teléfono *', Icons.phone_rounded),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _deco('Correo electrónico (para su login) *', Icons.email_rounded),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Campo requerido';
                      if (!v.contains('@') || !v.contains('.')) return 'Correo no válido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: true,
                    decoration: _deco('Contraseña *', Icons.lock_rounded),
                    validator: (v) => (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _guardando ? null : _guardar,
                      child: _guardando
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text('REGISTRAR RESPONSABLE',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
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