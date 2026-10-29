import 'package:flutter/material.dart';
import 'package:tucu_free_tacc/models/establecimiento.dart';
import 'package:tucu_free_tacc/screens/tienda_detalle_screen.dart';

class TiendaSearchDelegate extends SearchDelegate<Establecimiento?> {
  final List<Establecimiento> tiendas;

  TiendaSearchDelegate(this.tiendas);

  @override
  String get searchFieldLabel => 'Buscar tiendas, dietéticas, productos...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear, color: Colors.grey),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Color(0xFF0056D2)),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _construirResultados(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _construirResultados(context);
  }

  Widget _construirResultados(BuildContext context) {
    final q = query.trim().toLowerCase();

    final filtrados = tiendas.where((t) {
      return t.nombre.toLowerCase().contains(q) ||
          t.direccion.toLowerCase().contains(q) ||
          t.categoria.toLowerCase().contains(q) ||
          t.tags.any((tag) => tag.toLowerCase().contains(q));
    }).toList();

    if (filtrados.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 56,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            Text(
              query.isEmpty
                  ? 'Escribe el nombre de un local o producto'
                  : 'No se encontraron comercios para "$query"',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: filtrados.length,
      itemBuilder: (context, index) {
        final local = filtrados[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              local.imagenUrl.isNotEmpty
                  ? local.imagenUrl
                  : 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=100&q=50',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(
            local.nombre,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          subtitle: Text(
            '${local.tipo} • ${local.direccion}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: local.badgeText == '100% GF'
                  ? const Color(0xFFFFF7ED)
                  : const Color(0xFFEDF3FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              local.badgeText,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: local.badgeText == '100% GF'
                    ? Colors.orange.shade800
                    : const Color(0xFF0056D2),
              ),
            ),
          ),
          onTap: () {
            close(context, local);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TiendaDetalleScreen(comercio: local),
              ),
            );
          },
        );
      },
    );
  }
}
