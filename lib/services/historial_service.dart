import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HistorialService {
  static const String _key = 'historial_visitas';

  static Future<void> registrarVisita({
    required int id,
    required String nombre,
    required String tipo,
    required String imagenUrl,
    required String puntuacion,
    required String subtitulo,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Si el switch de privacidad está apagado, no almacenar nada
      final bool guardar =
          prefs.getBool('preferencia_guardar_historial') ?? true;
      if (!guardar) return;

      final visitasStr = prefs.getString(_key);
      List<dynamic> lista = visitasStr != null ? json.decode(visitasStr) : [];

      // Quita la visita anterior si existía para colocarla primera
      lista.removeWhere((item) => item['id'] == id && item['tipo'] == tipo);

      lista.insert(0, {
        'id': id,
        'nombre': nombre,
        'tipo': tipo,
        'imagenUrl': imagenUrl,
        'puntuacion': puntuacion,
        'subtitulo': subtitulo,
        'fecha': DateTime.now().toIso8601String(),
      });

      if (lista.length > 10) lista = lista.sublist(0, 10);

      await prefs.setString(_key, json.encode(lista));
    } catch (_) {}
  }

  static Future<List<Map<String, dynamic>>> obtenerHistorial() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final bool guardar =
          prefs.getBool('preferencia_guardar_historial') ?? true;
      if (!guardar) return [];

      final str = prefs.getString(_key);
      if (str == null || str.isEmpty) return [];

      final List<dynamic> decoded = json.decode(str);
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }
}
