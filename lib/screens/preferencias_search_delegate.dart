import 'package:flutter/material.dart';
import 'package:tucu_free_tacc/screens/informacion_personal_screen.dart';
import 'package:tucu_free_tacc/screens/cambiar_password_screen.dart';
import 'package:tucu_free_tacc/screens/idioma_screen.dart';
import 'package:tucu_free_tacc/screens/privacidad_screen.dart';
import 'package:tucu_free_tacc/screens/notificaciones_screen.dart';
import 'package:tucu_free_tacc/screens/centro_ayuda_screen.dart';
import 'package:tucu_free_tacc/screens/favoritos_screen.dart';
import 'package:tucu_free_tacc/screens/mis_resenas_screen.dart';

class PreferenciasSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> _opciones = [
    {
      'titulo': 'Información Personal',
      'categoria': 'Cuenta',
      'icono': Icons.person_outline,
      'screen': const InformacionPersonalScreen(),
    },
    {
      'titulo': 'Cambiar Contraseña',
      'categoria': 'Seguridad',
      'icono': Icons.lock_outline,
      'screen': const CambiarPasswordScreen(),
    },
    {
      'titulo': 'Idioma',
      'categoria': 'Preferencias',
      'icono': Icons.language,
      'screen': const IdiomaScreen(),
    },
    {
      'titulo': 'Privacidad',
      'categoria': 'Seguridad',
      'icono': Icons.shield_outlined,
      'screen': const PrivacidadScreen(),
    },
    {
      'titulo': 'Notificaciones',
      'categoria': 'Alertas',
      'icono': Icons.notifications_none_outlined,
      'screen': const NotificacionesScreen(),
    },
    {
      'titulo': 'Centro de Ayuda',
      'categoria': 'Soporte',
      'icono': Icons.help_outline,
      'screen': const CentroAyudaScreen(),
    },
    {
      'titulo': 'Mis Favoritos',
      'categoria': 'Actividad',
      'icono': Icons.favorite_border,
      'screen': const FavoritosScreen(),
    },
    {
      'titulo': 'Mis Reseñas',
      'categoria': 'Comunidad',
      'icono': Icons.rate_review_outlined,
      'screen': const MisResenasScreen(),
    },
  ];

  @override
  String get searchFieldLabel => 'Buscar ajustes o secciones...';

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
  Widget buildResults(BuildContext context) => _construirResultados(context);

  @override
  Widget buildSuggestions(BuildContext context) =>
      _construirResultados(context);

  Widget _construirResultados(BuildContext context) {
    final filtrados = _opciones.where((item) {
      final titulo = (item['titulo'] as String).toLowerCase();
      final cat = (item['categoria'] as String).toLowerCase();
      return titulo.contains(query.toLowerCase()) ||
          cat.contains(query.toLowerCase());
    }).toList();

    if (filtrados.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 50, color: Colors.grey.shade400),
            const SizedBox(height: 10),
            Text(
              'No se encontraron ajustes para "$query"',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: filtrados.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, indent: 64, color: Color(0xFFEEEEEE)),
      itemBuilder: (context, index) {
        final item = filtrados[index];
        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEDF3FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              item['icono'] as IconData,
              color: const Color(0xFF0056D2),
              size: 20,
            ),
          ),
          title: Text(
            item['titulo'],
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          subtitle: Text(
            item['categoria'],
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            size: 18,
            color: Colors.grey,
          ),
          onTap: () {
            close(context, null);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => item['screen'] as Widget),
            );
          },
        );
      },
    );
  }
}
