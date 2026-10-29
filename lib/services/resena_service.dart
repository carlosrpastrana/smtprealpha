import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ResenaService {
  static const String _baseUrl =
      'https://devotedly-elsewhere-unlighted.ngrok-free.dev/api/Resenas';

  Future<Map<String, dynamic>> publicarResena({
    required int establecimientoId,
    required int calificacion,
    required String nivelSeguridad,
    required List<String> destacados,
    required String comentario,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioId = prefs.getInt('usuarioId');
    final bool esAnonimo =
        prefs.getBool('preferencia_resenas_anonimas') ?? false;

    if (usuarioId == null) {
      return {'exito': false, 'mensaje': 'Debes iniciar sesión.'};
    }

    try {
      final url = Uri.parse('$_baseUrl');
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'usuarioId': usuarioId,
          'establecimientoId': establecimientoId,
          'calificacion': calificacion,
          'nivelSeguridad': nivelSeguridad,
          'destacadosSeguridad': destacados,
          'comentario': comentario,
          'esAnonimo': esAnonimo, // <--- Enviado al backend
        }),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        return {'exito': true, 'mensaje': 'Reseña publicada con éxito.'};
      }
      return {'exito': false, 'mensaje': 'Error del servidor al publicar.'};
    } catch (_) {
      return {'exito': false, 'mensaje': 'Error de conexión.'};
    }
  }

  // Cambia el tipo de retorno a Future<dynamic>
  Future<dynamic> obtenerPorEstablecimiento(int establecimientoId) async {
    try {
      final url = Uri.parse('$_baseUrl/establecimiento/$establecimientoId');
      final res = await http.get(url);

      if (res.statusCode == 200) {
        return json.decode(res.body);
      }
      return {'semaforo': null, 'resenas': []};
    } catch (_) {
      return {'semaforo': null, 'resenas': []};
    }
  }

  Future<List<dynamic>> obtenerPorUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioId = prefs.getInt('usuarioId');
    if (usuarioId == null) return [];

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/usuario/$usuarioId'),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
