import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tucu_free_tacc/models/establecimiento.dart';
import 'package:tucu_free_tacc/services/establecimiento_service.dart';
import 'package:tucu_free_tacc/screens/restaurante_detalle_screen.dart';

class ExplorarScreen extends StatefulWidget {
  const ExplorarScreen({super.key});

  @override
  State<ExplorarScreen> createState() => _ExplorarScreenState();
}

class _ExplorarScreenState extends State<ExplorarScreen> {
  final EstablecimientoService _service = EstablecimientoService();
  late Future<List<Establecimiento>> _restaurantesFuture;

  String _busqueda = '';
  String _categoriaSeleccionada = '';
  GoogleMapController? _mapController;

  // Centro inicial: San Miguel de Tucumán (Plaza Independencia / Microcentro)
  static const LatLng _centroSMT = LatLng(-26.8327, -65.2045);

  final List<Map<String, dynamic>> _categorias = [
    {'nombre': 'Desayuno', 'icono': Icons.breakfast_dining_outlined},
    {'nombre': 'Almuerzo', 'icono': Icons.lunch_dining_outlined},
    {'nombre': 'Merienda', 'icono': Icons.coffee_outlined},
    {'nombre': 'Cena', 'icono': Icons.dinner_dining_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _recargar();
  }

  void _recargar() {
    setState(() {
      _restaurantesFuture = _service.obtenerRestaurantes();
    });
  }

  void _alternarCategoria(String cat) {
    setState(() {
      if (_categoriaSeleccionada == cat) {
        _categoriaSeleccionada = '';
      } else {
        _categoriaSeleccionada = cat;
      }
    });
  }

  // Generación de Marcadores a partir de los locales con lat/lng
  Set<Marker> _generarMarcadores(List<Establecimiento> locales) {
    final Set<Marker> markers = {};

    for (final local in locales) {
      if (local.latitud != null && local.longitud != null) {
        markers.add(
          Marker(
            markerId: MarkerId(local.id.toString()),
            position: LatLng(local.latitud!, local.longitud!),
            infoWindow: InfoWindow(
              title: local.nombre,
              snippet: '${local.badgeText} • Toca para ver detalle',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RestauranteDetalleScreen(restaurante: local),
                  ),
                );
              },
            ),
            icon: local.badgeText == '100% GF'
                ? BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueOrange,
                  )
                : BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueAzure,
                  ),
          ),
        );
      }
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
      body: RefreshIndicator(
        color: const Color(0xFF0056D2),
        onRefresh: () async => _recargar(),
        child: FutureBuilder<List<Establecimiento>>(
          future: _restaurantesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF0056D2)),
              );
            }

            final items = snapshot.data ?? [];

            // Filtrado combinado
            final filtrados = items.where((e) {
              final query = _busqueda.toLowerCase();
              final coincideQuery =
                  query.isEmpty ||
                  e.nombre.toLowerCase().contains(query) ||
                  e.tags.any((t) => t.toLowerCase().contains(query)) ||
                  e.categoria.toLowerCase().contains(query) ||
                  e.direccion.toLowerCase().contains(query);

              final coincideCategoria =
                  _categoriaSeleccionada.isEmpty ||
                  e.categoria.toLowerCase().contains(
                    _categoriaSeleccionada.toLowerCase(),
                  ) ||
                  e.tags.any(
                    (t) => t.toLowerCase().contains(
                      _categoriaSeleccionada.toLowerCase(),
                    ),
                  );

              return coincideQuery && coincideCategoria;
            }).toList();

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                // 1. CABECERA CON GOOGLE MAPS REAL
                _buildMapaGoogle(items),

                // 2. BUSCADOR
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (val) => setState(() => _busqueda = val),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey,
                          size: 22,
                        ),
                        hintText: 'Buscar restaurantes o platos...',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 13,
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ),
                ),

                // 3. SELECTOR DE CATEGORÍAS
                SizedBox(
                  height: 42,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: _categorias.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final item = _categorias[index];
                      final String nombre = item['nombre'];
                      final IconData icono = item['icono'];
                      final bool activo = _categoriaSeleccionada == nombre;

                      return GestureDetector(
                        onTap: () => _alternarCategoria(nombre),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: activo
                                ? const Color(0xFF0056D2)
                                : const Color(0xFFF1F3F5),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                icono,
                                size: 16,
                                color: activo
                                    ? Colors.white
                                    : const Color(0xFF1E1E1E),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                nombre,
                                style: TextStyle(
                                  color: activo
                                      ? Colors.white
                                      : const Color(0xFF1E1E1E),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 22),

                // 4. CONTADOR Y SECCIÓN
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recomendados cerca de ti',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E1E1E),
                        ),
                      ),
                      Text(
                        '${filtrados.length} locales',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 5. LISTADO DE TARJETAS
                if (filtrados.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(40),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 48,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'No se encontraron locales aptos',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: filtrados
                          .map((item) => _buildCard(item))
                          .toList(),
                    ),
                  ),

                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }

  // --- WIDGET GOOGLE MAPS ---
  Widget _buildMapaGoogle(List<Establecimiento> locales) {
    return SizedBox(
      height: 210,
      width: double.infinity,
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _centroSMT,
              zoom: 13.0,
            ),
            markers: _generarMarcadores(locales),
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: false,
            mapToolbarEnabled: false,
            onMapCreated: (controller) => _mapController = controller,
            // Permite interacción directa sobre el mapa sin bloquear el scroll del ListView
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer(),
              ),
            },
          ),
          Positioned(
            bottom: 8,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.place, size: 12, color: Color(0xFF0056D2)),
                  SizedBox(width: 4),
                  Text(
                    'San Miguel de Tucumán',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0056D2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- TARJETA DE ESTABLECIMIENTO ---
  Widget _buildCard(Establecimiento local) {
    final bool es100GF = local.badgeText.trim() == '100% GF';
    final Color colorBadge = es100GF
        ? const Color(0xFFFFA500)
        : const Color(0xFF0056D2);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RestauranteDetalleScreen(restaurante: local),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: Image.network(
                    local.imagenUrl.isNotEmpty
                        ? local.imagenUrl
                        : 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=600&q=60',
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    cacheWidth: 600,
                    cacheHeight: 320,
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorBadge,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified,
                          color: Colors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          local.badgeText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          local.nombre,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E1E1E),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            local.puntuacion,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Color(0xFF1E1E1E),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.restaurant_menu,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          local.tags.isNotEmpty
                              ? '${local.categoria.isNotEmpty ? local.categoria : 'Gastronomía'} • ${local.tags.take(3).join(' • ')}'
                              : (local.categoria.isNotEmpty
                                    ? local.categoria
                                    : 'Menú Apto'),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          local.direccion,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
