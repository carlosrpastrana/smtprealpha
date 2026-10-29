class Establecimiento {
  final int id;
  final String nombre;
  final String puntuacion;
  final String direccion;
  final String horarios;
  final String descripcion;
  final String telefono;
  final String weboredes;
  final String badgeText;
  final String imagenUrl;
  final double? latitud;
  final double? longitud;
  final List<String> tags;
  final String categoria;
  final String tipo;
  final bool activo;

  Establecimiento({
    required this.id,
    required this.nombre,
    required this.puntuacion,
    required this.direccion,
    required this.horarios,
    required this.descripcion,
    required this.telefono,
    required this.weboredes,
    required this.badgeText,
    required this.imagenUrl,
    this.latitud,
    this.longitud,
    required this.tags,
    required this.categoria,
    required this.tipo,
    required this.activo,
  });

  factory Establecimiento.fromJson(Map<String, dynamic> json) {
    List<String> tagsParseados = [];
    if (json['tags'] != null && json['tags'].toString().isNotEmpty) {
      tagsParseados = json['tags']
          .toString()
          .split('•')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return Establecimiento(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      puntuacion: (json['puntuacion'] == null || json['puntuacion'] == '0.0')
          ? 'Nuevo'
          : json['puntuacion'],
      direccion: json['direccion'] ?? '',
      horarios: json['horarios'] ?? '',
      descripcion: json['descripcion'] ?? '',
      telefono: json['telefono'] ?? '-',
      weboredes: json['weboredes'] ?? '-',
      badgeText: json['badgeText'] ?? 'Certificado GF',
      imagenUrl: json['imagenUrl'] ?? '',
      latitud: (json['latitud'] as num?)?.toDouble(),
      longitud: (json['longitud'] as num?)?.toDouble(),
      tags: tagsParseados,
      categoria: json['categoria'] ?? '',
      tipo: json['tipo'] ?? 'Restaurante',
      activo: json['activo'] ?? true,
    );
  }
}
