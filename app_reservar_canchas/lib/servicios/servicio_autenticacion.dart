import 'package:app_reservar_canchas/controladores/reservas_controlador.dart';
import 'package:app_reservar_canchas/controladores/validaciones_acceso_controlador.dart';
import 'package:app_reservar_canchas/modelos/usuario.dart';
import 'package:app_reservar_canchas/servicios/servicio_firestore.dart';
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
      //* Validaciones internas
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

      //* Crea el usuario en firebase con auth
      final cred = await _auth.createUserWithEmailAndPassword(
        email: correo,
        password: contra,
      );

      //* Guarda los datos en firestore
      final usr = Usuario(
        nombre: nombre,
        correo: correo,
        telefono: int.parse(telefono),
      );
      final responseFireStore = await FirestoreService().guardaPerfil(usr);
      if (responseFireStore != null) return responseFireStore;

      final docId = await FirestoreService().usuarioDocIdPorCorreo(correo);
      if (docId != null) GetStorage().write('usuarioDocId', docId);

      validacionController.error = false;
      return cred.user!.email.toString();
    } on FirebaseAuthException catch (e) {
      validacionController.error = true;
      return manejaExepcionFireBase(e.code);
    }
  }

  Future<String> inicioSesionUsuario(String correo, String contra) async {
    try {
      //* Hace validacion interna
      final errorInterno = ValidacionesDeAcceso.validaInicioSesion(
        correo,
        contra,
      );

      if (errorInterno != null) {
        validacionController.error = true;
        return errorInterno;
      }

      //* Intenta inicio de sesion
      final cred = await _auth.signInWithEmailAndPassword(
        email: correo,
        password: contra,
      );

      //* Guarda datos usuario
      final docId = await FirestoreService().usuarioDocIdPorCorreo(correo);
      Get.delete<ReservasControlador>(force: true);
      Get.put(ReservasControlador());

      await GetStorage().remove('usuarioDocId');
      if (docId != null) await GetStorage().write('usuarioDocId', docId);

      final perfil = await FirestoreService().traerPerfil(correo);
      if (perfil != null) {
        GetStorage().write('usuarioAvatar', perfil.nombre![0].toUpperCase());
        GetStorage().write('usuarioTelefono', perfil.telefono);
      }

      validacionController.error = false;
      return cred.user!.email.toString();
    } on FirebaseAuthException catch (e) {
      validacionController.error = true;
      return manejaExepcionFireBase(e.code);
    }
  }

  Future<String?> iniciarSesionGoogle() async {
    try {
      //*Login por medio de google
      final usuarioGoogle = await GoogleSignIn().signIn();

      if (usuarioGoogle == null) return null;

      final googleAuth = await usuarioGoogle.authentication;
      final cred = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      //*Trae credenciales proveidas por google
      final userCred = await _auth.signInWithCredential(cred);

      //*Guarda la data del usuario
      final userData = userCred.user;
      if (userData == null) return null;

      //*Verifica si ya se tiene guardada la data del usuario en firestore
      Usuario? usuarioExistente = await FirestoreService().traerPerfil(
        userData.email,
      );
      final Usuario newUser;
      if (usuarioExistente == null) {
        newUser = Usuario(
          nombre: userData.displayName,
          correo: userData.email,
          telefono: userCred.user!.phoneNumber != null
              ? int.parse(userCred.user!.phoneNumber!)
              : null,
        );
        //* Guarda datos en firestore
        final responseFireStore = await FirestoreService().guardaPerfil(
          newUser,
        );
        if (responseFireStore != null) return responseFireStore;
        usuarioExistente = newUser;
      }

      final docId = await FirestoreService().usuarioDocIdPorCorreo(
        userData.email!,
      );
      Get.delete<ReservasControlador>(force: true);
      Get.put(ReservasControlador());

      //* Guarda datos localmente
      await GetStorage().remove('usuarioDocId');
      if (docId != null) await GetStorage().write('usuarioDocId', docId);
      GetStorage().write('usuarioAvatar', userData.photoURL);
      GetStorage().write('usuarioTelefono', usuarioExistente.telefono);

      validacionController.error = false;
      return userCred.user!.email.toString();
    } on FirebaseAuthException catch (e) {
      validacionController.error = true;
      return manejaExepcionFireBase(e.code);
    } catch (e) {
      validacionController.error = true;
      return 'Ocurrio un error inesperado';
    }
  }

  Future<void> cerrarSesion() async {
    try {
      await _auth.signOut();
      await GoogleSignIn().signOut(); // Cierra sesión de Google
      await GetStorage().remove('usuarioDocId');
      await GetStorage().erase();
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
