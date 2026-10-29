import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:tucu_free_tacc/screens/informacion_personal_screen.dart';
import 'package:tucu_free_tacc/screens/cambiar_password_screen.dart';
import 'package:tucu_free_tacc/screens/idioma_screen.dart';
import 'package:tucu_free_tacc/screens/privacidad_screen.dart';
import 'package:tucu_free_tacc/screens/centro_ayuda_screen.dart';

class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({super.key});

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  String _nombre = 'Usuario';
  String _email = 'usuario@ejemplo.com';
  String _idiomaActual = 'Español';
  String _fotoPerfil =
      'https://res.cloudinary.com/qhqxqsaj/image/upload/v1790540413/sintacc_gwtetn.png';
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  Future<void> _cargarDatosUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nombre = prefs.getString('nombre') ?? 'Usuario';
      _email = prefs.getString('email') ?? 'usuario@ejemplo.com';
      _idiomaActual = prefs.getString('idioma_nombre') ?? 'Español';
      _fotoPerfil =
          prefs.getString('foto_perfil') ??
          'https://res.cloudinary.com/qhqxqsaj/image/upload/v1790540413/sintacc_gwtetn.png';
      _cargando = false;
    });
  }

  void _confirmarEliminarCuenta() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '¿Eliminar cuenta permanentemente?',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: const Text(
          'Esta acción borrará definitivamente tus reseñas comunitarias, favoritos guardados y tu perfil de seguridad del sistema.',
          style: TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await _ejecutarBajaCuenta();
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _ejecutarBajaCuenta() async {
    final prefs = await SharedPreferences.getInstance();
    final int? usuarioId = prefs.getInt('usuarioId');

    if (usuarioId == null) return;

    try {
      final url = Uri.parse(
        'https://devotedly-elsewhere-unlighted.ngrok-free.dev/api/Usuarios/$usuarioId',
      );
      final res = await http.delete(url);

      if (res.statusCode == 200 || res.statusCode == 204) {
        // Limpiar almacenamiento local por completo
        await prefs.clear();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tu cuenta ha sido eliminada con éxito'),
            backgroundColor: Color(0xFFD32F2F),
          ),
        );

        // Redirigir al inicio o pantalla principal reiniciando la pila
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo eliminar la cuenta en el servidor.'),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error de conexión al eliminar la cuenta.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0056D2)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Configuración de Cuenta',
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
              padding: const EdgeInsets.symmetric(
                horizontal: 18.0,
                vertical: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTarjetaUsuario(),
                  const SizedBox(height: 24),

                  _buildTituloSeccion('PERSONAL'),
                  const SizedBox(height: 10),
                  _buildCardGrupo([
                    _buildOpcionTile(
                      icon: Icons.person_outline,
                      titulo: 'Información Personal',
                      onTap: () async {
                        final res = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const InformacionPersonalScreen(),
                          ),
                        );
                        if (res == true) _cargarDatosUsuario();
                      },
                    ),
                    const Divider(
                      height: 1,
                      indent: 56,
                      color: Color(0xFFF0F0F0),
                    ),
                    _buildOpcionTile(
                      icon: Icons.lock_outline,
                      titulo: 'Cambiar Contraseña',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CambiarPasswordScreen(),
                          ),
                        );
                      },
                    ),
                  ]),
                  const SizedBox(height: 24),

                  _buildTituloSeccion('PREFERENCIAS'),
                  const SizedBox(height: 10),
                  _buildCardGrupo([
                    _buildOpcionTile(
                      icon: Icons.language,
                      titulo: 'Idioma',
                      subtitulo: _idiomaActual,
                      onTap: () async {
                        final res = await Navigator.push<String>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const IdiomaScreen(),
                          ),
                        );
                        if (res != null) _cargarDatosUsuario();
                      },
                    ),
                    const Divider(
                      height: 1,
                      indent: 56,
                      color: Color(0xFFF0F0F0),
                    ),
                    _buildOpcionTile(
                      icon: Icons.shield_outlined,
                      titulo: 'Privacidad',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PrivacidadScreen(),
                          ),
                        );
                      },
                    ),
                  ]),
                  const SizedBox(height: 24),

                  _buildTituloSeccion('SOPORTE'),
                  const SizedBox(height: 10),
                  _buildCardGrupo([
                    _buildOpcionTile(
                      icon: Icons.help_outline,
                      titulo: 'Centro de Ayuda',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CentroAyudaScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(
                      height: 1,
                      indent: 56,
                      color: Color(0xFFF0F0F0),
                    ),
                    _buildOpcionTile(
                      icon: Icons.description_outlined,
                      titulo: 'Términos y Condiciones',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Los términos legales se actualizarán próximamente',
                            ),
                          ),
                        );
                      },
                    ),
                  ]),
                  const SizedBox(height: 32),

                  _buildBotonEliminarCuenta(),
                  const SizedBox(height: 12),
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        'Esta acción es permanente y borrará todos tus datos de seguridad alimentaria.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildTarjetaUsuario() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD6E4FF), width: 1.5),
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFFEEF3FF),
              backgroundImage: NetworkImage(_fotoPerfil),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _nombre,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  _email,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final res = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => const InformacionPersonalScreen(),
                ),
              );
              if (res == true) _cargarDatosUsuario();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEFF4FF),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Editar',
              style: TextStyle(
                color: Color(0xFF0056D2),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTituloSeccion(String titulo) {
    return Text(
      titulo,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Color(0xFF0056D2),
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildCardGrupo(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildOpcionTile({
    required IconData icon,
    required String titulo,
    String? subtitulo,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF3FF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF0056D2), size: 20),
      ),
      title: Text(
        titulo,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E1E1E),
        ),
      ),
      subtitle: subtitulo != null
          ? Text(
              subtitulo,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            )
          : null,
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildBotonEliminarCuenta() {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFFDF2F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFCDD2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: _confirmarEliminarCuenta,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.delete_outline, color: Color(0xFFC62828), size: 20),
              SizedBox(width: 8),
              Text(
                'Eliminar Cuenta',
                style: TextStyle(
                  color: Color(0xFFC62828),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
