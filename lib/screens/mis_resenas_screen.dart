import 'package:flutter/material.dart';
import 'package:tucu_free_tacc/services/resena_service.dart';

class MisResenasScreen extends StatefulWidget {
  const MisResenasScreen({super.key});

  @override
  State<MisResenasScreen> createState() => _MisResenasScreenState();
}

class _MisResenasScreenState extends State<MisResenasScreen> {
  final ResenaService _resenaService = ResenaService();
  List<dynamic> _todasLasResenas = [];
  bool _cargando = true;
  String _filtroSeleccionado = 'Todas'; // 'Todas', 'Restaurantes', 'Tiendas'

  @override
  void initState() {
    super.initState();
    _cargarMisResenas();
  }

  Future<void> _cargarMisResenas() async {
    final datos = await _resenaService.obtenerPorUsuario();
    if (!mounted) return;
    setState(() {
      _todasLasResenas = datos;
      _cargando = false;
    });
  }

  String _formatearFecha(String? fechaIso) {
    if (fechaIso == null) return 'Reciente';
    final fecha = DateTime.tryParse(fechaIso);
    if (fecha == null) return 'Reciente';
    final diferencia = DateTime.now().toUtc().difference(fecha);

    if (diferencia.inDays == 0) return 'Hoy';
    if (diferencia.inDays == 1) return 'Ayer';
    if (diferencia.inDays < 7) return 'Hace ${diferencia.inDays} días';
    if (diferencia.inDays < 30)
      return 'Hace ${(diferencia.inDays / 7).floor()} semanas';
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E1E1E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'SMT Libre de Gluten',
          style: TextStyle(
            color: Color(0xFF0056D2),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0056D2)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderResumen(),
                  const SizedBox(height: 20),
                  _buildFiltros(),
                  const SizedBox(height: 20),
                  if (_todasLasResenas.isEmpty)
                    _buildEstadoVacio()
                  else
                    ..._todasLasResenas.map((r) => _buildTarjetaMiResena(r)),
                  const SizedBox(height: 20),
                  _buildBannerNuevoLugar(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderResumen() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          const Text(
            'Reseñas',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Text(
                  _todasLasResenas.length.toString(),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0056D2),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Reseñas',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFEDF3FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.volunteer_activism_outlined,
                  color: Color(0xFF0056D2),
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Tus valoraciones han ayudado a muchos celíacos a comer seguros este mes.',
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF003E9A),
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltros() {
    final filtros = [
      'Todas (${_todasLasResenas.length})',
      'Restaurantes',
      'Tiendas',
    ];

    return Row(
      children: filtros.map((filtroTexto) {
        final esTodas = filtroTexto.startsWith('Todas');
        final valorClave = esTodas ? 'Todas' : filtroTexto;
        final seleccionado = _filtroSeleccionado == valorClave;

        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ChoiceChip(
            label: Text(filtroTexto),
            selected: seleccionado,
            onSelected: (_) {
              setState(() => _filtroSeleccionado = valorClave);
            },
            selectedColor: const Color(0xFF0056D2),
            backgroundColor: const Color(0xFFF0F2F6),
            labelStyle: TextStyle(
              color: seleccionado ? Colors.white : const Color(0xFF333333),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            side: BorderSide.none,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTarjetaMiResena(Map<String, dynamic> r) {
    final nombreLocal = r['establecimientoNombre'] ?? 'Establecimiento';
    final calif = (r['calificacion'] as int?) ?? 5;
    final nivelSeguridad = r['nivelSeguridad'] ?? 'Normal';
    final comentario = r['comentario'] ?? '';
    final fecha = _formatearFecha(r['fechaPublicacion']);

    final esPeligro = nivelSeguridad.toLowerCase().contains('contaminacion');
    final esExcelente = nivelSeguridad.toLowerCase().contains('excelente');

    Color badgeFondo = const Color(0xFFEDF3FF);
    Color badgeTexto = const Color(0xFF0056D2);
    IconData badgeIcon = Icons.verified_user_outlined;

    if (esPeligro) {
      badgeFondo = const Color(0xFFFFECEB);
      badgeTexto = const Color(0xFFD32F2F);
      badgeIcon = Icons.warning_amber_rounded;
    } else if (esExcelente) {
      badgeFondo = const Color(0xFFE8F5E9);
      badgeTexto = const Color(0xFF2E7D32);
      badgeIcon = Icons.security_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: badgeFondo,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(badgeIcon, size: 14, color: badgeTexto),
                    const SizedBox(width: 4),
                    Text(
                      nivelSeguridad,
                      style: TextStyle(
                        color: badgeTexto,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    Icons.star,
                    color: index < calif
                        ? const Color(0xFFE65100)
                        : Colors.grey.shade300,
                    size: 16,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            nombreLocal,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            fecha,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          if (comentario.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              comentario,
              style: const TextStyle(
                color: Color(0xFF4A4A4A),
                fontSize: 14,
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBannerNuevoLugar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF3FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add_location_alt_outlined,
              color: Color(0xFF0056D2),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '¿Visitaste un nuevo lugar?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Ayuda a otros celíacos compartiendo tu experiencia',
                  style: TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0056D2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 0,
            ),
            child: const Text(
              'Reseñar',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoVacio() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 60,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 12),
          Text(
            'Aún no publicaste reseñas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
