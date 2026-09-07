import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import 'registro_estudiante_screen.dart';
import 'registro_colegio_screen.dart';

/// Pantalla de selección: ¿Registrarse como Estudiante, Docente o Colegio?
class SeleccionRegistroScreen extends StatelessWidget {
  const SeleccionRegistroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blanco,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _header(),
              const SizedBox(height: 36),
              _buildIlustration(),
              const SizedBox(height: 32),
              _buildTitle(),
              const SizedBox(height: 28),
              _buildGrid(context),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────
  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: const BoxDecoration(
        color: AppColors.azulPrimario,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.school_rounded, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'EduKardex',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                'Control académico fácil y rápido',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Ilustración central ─────────────────────────────────────────────
  Widget _buildIlustration() {
    return SizedBox(
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Círculo fondo decorativo
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.azulClaro.withValues(alpha: 0.5),
            ),
          ),
          // Íconos decorativos apilados
          Positioned(
            top: 10,
            left: 60,
            child: _deco(Icons.auto_stories_rounded, AppColors.naranjaAlerta, 38),
          ),
          Positioned(
            bottom: 10,
            right: 65,
            child: _deco(Icons.people_alt_rounded, AppColors.verdePrimario, 34),
          ),
          Positioned(
            top: 30,
            right: 55,
            child: _deco(Icons.emoji_events_rounded, AppColors.azulSecundario, 30),
          ),
          // Ícono central principal
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.azulPrimario,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.azulPrimario.withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.school_rounded, color: Colors.white, size: 44),
          ),
        ],
      ),
    );
  }

  Widget _deco(IconData icon, Color color, double size) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: size),
    );
  }

  // ── Título ──────────────────────────────────────────────────────────
  Widget _buildTitle() {
    return Text(
      'Regístrese como:',
      style: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.grisTexto,
        letterSpacing: 0.2,
      ),
    );
  }

  // ── Grid de opciones ─────────────────────────────────────────────────
  Widget _buildGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Fila superior: Estudiante | Docente
          Row(
            children: [
              Expanded(
                child: _RegistroCard(
                  icon: Icons.face_rounded,
                  label: 'Estudiante',
                  color: AppColors.azulSecundario,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RegistroEstudianteScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _RegistroCard(
                  icon: Icons.front_hand_rounded,
                  label: 'Docente',
                  color: AppColors.verdePrimario,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Registro de Docente próximamente',
                          style: GoogleFonts.poppins(),
                        ),
                        backgroundColor: AppColors.verdePrimario,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Fila inferior: Colegio (centrado)
          SizedBox(
            width: (MediaQuery.of(context).size.width - 48) / 2,
            child: _RegistroCard(
              icon: Icons.apartment_rounded,
              label: 'Colegio',
              color: AppColors.naranjaAlerta,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RegistroColegioScreen(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Card de selección ────────────────────────────────────────────────────
class _RegistroCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _RegistroCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_RegistroCard> createState() => _RegistroCardState();
}

class _RegistroCardState extends State<_RegistroCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _ctrl.reverse();
  void _onTapUp(_) {
    _ctrl.forward();
    widget.onTap();
  }
  void _onTapCancel() => _ctrl.forward();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 12),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, color: Colors.white, size: 36),
              ),
              const SizedBox(height: 14),
              Text(
                widget.label,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
