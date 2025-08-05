import 'package:app_reservar_canchas/metodos_especiales/metodos_especiales_login/valida_login.dart';
import 'package:app_reservar_canchas/widgets/widgets_login/login_text_field.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Login extends StatelessWidget {
  Login({super.key});

  final emailController = TextEditingController();

  final pwController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                "assets/imagenes/fondo_login3.jpg",
              ), // Ruta de tu imagen
              fit: BoxFit.cover, // Ajusta la imagen al tamaño del contenedor
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image(
                //   image: AssetImage('assets/imagenes/fondo_login.jpg'),
                //   fit: BoxFit.contain,
                // ), //no cabe causa error de overflow
                SizedBox(height: 20),

                Text(
                  'Bienvenido !',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),

                Row(
                  children: [
                    Text('Ingresa, reserva y que empiece la potra'),
                    SizedBox(width: 10),
                    Icon(Icons.sports_soccer_rounded),
                  ],
                ),
                SizedBox(height: 30),

                LoginTextField(
                  prefixIcon: Icons.email_outlined,
                  topText: 'Correo ',
                  hintText: 'Ingrese su correo',
                  controller: emailController,
                ),

                SizedBox(height: 10),

                LoginTextField(
                  prefixIcon: Icons.lock_outline_sharp,
                  topText: 'Contraseña ',
                  hintText: 'Ingrese su contraseña',
                  activarSuffix: true,
                  controller: pwController,
                ),

                SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 20, 122, 73),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      String error = validaInicioSesion(
                        emailController.text,
                        pwController.text,
                      );

                      if (error == '') {
                        Map<String, String> data = usuarios[0];
                        context.goNamed('inicio', extra: data);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            action: SnackBarAction(
                              label: 'Cerrar',
                              onPressed: () {},
                            ),
                            content: Text(error),
                          ),
                        );
                      }
                    },
                    child: Text('Iniciar Sesión'),
                  ),
                ),

                SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(child: Divider(thickness: 2)),
                    Text(' ó ', style: TextStyle(fontWeight: FontWeight.w300)),
                    Expanded(child: Divider(thickness: 2)),
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    Text(
                      'No tienes una cuenta?  ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        context.goNamed('registro');
                      },
                      child: Text(
                        'Regístrate',
                        style: TextStyle(
                          color: Color.fromARGB(255, 20, 122, 73),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
