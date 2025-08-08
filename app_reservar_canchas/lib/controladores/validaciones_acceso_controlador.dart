import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ValidacionesDeAcceso extends GetxController {
  //*Variables globales para validar error

  final _error = true.obs;

  set error(bool hayError) {
    _error.value = hayError;
  }

  bool get error => _error.value;

  //*
  final _cargando = false.obs;

  set cargando(bool estaCargando) {
    _cargando.value = estaCargando;
  }

  bool get cargando => _cargando.value;

  //* METODOS
  static String? validaRegistro(
    String nombre,
    String correo,
    String telefono,
    String contra,
  ) {
    Map<String, String> params = {
      'nombre': nombre,
      'correo': correo,
      'telefono': telefono,
      'contraseña': contra,
    };

    //Valida que todos los campos esten llenos
    for (var param in params.entries) {
      if (param.value.isEmpty) {
        return 'ERROR: El campo ${param.key} no puede estar vacío';
      }
    }

    //Valida longitud del telefono
    if (telefono.length != 8) {
      return 'ERROR: El teléfono debe tener 8 caracteres ';
    }

    //Valida que el telefono sean solo numeros
    try {
      int.parse(telefono);
    } catch (e) {
      return 'ERROR: El teléfono debe contener solo numeros';
    }

    //Valida longitud de contraseña
    if (contra.length < 6) {
      return 'ERROR: La contraseña debe tener al menos 6 caracteres';
    }

    //Valida que contraseña tenga al menos un caracter especial
    final RegExp regex = RegExp(r'[!@#\$%^&*(),.?":{}|<>]');

    if (!regex.hasMatch(contra)) {
      return 'ERROR: La contraseña debe tener al menos 1 caracter especial';
    }

    return null;
  }

  static String? validaInicioSesion(String correo, String contra) {
    //Valida que todos los campos esten llenos
    Map<String, String> params = {'correo': correo, 'contrasena': contra};

    for (var param in params.entries) {
      if (param.value.isEmpty) {
        return 'ERROR: El campo ${param.key} no puede estar vacío';
      }
    }

    return null;
  }

  static void mostrarSnackBar(
    BuildContext context,
    String mensaje,
    bool esError,
    VoidCallback accion,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: esError
            ? Colors.red
            : Color.fromARGB(255, 20, 122, 73),
        action: SnackBarAction(
          label: esError ? 'Cerrar' : 'Entrar a la aplicación',
          textColor: Colors.white,
          onPressed: accion,
        ),
        content: Text(mensaje, style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
