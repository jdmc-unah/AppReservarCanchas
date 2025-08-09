import 'package:app_reservar_canchas/controladores/validaciones_acceso_controlador.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  Future<String> iniciarSesionGoogle() async {
    try {
      final usuarioGoogle = await GoogleSignIn().signIn();
      final googleAuth = await usuarioGoogle?.authentication;
      final cred = GoogleAuthProvider.credential(
        idToken: googleAuth?.idToken,
        accessToken: googleAuth?.accessToken,
      );

      final userCred = await _auth.signInWithCredential(cred);

      if (userCred.user == null) return 'Ocurrio un error inesperado';

      validacionController.error = false;
      return userCred.user!.email.toString();
    } on FirebaseAuthException catch (e) {
      validacionController.error = true;
      return manejaExepcionFireBase(e.code);
    }
  }

  Future<void> cerrarSesion() async {
    try {
      await _auth.signOut();
      await GoogleSignIn().signOut(); // Cierra sesión de Google
      GetStorage().write('sesionIniciada', false);
      validacionController.cargando = false;
    } catch (e) {
      print('ERROR AL SALIR DE LA APP');
    }
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
