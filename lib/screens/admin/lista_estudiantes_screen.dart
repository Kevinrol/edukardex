import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/estudiante.dart';
import '../../services/estudiante_service.dart';
import '../../theme/app_theme.dart';
import 'registro_estudiante_screen.dart';

class ListaEstudiantesScreen extends StatefulWidget {
  const ListaEstudiantesScreen({super.key});

  @override
  State<ListaEstudiantesScreen> createState() => _ListaEstudiantesScreenState();
}

class _ListaEstudiantesScreenState extends State<ListaEstudiantesScreen> {
  final _service = EstudianteService();
  List<Estudiante> _todos = [];
  List<Estudiante> _filtrados = [];
  bool _cargando = true;
  final _busquedaCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final estudiantes = await _service.listar();
    estudiantes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    setState(() {
      _todos = estudiantes;
      _filtrados = estudiantes;
      _cargando = false;
    });
  }

  void _filtrar(String query) {
    final q = query.toLowerCase().trim();
    setState(() {
      _filtrados = q.isEmpty
          ? _todos
          : _todos
              .where((e) =>
                  e.nombreCompleto.toLowerCase().contains(q) ||
                  e.ci.toLowerCase().contains(q))
              .toList();
    });
  }

  Future<void> _eliminar(Estudiante e) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar registro'),
        content: Text('¿Eliminar a ${e.nombreCompleto} del sistema?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Eliminar', style: GoogleFonts.poppins(color: AppColors.rojoError)),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      await _service.eliminar(e.id);
      _cargar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estudiantes Registrados')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RegistroEstudianteScreen()),
          );
          _cargar();
        },
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Nuevo estudiante'),
        backgroundColor: AppColors.azulPrimario,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _busquedaCtrl,
              onChanged: _filtrar,
              decoration: const InputDecoration(
                hintText: 'Buscar por nombre, CI o curso...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : _filtrados.isEmpty
                    ? _estadoVacio()
                    : RefreshIndicator(
                        onRefresh: _cargar,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                          itemCount: _filtrados.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, i) => _tarjetaEstudiante(_filtrados[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _estadoVacio() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.school_outlined, size: 64, color: AppColors.grisBorde),
            const SizedBox(height: 16),
            Text(
              _todos.isEmpty
                  ? 'Aún no hay estudiantes registrados'
                  : 'Sin resultados para tu búsqueda',
              style: GoogleFonts.poppins(color: AppColors.grisTexto, fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _tarjetaEstudiante(Estudiante e) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.azulClaro,
          child: Text(
            e.nombres.isNotEmpty ? e.nombres[0].toUpperCase() : '?',
            style: GoogleFonts.poppins(color: AppColors.azulPrimario, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(e.nombreCompleto, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        subtitle: Text('CI: ${e.ci}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: AppColors.rojoError),
          onPressed: () => _eliminar(e),
        ),
      ),
    );
  }
}
