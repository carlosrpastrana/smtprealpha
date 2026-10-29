import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({super.key});

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  // Canales de comunicación
  bool _notificacionesPush = true;
  bool _correosElectronicos = false;

  // Categorías de alertas
  bool _nuevosLocales = true;
  bool _alertasContaminacion = true; // Por defecto encendida por seguridad
  bool _nuevosArticulos = false;

  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarPreferencias();
  }

  Future<void> _cargarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificacionesPush = prefs.getBool('notif_push') ?? true;
      _correosElectronicos = prefs.getBool('notif_email') ?? false;
      _nuevosLocales = prefs.getBool('alerta_locales') ?? true;
      _alertasContaminacion = prefs.getBool('alerta_contaminacion') ?? true;
      _nuevosArticulos = prefs.getBool('alerta_articulos') ?? false;
      _cargando = false;
    });
  }

  Future<void> _guardarPreferencia(String key, bool valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, valor);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0056D2)),
          onPressed: () => Navigator.pop(context),
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
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0056D2)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notificaciones',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Controla cómo y cuándo quieres recibir actualizaciones.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // BLOQUE 1: Canales de Comunicación
                  _buildCardCanales(),

                  const SizedBox(height: 28),

                  // BLOQUE 2: Categorías de Alertas
                  const Text(
                    'Categorías de Alertas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildCardCategorias(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildCardCanales() {
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
      child: Stack(
        children: [
          // Borde decorativo azul lateral izquierdo
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 5,
              decoration: const BoxDecoration(
                color: Color(0xFF0056D2),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(
                      Icons.campaign_outlined,
                      color: Color(0xFF0056D2),
                      size: 22,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Canales de Comunicación',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Switch Push
                _buildSwitchRow(
                  icon: Icons.phone_android_outlined,
                  titulo: 'Notificaciones Push',
                  subtitulo: 'Recibe alertas directamente en tu dispositivo.',
                  valor: _notificacionesPush,
                  activeColor: const Color(0xFF0056D2),
                  onChanged: (val) {
                    setState(() => _notificacionesPush = val);
                    _guardarPreferencia('notif_push', val);
                  },
                ),

                const Divider(height: 24, color: Color(0xFFEEEEEE)),

                // Switch Email
                _buildSwitchRow(
                  icon: Icons.email_outlined,
                  titulo: 'Correos Electrónicos',
                  subtitulo: 'Resúmenes semanales y boletines importantes.',
                  valor: _correosElectronicos,
                  activeColor: const Color(0xFF0056D2),
                  onChanged: (val) {
                    setState(() => _correosElectronicos = val);
                    _guardarPreferencia('notif_email', val);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardCategorias() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Nuevos locales
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildSwitchRow(
              icon: Icons.storefront_outlined,
              iconColor: const Color(0xFFE65100),
              titulo: 'Nuevos locales',
              subtitulo:
                  'Te avisamos cuando un local certificado sin gluten abra cerca de ti.',
              valor: _nuevosLocales,
              activeColor: const Color(0xFF0056D2),
              onChanged: (val) {
                setState(() => _nuevosLocales = val);
                _guardarPreferencia('alerta_locales', val);
              },
            ),
          ),

          // Alertas de contaminación (Caja diferenciada con fondo rojo suave)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF6F6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFD5D2)),
            ),
            child: _buildSwitchRow(
              icon: Icons.warning_amber_rounded,
              iconColor: const Color(0xFFD32F2F),
              titulo: 'Alertas de Contaminación Cruzada',
              tituloColor: const Color(0xFFD32F2F),
              subtitulo:
                  'Avisos urgentes sobre productos retirados o reportes comunitarios.',
              valor: _alertasContaminacion,
              activeColor: const Color(0xFFD32F2F),
              onChanged: (val) {
                setState(() => _alertasContaminacion = val);
                _guardarPreferencia('alerta_contaminacion', val);
              },
            ),
          ),

          // Nuevos artículos educativos
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildSwitchRow(
              icon: Icons.menu_book_outlined,
              iconColor: const Color(0xFF0056D2),
              titulo: 'Nuevos Artículos Educativos',
              subtitulo:
                  'Consejos de nutrición, recetas y guías de estilo de vida.',
              valor: _nuevosArticulos,
              activeColor: const Color(0xFF0056D2),
              onChanged: (val) {
                setState(() => _nuevosArticulos = val);
                _guardarPreferencia('alerta_articulos', val);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow({
    required IconData icon,
    Color? iconColor,
    required String titulo,
    Color? tituloColor,
    required String subtitulo,
    required bool valor,
    required Color activeColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: Icon(icon, color: iconColor ?? Colors.grey.shade700, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: tituloColor ?? const Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitulo,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Switch(
          value: valor,
          activeColor: Colors.white,
          activeTrackColor: activeColor,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: Colors.grey.shade300,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
