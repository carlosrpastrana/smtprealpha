import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tucu_free_tacc/models/articulo.dart';

class ArticuloService {
  static const String _baseUrl =
      'https://devotedly-elsewhere-unlighted.ngrok-free.dev/api/Articulos';

  Future<List<Articulo>> obtenerArticulos({
    String? categoria,
    String? tipo,
  }) async {
    try {
      final uri = Uri.parse(_baseUrl).replace(
        queryParameters: {
          if (categoria != null && categoria != 'Todos') 'categoria': categoria,
          if (tipo != null) 'tipo': tipo,
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((jsonItem) => Articulo.fromJson(jsonItem)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
