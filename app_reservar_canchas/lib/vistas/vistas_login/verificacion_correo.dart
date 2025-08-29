import 'dart:async';

import 'package:app_reservar_canchas/controladores/validaciones_acceso_controlador.dart';
import 'package:app_reservar_canchas/estilos/colores.dart';
import 'package:app_reservar_canchas/servicios/servicio_autenticacion.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class VerificacionCorreo extends StatefulWidget {
  const VerificacionCorreo({super.key});

  @override
  State<VerificacionCorreo> createState() => _VerificacionCorreoState();
}

class _VerificacionCorreoState extends State<VerificacionCorreo> {
  final _auth = AuthService();
  final validacionController = Get.put<ValidacionesDeAcceso>(
    ValidacionesDeAcceso(),
  );
  late Timer timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      enviarCorreo();
    });

    timer = Timer.periodic(Duration(seconds: 5), (timer) {
      FirebaseAuth.instance.currentUser?.reload();

      if (FirebaseAuth.instance.currentUser!.emailVerified) {
        timer.cancel();
        context.goNamed('inicio');
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

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
            child: SizedBox(
              height: 500,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Correo de Verificación',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 30),

                  Text(
                    'Revisa tu bandeja de correo y sigue los pasos para continuar',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 30),

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
                        enviarCorreo();
                      },
                      child: Text('Enviar de nuevo'),
                    ),
                  ),

                  SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colores.error,
                        foregroundColor: Colores.textoSecundario,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        timer.cancel();
                        _auth.cerrarSesion();
                        context.goNamed('login');
                      },
                      child: Text('Usar otra cuenta'),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  void enviarCorreo() async {
    validacionController.cargando = true;

    String? response = await _auth.enviarCorreoVerificacion();

    validacionController.cargando = false;

    print(validacionController.cargando);

    if (response == null) {
      if (!context.mounted) return;
      ValidacionesDeAcceso.mostrarSnackBar(
        context,
        'Cerrar',
        'El correo de verificacion se envio con éxito',
        false,
        () {},
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
  }
}
