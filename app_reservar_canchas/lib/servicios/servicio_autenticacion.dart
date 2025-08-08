import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<User?> registroUsuario(String correo, String contra) async {
    try {
      print('${correo}, ${contra}');

      final cred = await _auth.createUserWithEmailAndPassword(
        email: correo,
        password: contra,
      );

      return cred.user;
    } on FirebaseAuthException catch (e) {
      manejarExcepciones(e.code);
    }
    return null;
  }

  Future<User?> inicioSesionUsuario(String correo, String contra) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: correo,
        password: contra,
      );

      return cred.user;
    } on FirebaseAuthException catch (e) {
      manejarExcepciones(e.code);
    }
    return null;
  }

  Future<void> cerrarSesion() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      manejarExcepciones(e.code);
    }
  }

  String? manejarExcepciones(String codigo) {
    String? error;

    switch (codigo) {
      case 'email-already-in-use':
        error = 'ERROR: Ya existe una cuenta asociada a ese correo';
        break;
      case 'invalid-email':
        error = 'ERROR: El formato del correo es incorrecto';
        break;
      case 'wrong-password':
        error = 'ERROR: La contraseña es incorrecta';
        break;
      case 'user-not-found':
        error = 'ERROR: No se encontró el usuario';
        break;
      case 'weak-password':
        error = 'ERROR: La contraseña es muy débil';
        break;
      case 'invalid-credential':
        error = 'ERROR: Credenciales incorrectas';
        break;
      case 'user-disabled':
        error =
            'ERROR: El usuario esta desactivado.\nFavor comunicarse con el administrador';
        break;
      case 'account-exists-with-different-credential':
        error = 'ERROR: La cuenta existe con otro tipo de autenticación';
        break;
      default:
        error = 'ERROR: Algo salió mal :(';
    }

    return error;
  }
}
