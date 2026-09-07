import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/colegio.dart';
import '../../models/gestion_academica.dart';
import '../../models/curso.dart';
import '../../services/gestion_service.dart';
import '../../services/curso_service.dart';
import '../../theme/app_theme.dart';
import 'registro_gestion_screen.dart';
import 'registro_curso_screen.dart';

class ColegioDetailScreen extends StatefulWidget {
  final Colegio colegio;
  const ColegioDetailScreen({super.key, required this.colegio});

  @override
  State<ColegioDetailScreen> createState() => _ColegioDetailScreenState();
}

class _ColegioDetailScreenState extends State<ColegioDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _gestionService = GestionService();
  final _cursoService = CursoService();
  
  List<GestionAcademica> _gestiones = [];
  List<Curso> _cursos = [];
  bool _cargandoGestiones = true;
  bool _cargandoCursos = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Para reconstruir el FAB basado en el tab activo
    });
    _cargarDatos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    _cargarGestiones();
    _cargarCursos();
  }

  Future<void> _cargarGestiones() async {
    setState(() => _cargandoGestiones = true);
    try {
      final list = await _gestionService.listarPorColegio(widget.colegio.id);
      if (!mounted) return;
      setState(() {
        _gestiones = list;
        _cargandoGestiones = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _cargandoGestiones = false);
    }
  }

  Future<void> _cargarCursos() async {
    setState(() => _cargandoCursos = true);
    try {
      final list = await _cursoService.listarPorColegio(widget.colegio.id);
      if (!mounted) return;
      setState(() {
        _cursos = list;
        _cargandoCursos = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _cargandoCursos = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grisFondo,
      appBar: AppBar(
        title: Text(widget.colegio.nombre),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Gestiones'),
            Tab(text: 'Cursos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTabGestiones(),
          _buildTabCursos(),
        ],
      ),
      floatingActionButton: _buildFab(),
    );
  }

  Widget? _buildFab() {
    if (_tabController.index == 0) {
      return FloatingActionButton.extended(
        heroTag: 'fab_gestion',
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RegistroGestionScreen(colegioId: widget.colegio.id),
            ),
          );
          _cargarGestiones();
        },
        backgroundColor: AppColors.azulPrimario,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.calendar_month_rounded),
        label: Text('Nueva Gestión', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      );
    } else if (_tabController.index == 1) {
      return FloatingActionButton.extended(
        heroTag: 'fab_curso',
        onPressed: () async {
          // Solo permitir si hay gestiones activas
          if (_gestiones.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Debe crear una gestión académica primero')),
            );
            return;
          }
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RegistroCursoScreen(
                colegioId: widget.colegio.id,
                gestiones: _gestiones,
              ),
            ),
          );
          _cargarCursos();
        },
        backgroundColor: AppColors.azulPrimario,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.class_rounded),
        label: Text('Nuevo Curso', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      );
    }
    return null;
  }

  Widget _buildTabGestiones() {
    if (_cargandoGestiones) return const Center(child: CircularProgressIndicator());
    if (_gestiones.isEmpty) return _buildEmpty('No hay gestiones', Icons.calendar_today_rounded);

    return RefreshIndicator(
      onRefresh: _cargarGestiones,
      child: ListView.separated(
        padding: const EdgeInsets.all(16).copyWith(bottom: 100),
        itemCount: _gestiones.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final g = _gestiones[index];
          return Card(
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.azulClaro,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  g.anio.toString(),
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.azulPrimario),
                ),
              ),
              title: Text('Gestión ${g.anio}', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              subtitle: Text(
                '${g.fechaInicio.toLocal().toString().split(' ')[0]} - ${g.fechaFin.toLocal().toString().split(' ')[0]}',
                style: GoogleFonts.poppins(fontSize: 12),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: g.activa ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  g.activa ? 'Activa' : 'Cerrada',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: g.activa ? AppColors.verdeOscuro : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabCursos() {
    if (_cargandoCursos) return const Center(child: CircularProgressIndicator());
    if (_cursos.isEmpty) return _buildEmpty('No hay cursos', Icons.class_rounded);

    return RefreshIndicator(
      onRefresh: _cargarCursos,
      child: ListView.separated(
        padding: const EdgeInsets.all(16).copyWith(bottom: 100),
        itemCount: _cursos.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final c = _cursos[index];
          // Buscar año de la gestión
          final gestion = _gestiones.where((g) => g.id == c.gestionId).firstOrNull;
          final anio = gestion?.anio.toString() ?? '?';

          return Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.azulClaro,
                child: Icon(Icons.class_rounded, color: AppColors.azulPrimario),
              ),
              title: Text('${c.nombre} ${c.paralelo ?? ''}'.trim(), style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              subtitle: Text('Nivel: ${c.nivel ?? '-'} | Gestión $anio', style: GoogleFonts.poppins(fontSize: 12)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmpty(String text, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(text, style: GoogleFonts.poppins(color: Colors.grey)),
        ],
      ),
    );
  }
}
