import 'dart:io';

import 'package:app_reservar_canchas/modelos/usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final _fire = FirebaseFirestore.instance;

  Future<String?> guardaPerfil(Usuario usr) async {
    try {
      await _fire.collection("usuarios").add(usr.toJson());

      // nuevoUsuario.id; //para ver el id del nuevo usuario creado
      return null;
    } on FirebaseException catch (e) {
      return 'Error de Firebase: ${e.message}';
    } on SocketException {
      return 'Sin conexión a internet';
    } catch (e) {
      return 'Error inesperado: $e';
    }
  }

  Future<Usuario?> traerPerfil(String? correo) async {
    final snapshot = await _fire
        .collection("usuarios")
        .where('correo', isEqualTo: correo)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return Usuario.fromJson(snapshot.docs[0].data());
    }

    return null;
  }
}
