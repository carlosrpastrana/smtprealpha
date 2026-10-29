import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tucu_free_tacc/models/establecimiento.dart';
import 'package:tucu_free_tacc/services/favoritos_service.dart';
import 'package:tucu_free_tacc/services/resena_service.dart';
import 'package:tucu_free_tacc/services/historial_service.dart';
import 'package:tucu_free_tacc/screens/login_screen.dart';
import 'package:tucu_free_tacc/screens/crear_resena_screen.dart';

class TiendaDetalleScreen extends StatefulWidget {
  final Establecimiento comercio;

  const TiendaDetalleScreen({super.key, required this.comercio});

  @override
  State<TiendaDetalleScreen> createState() => _TiendaDetalleScreenState();
}

class _TiendaDetalleScreenState extends State<TiendaDetalleScreen> {
  final ResenaService _resenaService = ResenaService();
  List<dynamic> _resenas = [];
  Map<String, dynamic>? _semaforo;
  bool _cargandoResenas = true;

  @override
  void initState() {
    super.initState();
    HistorialService.registrarVisita(
      id: widget.comercio.id,
      nombre: widget.comercio.nombre,
      tipo: 'tienda',
      imagenUrl: widget.comercio.imagenUrl,
      puntuacion: widget.comercio.puntuacion,
      subtitulo: widget.comercio.tipo.isNotEmpty
          ? widget.comercio.tipo
          : 'Tienda / Supermercado',
    );
    _cargarResenas();
  }

  Future<void> _cargarResenas() async {
    final dynamic respuesta = await _resenaService.obtenerPorEstablecimiento(
      widget.comercio.id,
    );
    if (!mounted) return;

    setState(() {
      if (respuesta is Map<String, dynamic>) {
        _resenas = (respuesta['resenas'] as List<dynamic>?) ?? [];
        _semaforo = respuesta['semaforo'] as Map<String, dynamic>?;
      } else if (respuesta is List) {
        _resenas = respuesta;
      }
      _cargandoResenas = false;
    });
  }

