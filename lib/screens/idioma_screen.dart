import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IdiomaScreen extends StatefulWidget {
  const IdiomaScreen({super.key});

  @override
  State<IdiomaScreen> createState() => _IdiomaScreenState();
}

class _IdiomaScreenState extends State<IdiomaScreen> {
  String _idiomaSeleccionado = 'Español';
  bool _cargando = true;

  final List<Map<String, String>> _idiomas = [
    {
      'codigo': 'es',
      'nombre': 'Español',
      'region': 'Argentina (Predeterminado)',
    },
    {'codigo': 'en', 'nombre': 'English', 'region': 'United States'},
    {'codigo': 'pt', 'nombre': 'Português', 'region': 'Brasil'},
  ];

  @override
  void initState() {
    super.initState();
    _cargarIdioma();
  }

  Future<void> _cargarIdioma() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _idiomaSeleccionado = prefs.getString('idioma_nombre') ?? 'Español';
      _cargando = false;
    });
  }

  Future<void> _seleccionarIdioma(String nombre) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('idioma_nombre', nombre);
    setState(() => _idiomaSeleccionado = nombre);

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Idioma cambiado a $nombre')));
    Navigator.pop(context, nombre);
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
          'Idioma',
          style: TextStyle(
            color: Color(0xFF0056D2),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0056D2)),
            )
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selecciona tu idioma preferido para la interfaz y los reportes de seguridad.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: _idiomas.map((item) {
                        final esSeleccionado =
                            _idiomaSeleccionado == item['nombre'];
                        return Column(
                          children: [
                            ListTile(
                              title: Text(
                                item['nombre']!,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: esSeleccionado
                                      ? const Color(0xFF0056D2)
                                      : const Color(0xFF1E1E1E),
                                ),
                              ),
                              subtitle: Text(
                                item['region']!,
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: esSeleccionado
                                  ? const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF0056D2),
                                    )
                                  : null,
                              onTap: () => _seleccionarIdioma(item['nombre']!),
                            ),
                            if (item != _idiomas.last)
                              const Divider(
                                height: 1,
                                indent: 16,
                                endIndent: 16,
                                color: Color(0xFFF0F0F0),
                              ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
