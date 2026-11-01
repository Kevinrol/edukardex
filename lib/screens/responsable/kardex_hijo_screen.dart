import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/responsable_portal_service.dart';
import '../../theme/app_theme.dart';

class KardexHijoScreen extends StatefulWidget {
  final String estudianteId;
  final String nombre;
  const KardexHijoScreen({super.key, required this.estudianteId, required this.nombre});

  @override
  State<KardexHijoScreen> createState() => _KardexHijoScreenState();
}

class _KardexHijoScreenState extends State<KardexHijoScreen> {
  final _service = ResponsablePortalService();
  List<Map<String, dynamic>> _items = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final k = await _service.kardexDelHijo(widget.estudianteId);
      if (!mounted) return;
      setState(() {
        _items = k;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _cargando = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Color _color(String g) => g == 'muy_grave'
      ? AppColors.rojoError
      : g == 'grave'
          ? Colors.orange[800]!
          : Colors.amber[800]!;

  String _etiqueta(String g) =>
      g == 'muy_grave' ? 'Muy grave' : g == 'grave' ? 'Grave' : 'Leve';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grisFondo,
      appBar: AppBar(title: Text('Kardex: ${widget.nombre}')),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(
                  child: Text('Sin incumplimientos registrados',
                      style: GoogleFonts.poppins(color: Colors.grey)))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final it = _items[i];
                    final g = it['gravedad'] as String;
                    return Card(
                      child: ListTile(
                        leading: Icon(Icons.warning_amber_rounded, color: _color(g)),
                        title: Text(it['tipos_falta']?['nombre'] ?? 'Sin tipo',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          '${it['descripcion']}\n'
                          '${it['accion_tomada'] != null ? 'Acción: ${it['accion_tomada']}\n' : ''}'
                          '${it['curso']} | T${it['trimestre']} | ${it['fecha']}',
                        ),
                        isThreeLine: true,
                        trailing: Text(_etiqueta(g),
                            style: GoogleFonts.poppins(
                                color: _color(g),
                                fontWeight: FontWeight.w600,
                                fontSize: 12)),
                      ),
                    );
                  },
                ),
    );
  }
}