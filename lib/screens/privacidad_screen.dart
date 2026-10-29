import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tucu_free_tacc/services/historial_service.dart';

class PrivacidadScreen extends StatefulWidget {
  const PrivacidadScreen({super.key});

  @override
  State<PrivacidadScreen> createState() => _PrivacidadScreenState();
}

class _PrivacidadScreenState extends State<PrivacidadScreen> {
  bool _resenasAnonimas = false;
  bool _guardarHistorial = true;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarPreferencias();
  }

  Future<void> _cargarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _resenasAnonimas = prefs.getBool('preferencia_resenas_anonimas') ?? false;
      _guardarHistorial =
          prefs.getBool('preferencia_guardar_historial') ?? true;
      _cargando = false;
    });
  }

  Future<void> _actualizarResenasAnonimas(bool valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('preferencia_resenas_anonimas', valor);
    setState(() => _resenasAnonimas = valor);
  }

  Future<void> _actualizarGuardarHistorial(bool valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('preferencia_guardar_historial', valor);
    setState(() => _guardarHistorial = valor);
  }

  Future<void> _borrarHistorialReciente() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('historial_visitas');

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Historial de visitas eliminado de este dispositivo'),
        backgroundColor: Color(0xFF0056D2),
      ),
    );
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
          'Privacidad y Datos',
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
                  _buildTituloSeccion('VISIBILIDAD EN LA COMUNIDAD'),
                  const SizedBox(height: 10),
                  _buildCardGrupo([
                    SwitchListTile.adaptive(
                      value: _resenasAnonimas,
                      activeColor: const Color(0xFF0056D2),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF3FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.visibility_off_outlined,
                          color: Color(0xFF0056D2),
                          size: 20,
                        ),
                      ),
                      title: const Text(
                        'Publicar reseñas de forma anónima',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E1E1E),
                        ),
                      ),
                      subtitle: const Padding(
                        padding: EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Tus valoraciones aparecerán como "Usuario Anónimo" ante el resto de la comunidad. Tu aporte seguirá protegiendo el semáforo.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            height: 1.35,
                          ),
                        ),
                      ),
                      onChanged: _actualizarResenasAnonimas,
                    ),
                  ]),

                  const SizedBox(height: 26),

                  _buildTituloSeccion('HISTORIAL EN EL DISPOSITIVO'),
                  const SizedBox(height: 10),
                  _buildCardGrupo([
                    SwitchListTile.adaptive(
                      value: _guardarHistorial,
                      activeColor: const Color(0xFF0056D2),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF3FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.history_toggle_off_outlined,
                          color: Color(0xFF0056D2),
                          size: 20,
                        ),
                      ),
                      title: const Text(
                        'Guardar lugares explorados',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E1E1E),
                        ),
                      ),
                      subtitle: const Padding(
                        padding: EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Registra en la memoria local de tu teléfono los restaurantes y tiendas que visitas para mostrarlos en la sección "Actividad Reciente" de tu perfil.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            height: 1.35,
                          ),
                        ),
                      ),
                      onChanged: _actualizarGuardarHistorial,
                    ),
                    const Divider(
                      height: 1,
                      indent: 56,
                      color: Color(0xFFF0F0F0),
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1F0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.delete_sweep_outlined,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                      ),
                      title: const Text(
                        'Borrar historial de visitas',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                      ),
                      subtitle: const Text(
                        'Elimina la lista de locales visualizados recientemente.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      onTap: _borrarHistorialReciente,
                    ),
                  ]),

                  const SizedBox(height: 28),

                  // Mensaje de transparencia
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4FF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFD6E4FF)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(
                          Icons.shield_outlined,
                          color: Color(0xFF0056D2),
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'En SMT Libre de Gluten tus datos de contacto nunca son compartidos con comercios ni gastronómicos. Las alertas de contaminación cruzada se procesan de manera agregada para velar por la salud comunitaria.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF1E3A8A),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTituloSeccion(String titulo) {
    return Text(
      titulo,
      style: const TextStyle(
        fontSize: 12,
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
}
