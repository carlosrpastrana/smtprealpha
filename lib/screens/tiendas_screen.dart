import 'package:flutter/material.dart';
import 'package:tucu_free_tacc/models/establecimiento.dart';
import 'package:tucu_free_tacc/services/establecimiento_service.dart';
import 'package:tucu_free_tacc/screens/tienda_detalle_screen.dart';
import 'package:tucu_free_tacc/screens/tienda_search_delegate.dart';

class TiendasScreen extends StatefulWidget {
  const TiendasScreen({super.key});

  @override
  State<TiendasScreen> createState() => _TiendasScreenState();
}

class _TiendasScreenState extends State<TiendasScreen> {
  final EstablecimientoService _service = EstablecimientoService();
  late Future<List<Establecimiento>> _tiendasFuture;
  String _filtroTipo = 'Todos';

  final List<String> _categorias = [
    'Todos',
    'Tienda',
    'Panadería',
    'Supermercado',
    'Tienda Online',
  ];

  @override
  void initState() {
    super.initState();
    _recargar();
  }

  List<Establecimiento> _tiendasCache = [];

  void _recargar() {
    setState(() {
      _tiendasFuture = _service.obtenerTiendas().then((lista) {
        _tiendasCache = lista;
        return lista;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.search, color: Color(0xFF0056D2)),
          onPressed: () {
            showSearch(
              context: context,
              delegate: TiendaSearchDelegate(_tiendasCache),
            );
          },
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
      body: RefreshIndicator(
        color: const Color(0xFF0056D2),
        onRefresh: () async => _recargar(),
        child: FutureBuilder<List<Establecimiento>>(
          future: _tiendasFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF0056D2)),
              );
            }

            final items = snapshot.data ?? [];
            final filtrados = _filtroTipo == 'Todos'
                ? items
                : items
                      .where(
                        (t) =>
                            t.tipo.toLowerCase() == _filtroTipo.toLowerCase(),
                      )
                      .toList();

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const Text(
                  'Tiendas y Almacenes',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Comercios especializados, dietéticas, panaderías y supermercados con sección Sin T.A.C.C.',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 14),

                // Selector de Categorías
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categorias.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = _categorias[index];
                      final activo = _filtroTipo == cat;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: activo,
                        onSelected: (_) => setState(() => _filtroTipo = cat),
                        selectedColor: const Color(0xFF0056D2),
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: activo
                              ? Colors.white
                              : const Color(0xFF333333),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(
                            color: activo
                                ? const Color(0xFF0056D2)
                                : Colors.grey.shade300,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),

                if (filtrados.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    alignment: Alignment.center,
                    child: Text(
                      'No hay comercios registrados en esta categoría',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  )
                else
                  ...filtrados.map((item) => _buildCard(item)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCard(Establecimiento local) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TiendaDetalleScreen(comercio: local),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                local.imagenUrl.isNotEmpty
                    ? local.imagenUrl
                    : 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=150&q=50',
                width: 76,
                height: 76,
                fit: BoxFit.cover,
                cacheWidth: 160,
                cacheHeight: 160,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDF3FF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          local.tipo.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF0056D2),
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        local.badgeText,
                        style: TextStyle(
                          color: local.badgeText == '100% GF'
                              ? Colors.orange.shade800
                              : const Color(0xFF0056D2),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    local.nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF1E1E1E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    local.direccion,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (local.tags.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      local.tags.join(' • '),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
