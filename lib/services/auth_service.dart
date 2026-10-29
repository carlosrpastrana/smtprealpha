import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // En local con emulador: usa la IP 10.0.2.2.
  // Tip: Si tu ASP.NET tiene puerto HTTP sin SSL (ej: 5030), úsalo aquí para evitar bloqueos del emulador.
  static const String _baseUrl =
      'https://devotedly-elsewhere-unlighted.ngrok-free.dev/api/Auth';

  // Iniciar Sesión con Email y Contraseña
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email.trim(), 'password': password}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        await _guardarSesion(data['usuarioId'], data['nombre'], data['email']);
        return {'exito': true, 'mensaje': data['mensaje']};
      } else {
        return {
          'exito': false,
          'mensaje': data['error'] ?? 'Credenciales incorrectas',
        };
      }
    } catch (e) {
      return {
        'exito': false,
        'mensaje': 'No se pudo conectar con el servidor ($e)',
      };
    }
  }

  // Registro con Email y Contraseña
  Future<Map<String, dynamic>> registro(
    String nombre,
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/registro'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nombreCompleto': nombre.trim(),
          'email': email.trim(),
          'password': password,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        await _guardarSesion(data['usuarioId'], data['nombre'], data['email']);
        return {'exito': true, 'mensaje': 'Cuenta creada exitosamente'};
      } else {
        return {
          'exito': false,
          'mensaje': data['error'] ?? 'Error al registrar',
        };
      }
    } catch (e) {
      return {'exito': false, 'mensaje': 'Error de conexión con el servidor'};
    }
  }

  // Login o Registro mediante Google
  Future<Map<String, dynamic>> loginConGoogle({
    required String googleId,
    required String email,
    required String nombre,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/google'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'googleId': googleId,
          'email': email,
          'nombre': nombre,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        await _guardarSesion(data['usuarioId'], data['nombre'], data['email']);
        return {'exito': true, 'mensaje': 'Bienvenido/a'};
      } else {
        return {'exito': false, 'mensaje': data['error'] ?? 'Error con Google'};
      }
    } catch (e) {
      return {
        'exito': false,
        'mensaje': 'Error al sincronizar cuenta de Google',
      };
    }
  }

  Future<void> _guardarSesion(int id, String nombre, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('usuarioId', id);
    await prefs.setString('nombre', nombre);
    await prefs.setString('email', email);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
