class Comercio {
  final int id;
  final String nombre;
  final String puntuacion;
  final String tags;
  final String distancia;
  final String badgeText;
  final String imagenUrl;
  final List<String> categoria;
  final String descripcion; // Nueva propiedad opcional
  final String horarios; // Nueva propiedad opcional
  final String telefono; // Nueva propiedad opcional
  final String weboredes; // Nueva propiedad opcional
  final String latitud; // Nueva propiedad opcional
  final String longitud; // Nueva propiedad opcional

  // 1. El constructor original se mantiene intacto
  Comercio({
    required this.id,
    required this.nombre,
    required this.puntuacion,
    required this.tags,
    required this.distancia,
    required this.badgeText,
    required this.imagenUrl,
    required this.categoria,
    required this.descripcion,
    required this.horarios,
    required this.telefono,
    required this.weboredes,
    required this.latitud,
    required this.longitud,
  });

  // Este "factory" toma el mapa del JSON y construye un objeto Restaurante
  factory Comercio.fromJson(Map<String, dynamic> json) {
    return Comercio(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      puntuacion: json['puntuacion'] ?? '0.0',
      distancia: json['direccion'] ?? '',
      badgeText: json['etiqueta'] ?? '',
      imagenUrl: json['imagenUrl'] ?? '',
      horarios: json['horarios'] ?? 'No especificado',
      descripcion: json['descripcion'] ?? '',
      telefono: json['telefono'] ?? '-',
      weboredes: json['webORedes'] ?? '-',
      latitud: json['latitud'] ?? '0.0',
      longitud: json['longitud'] ?? '0.0',

      // --- CORRECCIÓN DE LA API ---
      tags: json['tags'] ?? '',
      categoria:
          json['categoria'] != null && json['categoria'].toString().isNotEmpty
          ? json['categoria'].toString().split(' • ')
          : [],
    );
  }
}
