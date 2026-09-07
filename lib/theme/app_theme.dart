import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Identidad visual EduKardex: azul institucional #1c2f57, tipografía Poppins.
class AppColors {
  static const azulPrimario    = Color(0xFF1c2f57);
  static const azulSecundario  = Color(0xFF2B4A8F);
  static const azulClaro       = Color(0xFFEAF1FB);
  static const verdePrimario   = Color(0xFF22C55E);
  static const verdeOscuro     = Color(0xFF16A34A);
  static const verdeExito      = Color(0xFF2E9E5B);
  static const naranjaAlerta   = Color(0xFFF97316);
  static const naranjaClaro    = Color(0xFFFFF7ED);
  static const rojoError       = Color(0xFFD1483B);
  static const grisTexto       = Color(0xFF1c2f57);   // color global de fuente
  static const grisFondo       = Color(0xFFF5F7FA);
  static const grisBorde       = Color(0xFFDDE2E8);
  static const blanco          = Colors.white;
}

class AppTheme {
  static ThemeData get theme {
    final base = GoogleFonts.poppinsTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.grisFondo,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.azulPrimario,
        primary: AppColors.azulPrimario,
        error: AppColors.rojoError,
      ),

      // ── Tipografía global: Poppins + color #1c2f57 ──────────────────
      textTheme: base.copyWith(
        displayLarge : base.displayLarge?.copyWith(color: AppColors.grisTexto, fontWeight: FontWeight.bold),
        displayMedium: base.displayMedium?.copyWith(color: AppColors.grisTexto, fontWeight: FontWeight.bold),
        displaySmall : base.displaySmall?.copyWith(color: AppColors.grisTexto, fontWeight: FontWeight.bold),
        headlineLarge: base.headlineLarge?.copyWith(color: AppColors.grisTexto, fontWeight: FontWeight.bold),
        headlineMedium: base.headlineMedium?.copyWith(color: AppColors.grisTexto, fontWeight: FontWeight.w700),
        headlineSmall: base.headlineSmall?.copyWith(color: AppColors.grisTexto, fontWeight: FontWeight.w700),
        titleLarge   : base.titleLarge?.copyWith(color: AppColors.grisTexto, fontWeight: FontWeight.bold),
        titleMedium  : base.titleMedium?.copyWith(color: AppColors.grisTexto, fontWeight: FontWeight.w600),
        titleSmall   : base.titleSmall?.copyWith(color: AppColors.grisTexto, fontWeight: FontWeight.w600),
        bodyLarge    : base.bodyLarge?.copyWith(color: AppColors.grisTexto),
        bodyMedium   : base.bodyMedium?.copyWith(color: AppColors.grisTexto),
        bodySmall    : base.bodySmall?.copyWith(color: AppColors.grisTexto),
        labelLarge   : base.labelLarge?.copyWith(color: AppColors.grisTexto, fontWeight: FontWeight.w600),
        labelMedium  : base.labelMedium?.copyWith(color: AppColors.grisTexto),
        labelSmall   : base.labelSmall?.copyWith(color: AppColors.grisTexto),
      ),

      // ── AppBar ───────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.azulPrimario,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),

      // ── Inputs ───────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.grisBorde),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.grisBorde),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.azulPrimario, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.rojoError),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        labelStyle: GoogleFonts.poppins(color: AppColors.grisTexto),
        hintStyle: GoogleFonts.poppins(color: const Color(0xFF94A3B8)),
      ),

      // ── ElevatedButton ───────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.azulPrimario,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),

      // ── Cards ────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.grisBorde),
        ),
      ),
    );
  }
}
