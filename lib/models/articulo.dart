class Articulo {
  final int id;
  final String titulo;
  final String resumen;
  final String contenido;
  final String categoria; // 'Salud', 'Trámite Social', 'Evento', 'Guía Básica'
  final String tipo; // 'educacion' o 'noticia'
  final String autor;
  final String fecha;
  final String tiempoLectura;
  final String imagenUrl;
  final String? subtituloSeccion;
  final List<String> puntosClave;

  const Articulo({
    required this.id,
    required this.titulo,
    required this.resumen,
    required this.contenido,
    required this.categoria,
    required this.tipo,
    required this.autor,
    required this.fecha,
    required this.tiempoLectura,
    required this.imagenUrl,
    this.subtituloSeccion,
    this.puntosClave = const [],
  });

  factory Articulo.fromJson(Map<String, dynamic> json) {
    return Articulo(
      id: json['id'] ?? 0,
      titulo: json['titulo'] ?? '',
      resumen: json['resumen'] ?? '',
      contenido: json['contenido'] ?? '',
      categoria: json['categoria'] ?? 'Salud',
      tipo: json['tipo'] ?? 'educacion',
      autor: json['autor'] ?? 'SMT Libre de Gluten',
      fecha: json['fecha'] ?? '',
      tiempoLectura: json['tiempoLectura'] ?? '4 min',
      imagenUrl: json['imagenUrl'] ?? '',
      subtituloSeccion: json['subtituloSeccion'],
      puntosClave: json['puntosClave'] != null
          ? List<String>.from(json['puntosClave'])
          : [],
    );
  }
}
