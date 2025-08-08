import 'package:app_reservar_canchas/controladores/validaciones_acceso_controlador.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final validacionController = Get.put<ValidacionesDeAcceso>(
    ValidacionesDeAcceso(),
  );
  Future<String> registroUsuario(
    String nombre,
    String correo,
    String telefono,
    String contra,
  ) async {
    try {
      // print('${correo}, ${contra}');

      String? errorInterno = ValidacionesDeAcceso.validaRegistro(
        nombre,
        correo,
        telefono,
        contra,
      );

      if (errorInterno != null) {
        validacionController.error = true;
        return errorInterno;
      }

      final cred = await _auth.createUserWithEmailAndPassword(
        email: correo,
        password: contra,
      );
      validacionController.error = false;

      return cred.user!.email.toString();
    } on FirebaseAuthException catch (e) {
      validacionController.error = true;
      return manejaExepcionFireBase(e.code);
    }
  }

  Future<String> inicioSesionUsuario(String correo, String contra) async {
    try {
      //Hace validacion interna
      final errorInterno = ValidacionesDeAcceso.validaInicioSesion(
        correo,
        contra,
      );

      if (errorInterno != null) {
        validacionController.error = true;
        return errorInterno;
      }

      //Intenta inicio de sesion
      final cred = await _auth.signInWithEmailAndPassword(
        email: correo,
        password: contra,
      );

      validacionController.error = false;
      return cred.user!.email.toString();
    } on FirebaseAuthException catch (e) {
      validacionController.error = true;
      return manejaExepcionFireBase(e.code);
    }
  }

  Future<void> cerrarSesion() async {
    await _auth.signOut();
  }

  static String manejaExepcionFireBase(String codigo) {
    String error;

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