  // FUNCIÓN: Trazar ruta en Google Maps
  Future<void> _abrirComoLlegar() async {
    Uri uri;

    if (widget.comercio.latitud != null && widget.comercio.longitud != null) {
      uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${widget.comercio.latitud},${widget.comercio.longitud}',
      );
    } else {
      final query = Uri.encodeComponent(
        '${widget.comercio.nombre}, ${widget.comercio.direccion}, Tucumán, Argentina',
      );
      uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$query',
      );
    }

    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo abrir Google Maps en este dispositivo'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // Abrir WhatsApp con número pre-cargado
  Future<void> _abrirWhatsApp(String telefono) async {
    // Limpia espacios, guiones y signos para dejar solo números
    final soloNumeros = telefono.replaceAll(RegExp(r'[^0-9]'), '');
    if (soloNumeros.isEmpty) return;

    final uri = Uri.parse('https://wa.me/$soloNumeros');
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo abrir WhatsApp en este dispositivo'),
        ),
      );
    }
  }

  // Abrir perfil de Instagram o sitio Web
  Future<void> _abrirWebORedes(String webORedes) async {
    String url = webORedes.trim();

    if (url.toLowerCase().contains('ig') || url.startsWith('@')) {
      // Extrae el usuario quitando "@" y el sufijo "IG"
      final usuario = url
          .replaceAll('@', '')
          .replaceAll(RegExp(r'\s*ig', caseSensitive: false), '')
          .trim();
      url = 'https://instagram.com/$usuario';
    } else if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    final uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el enlace')),
      );
    }
  }

  String _obtenerImagenParaMenu(String tag) {
    final t = tag.toLowerCase();

    // Comidas rápidas y platos principales
    if (t.contains('pizza'))
      return 'https://res.cloudinary.com/qhqxqsaj/image/upload/f_auto,q_auto/v1788722805/pizza_cl11ca.jpg';
    if (t.contains('pasta'))
      return 'https://res.cloudinary.com/qhqxqsaj/image/upload/f_auto,q_auto/v1788722805/pastas_jq8pfs.jpg';
    if (t.contains('hamburguesa'))
      return 'https://res.cloudinary.com/qhqxqsaj/image/upload/f_auto,q_auto/v1788722805/pandehamburguesa_qbiuo9.jpg';
    if (t.contains('sandwich') || t.contains('sanguch'))
      return 'https://res.cloudinary.com/qhqxqsaj/image/upload/f_auto,q_auto/v1788722806/sandwich_lxy95t.jpg';
    if (t.contains('empanada'))
      return 'https://res.cloudinary.com/qhqxqsaj/image/upload/f_auto,q_auto/v1788722804/empanada_ayk8fw.jpg';
    if (t.contains('tarta'))
      return 'https://res.cloudinary.com/qhqxqsaj/image/upload/v1789952647/tarta_rixlak.png';
    if (t.contains('taco'))
      return 'https://res.cloudinary.com/qhqxqsaj/image/upload/v1789952644/tacos_xhg79h.jpg';
    if (t.contains('ensalada') || t.contains('vegan') || t.contains('vegetar'))
      return 'https://res.cloudinary.com/qhqxqsaj/image/upload/v1789952791/ensalada_dodpta.jpg';

    // Cafetería, Panadería y Dulces
    if (t.contains('cafeteria') || t.contains('cafe') || t.contains('desayuno'))
      return 'https://res.cloudinary.com/qhqxqsaj/image/upload/f_auto,q_auto/v1788722804/cafe_sczenz.jpg';
    if (t.contains('pasteleria') ||
        t.contains('postre') ||
        t.contains('panaderia'))
      return 'https://res.cloudinary.com/qhqxqsaj/image/upload/f_auto,q_auto/v1788722806/Postre_dwc2vf.jpg';
    if (t.contains('helad'))
      return 'https://res.cloudinary.com/qhqxqsaj/image/upload/f_auto,q_auto/v1788722804/helado_kzbowx.jpg';

    // Bebidas
    if (t.contains('bebida') || t.contains('cerveza') || t.contains('trago'))
      return 'https://res.cloudinary.com/qhqxqsaj/image/upload/v1789952644/tragos_ixwex1.jpg';

    // Tiendas / Almacén / Congelados
    if (t.contains('almacen') ||
        t.contains('congelado') ||
        t.contains('supermercado'))
      return 'https://res.cloudinary.com/qhqxqsaj/image/upload/f_auto,q_auto/v1788722807/Tiendas_tycfxp.jpg';

    // Fallback general para Resto / Bodegón / Buffet
    return 'https://res.cloudinary.com/qhqxqsaj/image/upload/f_auto,q_auto/v1788723241/bar_h47fig.jpg';
  }

  String _formatearFecha(String? fechaIso) {
    if (fechaIso == null) return 'Reciente';
    final fecha = DateTime.tryParse(fechaIso);
    if (fecha == null) return 'Reciente';
    final dif = DateTime.now().toUtc().difference(fecha);

    if (dif.inDays == 0) return 'Hoy';
    if (dif.inDays == 1) return 'Ayer';
    if (dif.inDays < 7) return 'Hace ${dif.inDays} días';
    if (dif.inDays < 30) return 'Hace ${(dif.inDays / 7).floor()} semanas';
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    final List<String> listaTags = widget.comercio.tags.isNotEmpty
        ? widget.comercio.tags
        : ['Productos Aptos'];

    final bool es100Gf = widget.comercio.badgeText == '100% GF';

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240.0,
            pinned: true,
            backgroundColor: Colors.white,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.35),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(
                      Icons.favorite_border,
                      color: Colors.redAccent,
                    ),
                    onPressed: () async {
                      final favService = FavoritosService();
                      final resultado = await favService.agregarFavorito(
                        widget.comercio.id,
                      );
                      if (!context.mounted) return;

                      if (resultado['requiereLogin'] == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Inicia sesión para guardar tus favoritos',
                            ),
                          ),
                        );
                        final logueado = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                        if (logueado == true) {
                          await favService.agregarFavorito(widget.comercio.id);
                        }
                      } else if (resultado['exito'] == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('¡Guardado en favoritos! ❤️'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(resultado['mensaje'] ?? '')),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                widget.comercio.imagenUrl.isNotEmpty
                    ? widget.comercio.imagenUrl
                    : 'https://res.cloudinary.com/qhqxqsaj/image/upload/v1788722807/Tiendas_tycfxp.jpg',
                fit: BoxFit.cover,
                cacheWidth: 800,
                cacheHeight: 500,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.comercio.nombre,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E1E1E),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: es100Gf
                              ? const Color(0xFFE5A000)
                              : const Color(0xFF0056D2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.verified,
                              color: Colors.white,
                              size: 13,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.comercio.badgeText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (_semaforo != null && _semaforo!['nivel'] != 'Normal') ...[
                    _buildBannerSemaforo(_semaforo!),
                    const SizedBox(height: 16),
                  ],

                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: Colors.grey,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          widget.comercio.direccion,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: Colors.grey,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.comercio.horarios,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Renglón de Teléfono con botón de WhatsApp
                  if (widget.comercio.telefono.isNotEmpty &&
                      widget.comercio.telefono != '-') ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.phone_outlined,
                          color: Colors.grey,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.comercio.telefono,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13,
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () => _abrirWhatsApp(widget.comercio.telefono),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFA5D6A7),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  color: Color(0xFF2E7D32),
                                  size: 14,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'WhatsApp',
                                  style: TextStyle(
                                    color: Color(0xFF2E7D32),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],

                  // Renglón de Redes / Web clickeable
                  if (widget.comercio.weboredes.isNotEmpty &&
                      widget.comercio.weboredes != '-') ...[
                    InkWell(
                      onTap: () => _abrirWebORedes(widget.comercio.weboredes),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.language,
                            color: Color(0xFF0056D2),
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              widget.comercio.weboredes,
                              style: const TextStyle(
                                color: Color(0xFF0056D2),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(
                            Icons.open_in_new,
                            color: Color(0xFF0056D2),
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  if (widget.comercio.descripcion.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      widget.comercio.descripcion,
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 13.5,
                        height: 1.4,
                      ),
                    ),
                  ],

                  const SizedBox(height: 18),
                  const Divider(),
                  const SizedBox(height: 14),

                  const Text(
                    'Productos Aptos Disponibles',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 175,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: listaTags.length,
                      itemBuilder: (context, index) {
                        final tagActual = listaTags[index].trim();
                        return Container(
                          width: 135,
                          margin: const EdgeInsets.only(right: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: Image.network(
                                  _obtenerImagenParaMenu(tagActual),
                                  height: 88,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  cacheWidth: 280,
                                  cacheHeight: 180,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tagActual,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      'Certificado',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 28),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Calificaciones',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0056D2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 18,
                          ),
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            final usuarioId = prefs.getInt('usuarioId');
                            if (!context.mounted) return;

                            if (usuarioId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Inicia sesión para dejar tu reseña',
                                  ),
                                ),
                              );
                              final logueado = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                              if (logueado != true) return;
                            }
                            if (!context.mounted) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CrearResenaScreen(
                                  restaurante: widget.comercio,
                                ),
                              ),
                            ).then((_) => _cargarResenas());
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        widget.comercio.puntuacion,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Row(
                          children: List.generate(
                            5,
                            (index) => const Icon(
                              Icons.star,
                              color: Colors.orange,
                              size: 17,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          '${_resenas.length} reseñas comunitarias',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  if (_cargandoResenas)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: CircularProgressIndicator(
                          color: Color(0xFF0056D2),
                        ),
                      ),
                    )
                  else if (_resenas.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Aún no hay reseñas para esta tienda. ¡Sé el primero en calificar la variedad sin gluten!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    )
                  else
                    Column(
                      children: _resenas
                          .map((r) => _buildTarjetaResena(r))
                          .toList(),
                    ),
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: FloatingActionButton.extended(
          onPressed:
              _abrirComoLlegar, // <--- Conectado a la ruta en Google Maps
          backgroundColor: const Color(0xFF0056D2),
          icon: const Icon(Icons.directions, color: Colors.white),
          label: const Text(
            'Cómo llegar',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildBannerSemaforo(Map<String, dynamic> semaforo) {
    final nivel = semaforo['nivel'] ?? '';
    final mensaje = semaforo['mensaje'] ?? '';
    final colorTipo = semaforo['color'] ?? 'amarillo';

    Color bg = const Color(0xFFFFFBEB);
    Color border = const Color(0xFFFDE68A);
    Color textCol = const Color(0xFF92400E);
    IconData icon = Icons.info_outline;

    if (colorTipo == 'naranja') {
      bg = const Color(0xFFFFF7ED);
      border = const Color(0xFFFED7AA);
      textCol = const Color(0xFFC2410C);
      icon = Icons.warning_amber_rounded;
    } else if (colorTipo == 'rojo') {
      bg = const Color(0xFFFEF2F2);
      border = const Color(0xFFFECACA);
      textCol = const Color(0xFFB91C1C);
      icon = Icons.dangerous_outlined;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: textCol, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nivel.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: textCol,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  mensaje,
                  style: TextStyle(
                    fontSize: 12,
                    color: textCol.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTarjetaResena(Map<String, dynamic> r) {
    final nombre = r['usuarioNombre'] ?? 'Usuario';
    final inicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U';
    final fecha = _formatearFecha(r['fechaPublicacion']);
    final calif = (r['calificacion'] as int?) ?? 5;
    final nivelSeguridad = r['nivelSeguridad'] ?? 'Normal';
    final comentario = r['comentario'] ?? '';
    final List<dynamic> tagsSeguridad = r['destacadosSeguridad'] ?? [];
    final esPeligro = nivelSeguridad == 'Contaminacion cruzada';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: esPeligro ? const Color(0xFFFFF5F5) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: esPeligro ? Border.all(color: Colors.red.shade200) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: esPeligro
                    ? Colors.red.shade100
                    : const Color(0xFFEDF3FF),
                child: Text(
                  inicial,
                  style: TextStyle(
                    color: esPeligro
                        ? Colors.red.shade900
                        : const Color(0xFF0056D2),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      fecha,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    Icons.star,
                    color: index < calif ? Colors.orange : Colors.grey.shade300,
                    size: 13,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: esPeligro ? Colors.red.shade100 : Colors.green.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Seguridad: $nivelSeguridad',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: esPeligro ? Colors.red.shade800 : Colors.green.shade900,
              ),
            ),
          ),
          if (tagsSeguridad.isNotEmpty) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              children: tagsSeguridad.map((t) {
                return Chip(
                  padding: EdgeInsets.zero,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.grey.shade300),
                  label: Text(
                    t.toString(),
                    style: const TextStyle(fontSize: 9, color: Colors.black87),
                  ),
                );
              }).toList(),
            ),
          ],
          if (comentario.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '"$comentario"',
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
