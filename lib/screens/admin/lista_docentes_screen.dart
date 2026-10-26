import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/docente.dart';
import '../../services/docente_service.dart';
import '../../theme/app_theme.dart';

class ListaDocentesScreen extends StatefulWidget {
  final String colegioId;
  const ListaDocentesScreen({super.key, required this.colegioId});

  @override
  State<ListaDocentesScreen> createState() => _ListaDocentesScreenState();
}

class _ListaDocentesScreenState extends State<ListaDocentesScreen> {
  final _service = DocenteService();
  List<Docente> _docentes = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    try {
      final lista = await _service.listarPorColegio(widget.colegioId);
      if (!mounted) return;
      setState(() {
        _docentes = lista;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _cargando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Docentes')),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _docentes.isEmpty
              ? Center(
                  child: Text(
                    'No hay docentes en este colegio',
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _cargar,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _docentes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final d = _docentes[i];
                      return Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.azulClaro,
                            child: Icon(
                              Icons.menu_book_rounded,
                              color: AppColors.azulPrimario,
                            ),
                          ),
                          title: Text(
                            d.especialidad ?? 'Sin especialidad',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            'Ítem: ${d.itemCodigo ?? '-'} | Contrato: ${d.tipoContrato ?? '-'}',
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}