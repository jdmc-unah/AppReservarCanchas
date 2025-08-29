import 'package:app_reservar_canchas/controladores/validaciones_acceso_controlador.dart';
import 'package:app_reservar_canchas/estilos/colores.dart';
import 'package:app_reservar_canchas/servicios/servicio_autenticacion.dart';
import 'package:app_reservar_canchas/widgets/widgets_login/login_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class Registro extends StatelessWidget {
  Registro({super.key});
  final _auth = AuthService();
  final validacionController = Get.put<ValidacionesDeAcceso>(
    ValidacionesDeAcceso(),
  );
  final _nombre = TextEditingController();
  final _correo = TextEditingController();
  final _telefono = TextEditingController();
  final _contra = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Obx(() {
          if (validacionController.cargando) {
            return Center(
              child: CircularProgressIndicator(color: Colores.fondoPrimario),
            );
          }
          return SafeArea(
            child: ListView(
              children: [
                Column(
                  children: [
                    SizedBox(height: 20),

                    Text(
                      'Crea tu cuenta',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 30),

                LoginTextField(
                  prefixIcon: Icons.person_outline_outlined,
                  topText: 'Nombre ',
                  hintText: 'Ingrese su nombre',
                  controller: _nombre,
                ),

                SizedBox(height: 10),

                LoginTextField(
                  prefixIcon: Icons.email_outlined,
                  topText: 'Correo ',
                  hintText: 'Ingrese su correo',
                  controller: _correo,
                ),

                SizedBox(height: 10),

                LoginTextField(
                  prefixIcon: Icons.phone_outlined,
                  topText: 'Teléfono ',
                  hintText: 'Ingrese su teléfono',
                  controller: _telefono,
                ),

                SizedBox(height: 10),

                LoginTextField(
                  prefixIcon: Icons.lock_outline_sharp,
                  topText: 'Contraseña ',
                  hintText: 'Ingrese la contraseña',
                  activarSuffix: true,
                  controller: _contra,
                ),

                SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colores.fondoPrimario,
                      foregroundColor: Colores.textoSecundario,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      validacionController.cargando = true;

                      String? response;
                      response = await _auth.registroUsuario(
                        _nombre.text.trim(),
                        _correo.text.trim(),
                        _telefono.text.trim(),
                        _contra.text.trim(),
                      );

                      validacionController.cargando = false;

                      if (validacionController.error == false) {
                        if (!context.mounted) return;

                        ValidacionesDeAcceso.mostrarSnackBar(
                          context,
                          'Verificar correo',
                          'Has creado tu usuario con éxito!',
                          false,
                          () async {
                            await _auth.inicioSesionUsuario(
                              _correo.text.trim(),
                              _contra.text.trim(),
                            );

                            if (!context.mounted) return;
                            context.goNamed('verificacioncorreo');
                          },
                        );
                      } else {
                        if (!context.mounted) return;
                        ValidacionesDeAcceso.mostrarSnackBar(
                          context,
                          'Cerrar',
                          response,
                          true,
                          () {},
                        );
                      }
                    },
                    child: Text('Registrarse'),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
