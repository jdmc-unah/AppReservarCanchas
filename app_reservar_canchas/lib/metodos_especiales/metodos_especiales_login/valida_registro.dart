String validaRegistro(
  String nombre,
  String correo,
  String telefono,
  String contra,
) {
  //Valida que todos los campos esten llenos
  Map<String, String> params = {
    'nombre': nombre,
    'correo': correo,
    'telefono': telefono,
    'contrasena': contra,
  };

  for (var param in params.entries) {
    if (param.value.isEmpty) {
      return 'ERROR: El campo ${param.key} no puede estar vacío';
    }
  }

  //Valida longitud del correo
  if (correo.length < 10) {
    return 'ERROR: El correo debe tener mas de 10 caracteres ';
  }

  //Valida longitud del correo
  if (telefono.length < 8) {
    return 'ERROR: El teléfono debe tener mas de 10 caracteres ';
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

  return '';
}
