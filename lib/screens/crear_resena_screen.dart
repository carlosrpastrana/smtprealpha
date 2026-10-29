import 'package:flutter/material.dart';
import 'package:tucu_free_tacc/models/establecimiento.dart';
import 'package:tucu_free_tacc/services/resena_service.dart';
import 'package:tucu_free_tacc/screens/resena_confirmacion_screen.dart';

class CrearResenaScreen extends StatefulWidget {
  final Establecimiento? restaurante;
  final Establecimiento? comercio;

  const CrearResenaScreen({super.key, this.restaurante, this.comercio})
    : assert(
        restaurante != null || comercio != null,
        'Debes enviar un restaurante o un comercio',
      );

  @override
  State<CrearResenaScreen> createState() => _CrearResenaScreenState();
}

class _CrearResenaScreenState extends State<CrearResenaScreen> {
  final _comentarioController = TextEditingController();
  final _resenaService = ResenaService();

  int _calificacion = 0;
  String _nivelSeguridad = '';
  final List<String> _destacadosSeleccionados = [];
  bool _enviando = false;

  // Getters unificados
  int get _establecimientoId =>
      widget.restaurante?.id ?? widget.comercio?.id ?? 0;
  String get _nombre =>
      widget.restaurante?.nombre ?? widget.comercio?.nombre ?? '';
  String get _imagenUrl =>
      widget.restaurante?.imagenUrl ?? widget.comercio?.imagenUrl ?? '';
  String get _direccion =>
      widget.restaurante?.direccion ?? widget.comercio?.direccion ?? '';

  final List<Map<String, dynamic>> _opcionesDestacados = [
    {'label': 'Menú Identificado', 'icon': Icons.menu_book_outlined},
    {'label': 'Personal Capacitado', 'icon': Icons.groups_outlined},
    {'label': 'Opciones Sin TACC', 'icon': Icons.check_circle_outline},
    {'label': 'Cocina Separada', 'icon': Icons.kitchen_outlined},
  ];

  void _alternarDestacado(String valor) {
    setState(() {
      if (_destacadosSeleccionados.contains(valor)) {
        _destacadosSeleccionados.remove(valor);
      } else {
        _destacadosSeleccionados.add(valor);
      }
    });
  }

  void _enviarResena() async {
    if (_calificacion == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor, califica con estrellas la experiencia general',
          ),
        ),
      );
      return;
    }

    if (_nivelSeguridad.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona el nivel de seguridad celíaca'),
        ),
      );
      return;
    }

    setState(() => _enviando = true);

    final resultado = await _resenaService.publicarResena(
      establecimientoId: _establecimientoId,
      calificacion: _calificacion,
      nivelSeguridad: _nivelSeguridad,
      destacados: _destacadosSeleccionados,
      comentario: _comentarioController.text.trim(),
    );

    setState(() => _enviando = false);

    if (!mounted) return;

    if (resultado['exito'] == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResenaConfirmacionScreen(
            nombre: _nombre,
            imagenUrl: _imagenUrl,
            calificacion: _calificacion,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado['mensaje'] ?? 'Ocurrió un error'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0056D2)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Añadir Reseña',
          style: TextStyle(
            color: Color(0xFF0056D2),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera del local
            Container(
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
                      _imagenUrl.isNotEmpty
                          ? _imagenUrl
                          : 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=200&q=80',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      cacheWidth: 150,
                      cacheHeight: 150,
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
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Color(0xFF0056D2),
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _direccion,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
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
            ),
            const SizedBox(height: 24),

            // Experiencia General
            const Text(
              'EXPERIENCIA GENERAL',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final estrella = index + 1;
                  return IconButton(
                    iconSize: 34,
                    icon: Icon(
                      estrella <= _calificacion
                          ? Icons.star
                          : Icons.star_border,
                      color: const Color(0xFF0056D2),
                    ),
                    onPressed: () => setState(() => _calificacion = estrella),
                  );
                }),
              ),
            ),
            const SizedBox(height: 24),

            // Seguridad Celíaca
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF3FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.security, color: Color(0xFFD9531E), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'SEGURIDAD CELÍACA',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFF1E1E1E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '¿Cómo calificarías el protocolo y conocimiento del personal?',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 14),
                  _buildBotonSeguridad(
                    'Contaminacion cruzada',
                    isWarning: true,
                  ),
                  const SizedBox(height: 8),
                  _buildBotonSeguridad('Normal'),
                  const SizedBox(height: 8),
                  _buildBotonSeguridad('Excelente'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Destacados de Seguridad
            const Text(
              'DESTACADOS DE SEGURIDAD',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 10,
              children: _opcionesDestacados.map((item) {
                final bool seleccionado = _destacadosSeleccionados.contains(
                  item['label'],
                );
                return GestureDetector(
                  onTap: () => _alternarDestacado(item['label']),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: seleccionado
                          ? const Color(0xFF0056D2).withOpacity(0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: seleccionado
                            ? const Color(0xFF0056D2)
                            : Colors.grey.shade300,
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item['icon'] as IconData,
                          size: 16,
                          color: seleccionado
                              ? const Color(0xFF0056D2)
                              : Colors.black87,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item['label'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: seleccionado
                                ? const Color(0xFF0056D2)
                                : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Comentario
            const Text(
              'TU EXPERIENCIA',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _comentarioController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    'Cuéntanos sobre los productos, la atención y la seguridad...',
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Botón Publicar
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _enviando ? null : _enviarResena,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0056D2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _enviando
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Publicar Reseña',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.send_outlined,
                            size: 18,
                            color: Colors.white,
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBotonSeguridad(String texto, {bool isWarning = false}) {
    final bool seleccionado = _nivelSeguridad == texto;
    Color bordeColor = Colors.grey.shade300;
    Color fondoColor = Colors.white;
    Color textoColor = Colors.black87;

    if (seleccionado) {
      if (isWarning) {
        bordeColor = Colors.redAccent;
        fondoColor = Colors.red.shade50;
        textoColor = Colors.redAccent.shade700;
      } else {
        bordeColor = const Color(0xFF0056D2);
        fondoColor = const Color(0xFF0056D2).withOpacity(0.08);
        textoColor = const Color(0xFF0056D2);
      }
    }

    return GestureDetector(
      onTap: () => setState(() => _nivelSeguridad = texto),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: fondoColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: bordeColor, width: 1.2),
        ),
        child: Text(
          texto,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: textoColor,
          ),
        ),
      ),
    );
  }
}
