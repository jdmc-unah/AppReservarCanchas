import 'package:flutter/material.dart';

class LoginTextField extends StatefulWidget {
  const LoginTextField({
    super.key,
    required this.topText,
    required this.hintText,
    required this.prefixIcon,
    required this.controller,
    this.activarSuffix,
  });

  final String topText;
  final String hintText;
  final IconData prefixIcon;
  final TextEditingController controller;

  final bool?
  activarSuffix; //para activar/desactivar la parte que oculta o muestra la contraseña

  @override
  State<LoginTextField> createState() => _LoginTextFieldState();
}

class _LoginTextFieldState extends State<LoginTextField> {
  bool mostrarContra = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Text(
                widget.topText,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '*',
                style: TextStyle(color: const Color.fromARGB(255, 228, 21, 6)),
              ),
            ],
          ),
        ),

        TextField(
          cursorColor: Color.fromARGB(255, 20, 122, 73),
          controller: widget.controller,
          obscureText: widget.activarSuffix == true
              ? mostrarContra
              : false, //si activar suffix fuese nulo entonces por defecto va a mostrar lo que se escribe siempre
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white30,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color.fromARGB(255, 20, 122, 73)),
            ),
            hintText: widget.hintText,
            prefixIcon: Icon(widget.prefixIcon),

            suffixIcon: widget.activarSuffix == true
                ? IconButton(
                    icon: Icon(
                      mostrarContra
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),

                    onPressed: () {
                      setState(() {
                        mostrarContra = !mostrarContra;
                      });
                    },
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
