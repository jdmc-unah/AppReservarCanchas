class Usuario {
  String? nombre;
  String? correo;
  int? telefono;

  Usuario({required this.nombre, required this.correo, required this.telefono});

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
    nombre: json["nombre"],
    correo: json["correo"],
    telefono: json["telefono"],
  );

  Map<String, dynamic> toJson() => {
    "nombre": nombre,
    "correo": correo,
    "telefono": telefono,
  };
}
