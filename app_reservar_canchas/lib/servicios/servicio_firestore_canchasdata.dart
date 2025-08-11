import 'package:app_reservar_canchas/modelos/cancha.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  static Stream<List<Cancha>> canchasStream() => _db
      .collection('canchas')
      .snapshots()
      .map((s) => s.docs.map(Cancha.fromDoc).toList());

  /// Une todas las reservas de esa cancha y fecha y devuelve set<int> de horas ocupadas
  static Stream<Set<int>> horasOcupadasStream(
    String canchaId,
    String fechaYmd,
  ) {
    return _db
        .collection('reservas')
        .where('canchaId', isEqualTo: canchaId)
        .where('fecha', isEqualTo: fechaYmd)
        .snapshots()
        .map((snap) {
          final obtenidas = <int>{};
          for (final d in snap.docs) {
            final lista = List<int>.from(d.data()['horasReservadas'] ?? []);
            obtenidas.addAll(lista);
          }
          return obtenidas;
        });
  }

  static Future<void> crearReserva({
    required String userId,
    //required String usuarioDocId,
    required String canchaId,
    required String canchaNombre,
    required String fecha, // "YYYY-MM-DD"
    required List<int> horas, // ej: [10,11,12]
    required double total,
  }) async {
    horas.sort();
    final reservaRef = _db.collection('reservas').doc();
    await reservaRef.set({
      'userId': userId,
      //'usuarioDocId': usuarioDocId,
      'canchaId': canchaId,
      'fecha': fecha,
      'horasReservadas': horas,
      'total': total,
      'estado': 'confirmada',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _db.doc('usuarios/$userId/reservas/${reservaRef.id}').set({
      'reservaId': reservaRef.id,
      'canchaId': canchaId,
      'canchaNombre': canchaNombre,
      'fecha': fecha,
      'horasReservadas': horas,
      'horaInicio': horas[0],
      'horaFin': horas[horas.length - 1],
      'total': total,
      'estado': 'confirmada',
      'createdAt': FieldValue.serverTimestamp(),
    });
    //Agregar horas en /canchas/{id}/fechas/{fecha}
    final agendaRef = _db.doc('canchas/$canchaId/fechas/$fecha');
    await agendaRef.set({
      'horasReservadas': {
        for (final h in horas) '$h': userId, //
      },
    }, SetOptions(merge: true));
  }

  //Quitar horas reservadas
  static Future<void> liberarHoras({
    required String canchaId,
    required String fecha, // "YYYY-MM-DD"
    required List<int> horas, // ej: [10,11]
  }) async {
    final ref = _db.doc('canchas/$canchaId/fechas/$fecha');
    final updates = {
      for (final h in horas) 'horasReservadas.$h': FieldValue.delete(),
    };
    await ref.set(updates, SetOptions(merge: true));
  }

  static Future<String> crearCancha({
    required String nombre,
    required String tipo,
    required String ubicacion,
    required String telefono,
    required int horaInicio,
    required int horaFin,
    required double precio,
    required double rating, // <-- el modelo espera 'rating'
    String? url,
    String? descripcion,
  }) async {
    final ref = _db.collection('canchas').doc();
    await ref.set({
      'nombre': nombre,
      'tipo': tipo,
      'ubicacion': ubicacion,
      'telefono': telefono,
      'horaInicio': horaInicio,
      'horaFin': horaFin,
      'precio': precio,
      'rating': rating, // <-- clave alineada con tu modelo
      'url': url ?? 'urlpaginaweb',
      'descripcion': descripcion ?? '',
    });
    return ref.id;
  }
}
