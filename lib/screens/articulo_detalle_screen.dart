import 'package:flutter/material.dart';
import 'package:tucu_free_tacc/models/articulo.dart';
import 'package:tucu_free_tacc/data/articulos_data.dart';

class ArticuloDetalleScreen extends StatelessWidget {
  final Articulo articulo;

  const ArticuloDetalleScreen({super.key, required this.articulo});

  @override
  Widget build(BuildContext context) {
    // Relacionados: otros artículos excluyendo el actual
    final articulosRelacionados = listaArticulos
        .where((a) => a.id != articulo.id)
        .take(2)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0056D2)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          articulo.categoria,
          style: const TextStyle(
            color: Color(0xFF0056D2),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.grey),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Imagen Principal con Badge
            Stack(
              children: [
                Image.network(
                  articulo.imagenUrl,
                  height: 210,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  cacheWidth: 600,
                  cacheHeight: 350,
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0056D2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      articulo.categoria.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // 2. Contenido del Artículo
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    articulo.titulo,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.25,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Autor y Fecha
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(
                          0xFF0056D2,
                        ).withOpacity(0.1),
                        child: const Icon(
                          Icons.person,
                          color: Color(0xFF0056D2),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            articulo.autor,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${articulo.fecha} • ${articulo.tiempoLectura} de lectura',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // Cuerpo del texto
                  Text(
                    articulo.contenido,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade800,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Caja de Puntos Clave o Alertas
                  if (articulo.puntosClave.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F6FD),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFD6E3FF)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.checklist_rounded,
                                color: Color(0xFF0056D2),
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                articulo.subtituloSeccion ?? 'Puntos clave',
                                style: const TextStyle(
                                  color: Color(0xFF0056D2),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...articulo.puntosClave.map(
                            (punto) => _buildBulletPoint(punto),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                ],
              ),
            ),

            // 3. Sección Seguir Leyendo
            Container(
              color: const Color(0xFFF3F4F9),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Seguir Leyendo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Contenido seleccionado para la comunidad',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  ...articulosRelacionados.map((rel) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildRelatedArticleCard(context, rel),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              color: Color(0xFF0056D2),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 13.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedArticleCard(BuildContext context, Articulo rel) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ArticuloDetalleScreen(articulo: rel),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                rel.imagenUrl,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                cacheWidth: 150,
                cacheHeight: 150,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rel.categoria.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF0056D2),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    rel.titulo,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${rel.fecha} • ${rel.tiempoLectura}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
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
