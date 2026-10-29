import 'package:flutter/material.dart';
import 'package:tucu_free_tacc/services/favoritos_service.dart';
import 'package:tucu_free_tacc/models/establecimiento.dart';
import 'package:tucu_free_tacc/screens/restaurante_detalle_screen.dart';
import 'package:tucu_free_tacc/screens/tienda_detalle_screen.dart';

class FavoritosScreen extends StatefulWidget {
  const FavoritosScreen({super.key});

  @override
  State<FavoritosScreen> createState() => _FavoritosScreenState();
}

class _FavoritosScreenState extends State<FavoritosScreen> {
  final FavoritosService _favoritosService = FavoritosService();
  List<Establecimiento> _listaFavoritos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarFavoritos();
  }

  Future<void> _cargarFavoritos() async {
    final datos = await _favoritosService.obtenerFavoritos();
    if (!mounted) return;
    setState(() {
      _listaFavoritos = datos
          .map((item) => Establecimiento.fromJson(item as Map<String, dynamic>))
          .toList();
      _cargando = false;
    });
  }

  Future<void> _quitarFavorito(int id) async {
    final exito = await _favoritosService.eliminarFavorito(id);
    if (exito) {
      setState(() {
        _listaFavoritos.removeWhere((item) => item.id == id);
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Eliminado de favoritos')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0056D2)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Mis Favoritos',
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
          : _listaFavoritos.isEmpty
          ? _buildEstadoVacio()
          : _buildListaFavoritos(),
    );
  }

  Widget _buildEstadoVacio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Aún no tienes favoritos',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Explora y guarda los lugares que más te gusten.',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildListaFavoritos() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _listaFavoritos.length,
      itemBuilder: (context, index) {
        final local = _listaFavoritos[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: GestureDetector(
            onTap: () {
              final Widget screen = local.tipo == 'Restaurante'
                  ? RestauranteDetalleScreen(restaurante: local)
                  : TiendaDetalleScreen(comercio: local);

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => screen),
              ).then((_) => _cargarFavoritos());
            },
            child: _buildTarjetaFavorito(local),
          ),
        );
      },
    );
  }

  Widget _buildTarjetaFavorito(Establecimiento local) {
    return Container(
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
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.network(
                  local.imagenUrl.isNotEmpty
                      ? local.imagenUrl
                      : 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=600&q=80',
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  cacheWidth: 400,
                  cacheHeight: 260,
                ),
              ),
              // Botón Quitar Favorito
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () => _quitarFavorito(local.id),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.redAccent,
                      size: 18,
                    ),
                  ),
                ),
              ),
              // Badge Certificación
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: local.badgeText == '100% GF'
                        ? const Color(0xFFE5A000)
                        : const Color(0xFF0056D2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified, color: Colors.white, size: 12),
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E1E1E),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 15),
                        const SizedBox(width: 3),
                        Text(
                          local.puntuacion,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  local.categoria.isNotEmpty ? local.categoria : local.tipo,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: Colors.grey.shade500,
                      size: 15,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        local.direccion,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
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
    );
  }
}
