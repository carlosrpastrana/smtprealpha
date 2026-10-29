import 'package:flutter/material.dart';
import 'package:tucu_free_tacc/models/articulo.dart';
import 'package:tucu_free_tacc/services/articulo_service.dart';
import 'package:tucu_free_tacc/screens/articulo_detalle_screen.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  final ArticuloService _articuloService = ArticuloService();

  List<Articulo> _todosLosArticulos = [];
  bool _cargando = true;
  String _filtroActivo = 'Todos';

  final List<String> _categoriasFiltro = [
    'Todos',
    'Salud',
    'Noticias',
    'Trámites',
    'Eventos',
    'Recetas',
  ];

  @override
  void initState() {
    super.initState();
    _cargarArticulos();
  }

  Future<void> _cargarArticulos() async {
    final articulos = await _articuloService.obtenerArticulos();
    if (!mounted) return;
    setState(() {
      _todosLosArticulos = articulos;
      _cargando = false;
    });
  }

  List<Articulo> get _articulosFiltrados {
    if (_filtroActivo == 'Todos') return _todosLosArticulos;
    if (_filtroActivo == 'Noticias') {
      return _todosLosArticulos.where((a) => a.tipo == 'noticia').toList();
    }
    if (_filtroActivo == 'Salud') {
      return _todosLosArticulos
          .where((a) => a.categoria == 'Salud' || a.categoria == 'Guía Básica')
          .toList();
    }
    if (_filtroActivo == 'Trámites') {
      return _todosLosArticulos
          .where((a) => a.categoria == 'Trámite Social')
          .toList();
    }
    if (_filtroActivo == 'Eventos') {
      return _todosLosArticulos.where((a) => a.categoria == 'Evento').toList();
    }
    if (_filtroActivo == 'Recetas') {
      return _todosLosArticulos.where((a) => a.categoria == 'Recetas').toList();
    }
    return _todosLosArticulos;
  }

  Color _obtenerColorBadge(String categoria) {
    switch (categoria) {
      case 'Salud':
        return Colors.red.shade700;
      case 'Trámite Social':
        return const Color(0xFF0056D2);
      case 'Evento':
        return Colors.green.shade700;
      case 'Noticia':
        return Colors.orange.shade700;
      case 'Recetas':
        return Colors.purple.shade700;
      default:
        return const Color(0xFF0056D2);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Busca la primera noticia o trámite relevante para fijarlo como destacado
    final Articulo? articuloDestacado = _todosLosArticulos
        .cast<Articulo?>()
        .firstWhere(
          (a) => a?.tipo == 'noticia' || a?.categoria == 'Trámite Social',
          orElse: () =>
              _todosLosArticulos.isNotEmpty ? _todosLosArticulos.first : null,
        );

    final List<Articulo> articulosParaMostrar = _articulosFiltrados;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
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
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0056D2)),
            )
          : RefreshIndicator(
              color: const Color(0xFF0056D2),
              onRefresh: _cargarArticulos,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                children: [
                  const Text(
                    'Educación y Comunidad',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Guías de salud, noticias de subsidios y eventos para la comunidad celíaca.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Chips de categoría
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categoriasFiltro.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final cat = _categoriasFiltro[index];
                        final seleccionado = _filtroActivo == cat;
                        return ChoiceChip(
                          label: Text(cat),
                          selected: seleccionado,
                          onSelected: (_) =>
                              setState(() => _filtroActivo = cat),
                          selectedColor: const Color(0xFF0056D2),
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: seleccionado
                                ? Colors.white
                                : const Color(0xFF333333),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: seleccionado
                                  ? const Color(0xFF0056D2)
                                  : Colors.grey.shade300,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Tarjeta destacada sólo en vista general o de noticias
                  if ((_filtroActivo == 'Todos' ||
                          _filtroActivo == 'Noticias') &&
                      articuloDestacado != null) ...[
                    _buildTarjetaDestacada(context, articuloDestacado),
                    const SizedBox(height: 20),
                  ],

                  if (articulosParaMostrar.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Icon(
                            Icons.article_outlined,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No hay publicaciones en esta categoría',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...articulosParaMostrar.map((articulo) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: _buildTarjetaArticulo(context, articulo),
                      );
                    }),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildTarjetaDestacada(BuildContext context, Articulo articulo) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ArticuloDetalleScreen(articulo: articulo),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0043A8), Color(0xFF0056D2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0056D2).withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    articulo.categoria.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  articulo.fecha,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              articulo.titulo,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              articulo.resumen,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                Text(
                  'Consultar detalles',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward, color: Colors.white, size: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTarjetaArticulo(BuildContext context, Articulo articulo) {
    final colorBadge = _obtenerColorBadge(articulo.categoria);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticuloDetalleScreen(articulo: articulo),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
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
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    articulo.imagenUrl.isNotEmpty
                        ? articulo.imagenUrl
                        : 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=400&q=50',
                    height: 130,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    cacheWidth: 400,
                    cacheHeight: 260,
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorBadge,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      articulo.categoria.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    articulo.titulo,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    articulo.resumen,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.35,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            articulo.tiempoLectura,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: const [
                          Text(
                            'Leer más',
                            style: TextStyle(
                              color: Color(0xFF0056D2),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward,
                            color: Color(0xFF0056D2),
                            size: 14,
                          ),
                        ],
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
