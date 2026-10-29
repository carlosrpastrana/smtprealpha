import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tucu_free_tacc/services/auth_service.dart';
import 'package:tucu_free_tacc/services/favoritos_service.dart';
import 'package:tucu_free_tacc/services/resena_service.dart';
import 'package:tucu_free_tacc/services/historial_service.dart';
import 'package:tucu_free_tacc/screens/configuracion_screen.dart';
import 'package:tucu_free_tacc/screens/favoritos_screen.dart';
import 'package:tucu_free_tacc/screens/mis_resenas_screen.dart';
import 'package:tucu_free_tacc/screens/notificaciones_screen.dart';
import 'package:tucu_free_tacc/screens/login_screen.dart';
import 'package:tucu_free_tacc/screens/preferencias_search_delegate.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final FavoritosService _favoritosService = FavoritosService();
  final ResenaService _resenaService = ResenaService();

  bool _cargando = true;
  int? _usuarioId;
  String _nombre = '';
  String _email = '';
  String _fotoPerfil = '';
  int _cantidadFavoritos = 0;
  int _cantidadResenas = 0;
  List<Map<String, dynamic>> _actividadReciente = [];

  final List<String> _avataresPredeterminados = [
    'https://res.cloudinary.com/qhqxqsaj/image/upload/v1790540413/sintacc_gwtetn.png',
    'https://res.cloudinary.com/qhqxqsaj/image/upload/v1790541921/sonrisa_stozxu.jpg',
    'https://res.cloudinary.com/qhqxqsaj/image/upload/v1790539933/trigo_zgjnaq.png',
    'https://res.cloudinary.com/qhqxqsaj/image/upload/v1790541969/cool_fgu1av.jpg',
    'https://res.cloudinary.com/qhqxqsaj/image/upload/v1790539921/pan_cqhfmf.png',
    'https://res.cloudinary.com/qhqxqsaj/image/upload/v1790539921/gato_j7qsaf.png',
    'https://res.cloudinary.com/qhqxqsaj/image/upload/v1790539921/perro_mpeaw5.png',
  ];

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  Future<void> _cargarDatosUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('usuarioId');
    final nombre = prefs.getString('nombre') ?? '';
    final email = prefs.getString('email') ?? '';
    final foto =
        prefs.getString('foto_perfil') ?? _avataresPredeterminados.first;

    int cantFavs = 0;
    int cantResenas = 0;

    if (id != null) {
      final favs = await _favoritosService.obtenerFavoritos();
      cantFavs = favs.length;

      final resenas = await _resenaService.obtenerPorUsuario();
      cantResenas = resenas.length;
    }

    final historial = await HistorialService.obtenerHistorial();

    if (!mounted) return;

    setState(() {
      _usuarioId = id;
      _nombre = nombre;
      _email = email;
      _fotoPerfil = foto;
      _cantidadFavoritos = cantFavs;
      _cantidadResenas = cantResenas;
      _actividadReciente = historial;
      _cargando = false;
    });
  }

  String _formatearFechaVisita(String? fechaIso) {
    if (fechaIso == null) return 'Reciente';
    final fecha = DateTime.tryParse(fechaIso);
    if (fecha == null) return 'Reciente';
    final dif = DateTime.now().difference(fecha);

    if (dif.inMinutes < 60) return 'Hace instantes';
    if (dif.inHours < 24) return 'Hoy';
    if (dif.inDays == 1) return 'Ayer';
    if (dif.inDays < 7) return 'Hace ${dif.inDays} días';
    return 'Hace ${(dif.inDays / 7).floor()} sem';
  }

  void _abrirModalCambiarFoto() {
    final urlController = TextEditingController();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Foto de Perfil',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1E1E),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Selecciona un avatar o pega la URL de una foto',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 64,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _avataresPredeterminados.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final url = _avataresPredeterminados[i];
                  return GestureDetector(
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('foto_perfil', url);
                      setState(() => _fotoPerfil = url);
                      Navigator.pop(ctx);
                    },
                    child: CircleAvatar(
                      radius: 28,
                      backgroundImage: NetworkImage(url),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            //TextField(
            //controller: urlController,
            //decoration: InputDecoration(
            //  hintText: 'https://ejemplo.com/mifoto.jpg',
            // prefixIcon: const Icon(Icons.link, color: Color(0xFF0056D2)),
            // border: OutlineInputBorder(
            //   borderRadius: BorderRadius.circular(12),
            //),
            //  ),
            // ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0056D2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  if (urlController.text.trim().isNotEmpty) {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString(
                      'foto_perfil',
                      urlController.text.trim(),
                    );
                    setState(() => _fotoPerfil = urlController.text.trim());
                  }
                  Navigator.pop(ctx);
                },
                child: const Text(
                  'Guardar Foto',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoCerrarSesion() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas salir de tu cuenta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await _authService.logout();
              await _cargarDatosUsuario();

              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sesión cerrada exitosamente'),
                  backgroundColor: Color(0xFF0056D2),
                ),
              );
            },
            child: const Text('Salir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF0056D2)),
        ),
      );
    }

    final bool estaAutenticado = _usuarioId != null;

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
              delegate: PreferenciasSearchDelegate(),
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
        onRefresh: () async => _cargarDatosUsuario(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildProfileHeader(estaAutenticado),
              const SizedBox(height: 24),
              _buildStatsRow(estaAutenticado),
              const SizedBox(height: 24),
              _buildRecentActivity(),
              const SizedBox(height: 24),
              _buildSettingsMenu(estaAutenticado),
              const SizedBox(height: 32),
              const Text(
                'Versión 1.0.0 • c.r.p',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(bool estaAutenticado) {
    if (!estaAutenticado) {
      return Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey.shade300,
            child: const Icon(
              Icons.person_outline,
              size: 55,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Invitado',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Explorando sin cuenta',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () async {
              final logueado = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
              if (logueado == true) _cargarDatosUsuario();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0056D2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
            child: const Text(
              'Iniciar Sesión / Registro',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            GestureDetector(
              onTap: _abrirModalCambiarFoto,
              child: CircleAvatar(
                radius: 55,
                backgroundImage: NetworkImage(_fotoPerfil),
              ),
            ),
            GestureDetector(
              onTap: _abrirModalCambiarFoto,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0056D2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                padding: const EdgeInsets.all(5),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          _nombre.isNotEmpty ? _nombre : 'Usuario',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E1E1E),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.email_outlined, color: Colors.grey, size: 16),
            const SizedBox(width: 4),
            Text(_email, style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsRow(bool estaAutenticado) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            estaAutenticado ? _cantidadResenas.toString() : '0',
            'Reseñas',
            const Color(0xFF0056D2),
            onTap: () {
              if (!estaAutenticado) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Inicia sesión para ver tus reseñas'),
                  ),
                );
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MisResenasScreen(),
                ),
              ).then((_) => _cargarDatosUsuario());
            },
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _buildStatCard(
            estaAutenticado ? _cantidadFavoritos.toString() : '0',
            'Favoritos',
            Colors.orange,
            onTap: () {
              if (!estaAutenticado) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Inicia sesión para ver tus favoritos'),
                  ),
                );
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoritosScreen(),
                ),
              ).then((_) => _cargarDatosUsuario());
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actividad Reciente',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E1E1E),
          ),
        ),
        const SizedBox(height: 12),
        if (_actividadReciente.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.history_outlined,
                  size: 36,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 8),
                Text(
                  'Aún no exploraste locales',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          )
        else
          ..._actividadReciente.take(3).map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildActivityCard(
                item['nombre'] ?? '',
                item['subtitulo'] ?? '',
                _formatearFechaVisita(item['fecha']),
                item['puntuacion'] ?? '5.0',
                item['imagenUrl'] ?? '',
              ),
            );
          }),
      ],
    );
  }

  Widget _buildActivityCard(
    String title,
    String subtitle,
    String time,
    String rating,
    String imageUrl,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl.isNotEmpty
                  ? imageUrl
                  : 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=150&q=50',
              width: 56,
              height: 56,
              fit: BoxFit.cover,
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
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          rating,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  time,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsMenu(bool estaAutenticado) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildListTile(
            Icons.settings_outlined,
            'Configuración de Cuenta',
            color: const Color(0xFF0056D2),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ConfiguracionScreen(),
                ),
              ).then((_) => _cargarDatosUsuario());
            },
          ),
          const Divider(height: 1, indent: 50, color: Color(0xFFEEEEEE)),
          _buildListTile(
            Icons.notifications_none,
            'Notificaciones',
            color: const Color(0xFF0056D2),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificacionesScreen(),
                ),
              );
            },
          ),
          if (estaAutenticado) ...[
            const Divider(height: 1, indent: 50, color: Color(0xFFEEEEEE)),
            _buildListTile(
              Icons.exit_to_app,
              'Cerrar Sesión',
              color: Colors.red,
              isLogout: true,
              onTap: _mostrarDialogoCerrarSesion,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildListTile(
    IconData icon,
    String title, {
    required Color color,
    bool isLogout = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: isLogout ? Colors.red : const Color(0xFF1E1E1E),
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap ?? () {},
    );
  }
}
