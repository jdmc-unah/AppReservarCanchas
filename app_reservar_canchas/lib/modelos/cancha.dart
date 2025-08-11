import 'package:cloud_firestore/cloud_firestore.dart';

class Cancha {
  final String id;
  final String nombre;
  final int horaInicio;
  final int horaFin;
  final double precio;
  final String ubicacion;
  final double rating;
  final String url;
  final String tipo;
  final String descripcion;
  Cancha({
    required this.id,
    required this.nombre,
    required this.horaInicio,
    required this.horaFin,
    required this.precio,
    required this.ubicacion,
    required this.rating,
    required this.url,
    required this.tipo,
    required this.descripcion,
  });

  factory Cancha.fromDoc(DocumentSnapshot documento) {
    final data = (documento.data() as Map<String, dynamic>? ?? {});

    //VALIDACIONES
    int toInt(dynamic valor, {int def = 0}) {
      if (valor == null) return def;
      if (valor is int) return valor;
      if (valor is double) return valor.toInt();
      if (valor is String) return int.tryParse(valor) ?? def;
      return def;
    }

    double toDouble(dynamic valor, {double def = 0}) {
      if (valor == null) return def;
      if (valor is double) return valor;
      if (valor is int) return valor.toDouble();
      if (valor is String) return double.tryParse(valor) ?? def;
      return def;
    }

    return Cancha(
      id: documento.id,
      nombre: (data['nombre'] ?? 'Sin nombre') as String,
      horaInicio: toInt(data['horaInicio'], def: 0),
      horaFin: toInt(data['horaFin'], def: 23),
      precio: toDouble(data['precio'], def: 0),
      ubicacion: (data['ubicacion'] ?? '') as String,
      // usa 'calificacion' si existe, si no 'rating'; default 0.0
      rating: toDouble(data['calificacion'] ?? data['rating'] ?? 0),
      url: data['url'],
      tipo: data['tipo'],
      descripcion: data['descripcion'],
    );
  }
}
