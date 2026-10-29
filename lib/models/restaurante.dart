class Restaurante {
  final int id;
  final String nombre;
  final String puntuacion;
  final String tags;
  final String distancia; //esto es direccion por si las dudas
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
  Restaurante({
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

  // 2. Aquí agregamos el nuevo bloque factory ADENTRO de la clase
  factory Restaurante.fromJson(Map<String, dynamic> json) {
    return Restaurante(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      puntuacion: json['puntuacion'] ?? '0.0',
      distancia: json['direccion'] ?? '',
      badgeText: json['etiqueta'] ?? '',
      imagenUrl: json['imagenUrl'] ?? '',
      horarios: json['horarios'] ?? 'No especificado',
      descripcion: json['descripcion'] ?? '',
      telefono: json['telefono'] ?? '-',
      weboredes:
          json['webORedes'] ??
          '-', // Ojo aquí: Swagger suele mandarlo como webORedes con O mayúscula
      // --- CORRECCIÓN DE LA API ---
      latitud: json['latitud'] ?? '0.0',
      longitud: json['longitud'] ?? '0.0',
      // La API ahora manda tags como un texto ("Pizza • Pasta"), ya no es una lista
      tags: json['tags'] ?? '',

      // La API manda categoría como texto ("Cena • Almuerzo"), lo volvemos a convertir a lista para los filtros
      categoria:
          json['categoria'] != null && json['categoria'].toString().isNotEmpty
          ? json['categoria'].toString().split(' • ')
          : [],
    );
  }
}
