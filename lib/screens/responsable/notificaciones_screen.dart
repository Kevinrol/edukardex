import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/responsable_portal_service.dart';
import '../../theme/app_theme.dart';

class NotificacionesScreen extends StatefulWidget {
  final String responsableId;
  const NotificacionesScreen({super.key, required this.responsableId});

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
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
      final n = await _service.notificaciones(widget.responsableId);
      if (!mounted) return;
      setState(() {
        _items = n;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _cargando = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grisFondo,
      appBar: AppBar(title: const Text('Notificaciones')),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(
                  child: Text('No tienes notificaciones',
                      style: GoogleFonts.poppins(color: Colors.grey)))
              : RefreshIndicator(
                  onRefresh: _cargar,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final n = _items[i];
                      final inc = n['incumplimientos'] as Map<String, dynamic>?;
                      final est = inc?['kardex']?['estudiantes'];
                      final nombreEst = est == null
                          ? ''
                          : '${est['nombres']} ${est['apellido_paterno']}';
                      return Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.azulClaro,
                            child: Icon(Icons.notifications_active_rounded,
                                color: AppColors.azulPrimario),
                          ),
                          title: Text(
                              '$nombreEst: ${inc?['tipos_falta']?['nombre'] ?? 'Incumplimiento'}',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                          subtitle: Text('${inc?['descripcion'] ?? ''}\n${inc?['fecha'] ?? ''}'),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}