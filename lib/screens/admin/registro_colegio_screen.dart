import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../../models/colegio.dart';
import '../../services/colegio_service.dart';
import '../../theme/app_theme.dart';

class RegistroColegioScreen extends StatefulWidget {
  const RegistroColegioScreen({super.key});

  @override
  State<RegistroColegioScreen> createState() => _RegistroColegioScreenState();
}

class _RegistroColegioScreenState extends State<RegistroColegioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = ColegioService();
  bool _guardando = false;

  final _nombreCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _directorCtrl = TextEditingController();

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _direccionCtrl.dispose();
    _telefonoCtrl.dispose();
    _directorCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);

    final colegio = Colegio(
      id: const Uuid().v4(),
      nombre: _nombreCtrl.text.trim(),
      direccion: _direccionCtrl.text.trim(),
      telefono: _telefonoCtrl.text.trim(),
      directorNombre: _directorCtrl.text.trim(),
      createdAt: DateTime.now(),
    );

    try {
      await _service.agregar(colegio);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Colegio registrado exitosamente'),
          backgroundColor: AppColors.verdeExito,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
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
            // 1. Header Azul
            Container(
              height: 220,
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 16,
                right: 16,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF3B82F6),
              ),
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
                      child: Image.asset(
                        'lib/assets/logo_edukardex.png',
                        height: 90,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Card Blanca
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
                  padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Registrar Colegio',
                                    style: GoogleFonts.poppins(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1C2F57),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Ingresa los datos del colegio',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.azulClaro,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.school_rounded,
                                size: 28,
                                color: AppColors.azulPrimario,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        _buildCustomInput(
                          controller: _nombreCtrl,
                          label: 'Nombre del colegio *',
                          hint: 'Ej. Unidad Educativa 6 de Junio',
                          icon: Icons.account_balance,
                          required: true,
                        ),
                        const SizedBox(height: 16),

                        _buildCustomInput(
                          controller: _direccionCtrl,
                          label: 'Dirección',
                          hint: 'Ej. Av. Principal #123',
                          icon: Icons.location_on,
                        ),
                        const SizedBox(height: 16),

                        _buildCustomInput(
                          controller: _telefonoCtrl,
                          label: 'Teléfono',
                          hint: 'Ej. 76543210',
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),

                        _buildCustomInput(
                          controller: _directorCtrl,
                          label: 'Director/a',
                          hint: 'Ej. Lic. Juan Perez',
                          icon: Icons.person,
                        ),
                        const SizedBox(height: 32),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: _guardando ? null : _guardar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            icon: _guardando
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Icon(Icons.save_rounded),
                            label: Text(
                              _guardando ? 'GUARDANDO...' : 'GUARDAR COLEGIO',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15),
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
                              foregroundColor: const Color(0xFF2563EB),
                              side: const BorderSide(color: Color(0xFF93C5FD), width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'CANCELAR',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
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

  Widget _buildCustomInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool required = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.grisTexto,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF2563EB),
                size: 22,
              ),
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
                  keyboardType: keyboardType,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: GoogleFonts.poppins(color: const Color(0xFF94A3B8), fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  validator: required
                      ? (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Campo requerido';
                          }
                          return null;
                        }
                      : null,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
