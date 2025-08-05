import 'package:app_reservar_canchas/metodos_especiales/metodos_especiales_login/valida_registro.dart';
import 'package:app_reservar_canchas/widgets/widgets_login/login_text_field.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Registro extends StatelessWidget {
  Registro({super.key});

  final userController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final pwController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SafeArea(
          child: ListView(
            children: [
              Column(
                children: [
                  SizedBox(height: 20),

                  Text(
                    'Crea tu cuenta',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              SizedBox(height: 30),

              LoginTextField(
                prefixIcon: Icons.person_outline_outlined,
                topText: 'Nombre ',
                hintText: 'Ingrese su nombre',
                controller: userController,
              ),

              SizedBox(height: 10),

              LoginTextField(
                prefixIcon: Icons.email_outlined,
                topText: 'Correo ',
                hintText: 'Ingrese su correo',
                controller: emailController,
              ),

              SizedBox(height: 10),

              LoginTextField(
                prefixIcon: Icons.phone_outlined,
                topText: 'Teléfono ',
                hintText: 'Ingrese su teléfono',
                controller: phoneController,
              ),

              SizedBox(height: 10),

              LoginTextField(
                prefixIcon: Icons.lock_outline_sharp,
                topText: 'Contraseña ',
                hintText: 'Ingrese la contraseña',
                activarSuffix: true,
                controller: pwController,
              ),

              SizedBox(height: 40),

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
                    String error = validaRegistro(
                      userController.text,
                      emailController.text,
                      phoneController.text,
                      pwController.text,
                    );

                    if (error == '') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color.fromARGB(
                            255,
                            18,
                            169,
                            56,
                          ),

                          action: SnackBarAction(
                            label: 'Continuar al login',
                            onPressed: () {
                              context.goNamed('login');
                            },
                          ),
                          content: Text(
                            'Se guardo el usuario con éxito',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.red,
                          action: SnackBarAction(
                            label: 'Cerrar',
                            onPressed: () {},
                          ),
                          content: Text(
                            error,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    }
                  },
                  child: Text('Registrarse'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
