import 'package:app_reservar_canchas/controladores/validaciones_acceso_controlador.dart';
import 'package:app_reservar_canchas/estilos/colores.dart';
import 'package:app_reservar_canchas/servicios/servicio_autenticacion.dart';
import 'package:app_reservar_canchas/widgets/widgets_login/login_text_field.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ReiniciarContra extends StatelessWidget {
  ReiniciarContra({super.key});

  final _auth = AuthService();
  final _correo = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Reiniciar Contraseña',
                      textAlign: TextAlign.start,

                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Divider(),
                    ),

                    Text(
                      'Por favor ingresa tu correo para establecer una nueva contraseña',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
                    ),

                    LoginTextField(
                      prefixIcon: Icons.email_outlined,
                      topText: '',
                      hintText: 'micorreo@dominio.com',
                      activarSuffix: false,
                      controller: _correo,
                    ),

                    SizedBox(height: 30),

                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colores.fondoPrimario,
                          foregroundColor: Colores.textoSecundario,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          String? response = await _auth.enviarReinicioContra(
                            _correo.text,
                          );

                          if (response == null) {
                            if (!context.mounted) return;
                            ValidacionesDeAcceso.mostrarSnackBar(
                              context,
                              'Volver al login',
                              'El correo se envió con éxito',
                              false,
                              () {
                                context.pop();
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
                        child: Text('Enviar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
