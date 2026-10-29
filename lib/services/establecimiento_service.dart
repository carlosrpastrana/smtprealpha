import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tucu_free_tacc/models/establecimiento.dart';

class EstablecimientoService {
  // En emulador Android usar 10.0.2.2; en dispositivo físico usar la IP local o dominio final
  static const String _baseUrl =
      'https://devotedly-elsewhere-unlighted.ngrok-free.dev/api/Establecimientos';

  Future<List<Establecimiento>> obtenerRestaurantes() async {
    return _consultarApi('Restaurante');
  }

  Future<List<Establecimiento>> obtenerTiendas() async {
    return _consultarApi('Tienda');
  }

  Future<List<Establecimiento>> _consultarApi(String tipo) async {
    try {
      final url = Uri.parse('$_baseUrl?tipo=$tipo&soloActivos=true');
      final res = await http.get(url);

      if (res.statusCode == 200) {
        final List<dynamic> data = json.decode(res.body);
        return data.map((e) => Establecimiento.fromJson(e)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
