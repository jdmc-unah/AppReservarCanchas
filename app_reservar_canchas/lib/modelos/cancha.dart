class Cancha {
  final int canchaId;
  final String nombre;
  final Map<String, List<int>> reservasPorFecha;
  String fechaSeleccionada;
  final int horaInicio;
  final int horaFin;
  final int precio;
  final String ubicacion;
  final double rating;
  Cancha({
    required this.canchaId,
    required this.nombre,
    required this.reservasPorFecha,
    this.fechaSeleccionada = '',
    required this.horaInicio,
    required this.horaFin,
    required this.precio,
    required this.ubicacion,
    required this.rating,
  });

  factory Cancha.fromJson(Map<String, dynamic> json) {
    final bruto = Map<String, dynamic>.from(json['horasReservadas']);

    final reservasMapa = bruto.map(
      (fecha, lista) => MapEntry(fecha, List<int>.from(lista)),
    );

    return Cancha(
      canchaId: json["id"],
      nombre: json["nombre"],
      reservasPorFecha: reservasMapa,
      fechaSeleccionada: reservasMapa.keys.isNotEmpty
          ? reservasMapa.keys.first
          : "", // valor inicial por defecto si hay fechas
      horaInicio: json["horaInicio"] ?? 0,
      horaFin: json["horaFin"] ?? 23,
      precio: json["precio"],
      ubicacion: json["ubicacion"],
      rating: (json["rating"] as num).toDouble(),
    );
  }
}
