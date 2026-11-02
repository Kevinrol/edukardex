import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/docente_service.dart';
import '../../theme/app_theme.dart';

class RegistroDocenteScreen extends StatefulWidget {
  final String colegioId;
  const RegistroDocenteScreen({super.key, required this.colegioId});

  @override
  State<RegistroDocenteScreen> createState() => _RegistroDocenteScreenState();
}

class _RegistroDocenteScreenState extends State<RegistroDocenteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = DocenteService();
  bool _guardando = false;

  final _nombreCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _itemCodigoCtrl = TextEditingController();
  final _especialidadCtrl = TextEditingController();
  final _tipoContratoCtrl = TextEditingController();

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _telefonoCtrl.dispose();
    _itemCodigoCtrl.dispose();
    _especialidadCtrl.dispose();
    _tipoContratoCtrl.dispose();
    super.dispose();
  }

  String? _n(String s) => s.trim().isEmpty ? null : s.trim();

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    try {
      await _service.crearConUsuario(
        colegioId: widget.colegioId,
        nombreCompleto: _nombreCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        telefono: _n(_telefonoCtrl.text),
        itemCodigo: _n(_itemCodigoCtrl.text),
        especialidad: _n(_especialidadCtrl.text),
        tipoContrato: _n(_tipoContratoCtrl.text),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Docente registrado exitosamente'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SizedBox.expand(
        child: Stack(
          children: [
            Container(
              height: 220,
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 16,
                right: 16,
              ),
              color: const Color(0xFF3B82F6),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Image.asset('assets/logo_horizontal.png',
                          height: 50, fit: BoxFit.contain),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 140,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Registrar Docente',
                            style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.grisTexto)),
                        Text('Se creará su cuenta para iniciar sesión',
                            style: GoogleFonts.poppins(
                                fontSize: 13, color: Colors.grey[600])),
                        const SizedBox(height: 24),
                        _campo(_nombreCtrl, 'Nombre completo *', 'Ej. María Pérez López',
                            Icons.person_rounded,
                            validator: _requerido),
                        _campo(_emailCtrl, 'Correo electrónico *', 'docente@colegio.com',
                            Icons.email_rounded,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Campo requerido';
                              if (!v.contains('@') || !v.contains('.')) return 'Correo no válido';
                              return null;
                            }),
                        _campo(_passCtrl, 'Contraseña *', 'Mínimo 6 caracteres',
                            Icons.lock_rounded,
                            obscure: true,
                            validator: (v) => (v == null || v.length < 6)
                                ? 'Mínimo 6 caracteres'
                                : null),
                        _campo(_telefonoCtrl, 'Teléfono', 'Ej. 70000000',
                            Icons.phone_rounded,
                            keyboardType: TextInputType.phone),
                        _campo(_itemCodigoCtrl, 'Código de Ítem', 'Ej. ITM-2026',
                            Icons.tag),
                        _campo(_especialidadCtrl, 'Especialidad', 'Ej. Matemáticas',
                            Icons.science),
                        _campo(_tipoContratoCtrl, 'Tipo de Contrato', 'Ej. Planta',
                            Icons.description),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: _guardando ? null : _guardar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEA580C),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: _guardando
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2))
                                : const Icon(Icons.person_add_rounded),
                            label: Text(
                              _guardando ? 'GUARDANDO...' : 'REGISTRAR DOCENTE',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFEA580C),
                              side: const BorderSide(
                                  color: Color(0xFFFDBA74), width: 1.5),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text('CANCELAR',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold, fontSize: 15)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _requerido(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Campo requerido' : null;

  Widget _campo(
    TextEditingController controller,
    String label,
    String hint,
    IconData icon, {
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grisTexto)),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFFEA580C), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextFormField(
                    controller: controller,
                    obscureText: obscure,
                    keyboardType: keyboardType,
                    validator: validator,
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: GoogleFonts.poppins(
                          color: const Color(0xFF94A3B8), fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}