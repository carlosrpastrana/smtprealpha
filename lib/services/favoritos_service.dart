import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FavoritosService {
  static const String _baseUrl =
      'https://devotedly-elsewhere-unlighted.ngrok-free.dev/api/Favoritos';

  // Verifica si hay sesión y guarda el favorito
  Future<Map<String, dynamic>> agregarFavorito(int establecimientoId) async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioId = prefs.getInt('usuarioId');

    // Validación clave: Si no hay usuario, avisamos al frontend para que muestre el Login
    if (usuarioId == null) {
      return {'exito': false, 'requiereLogin': true};
    }

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'usuarioId': usuarioId,
          'establecimientoId': establecimientoId,
        }),
      );

      if (response.statusCode == 200) {
        return {'exito': true, 'mensaje': 'Agregado a favoritos'};
      } else {
        return {'exito': false, 'mensaje': 'Ya está en tus favoritos'};
      }
    } catch (e) {
      return {'exito': false, 'mensaje': 'Error de conexión'};
    }
  }

  // Obtener la lista completa de favoritos del usuario
  Future<List<dynamic>> obtenerFavoritos() async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioId = prefs.getInt('usuarioId');

    if (usuarioId == null) return []; // Si no hay sesión, devuelve lista vacía

    try {
      final response = await http.get(Uri.parse('$_baseUrl/$usuarioId'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // Elimina un favorito
  Future<bool> eliminarFavorito(int establecimientoId) async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioId = prefs.getInt('usuarioId');

    if (usuarioId == null) return false;

    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$usuarioId/$establecimientoId'),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
