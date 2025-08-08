import 'package:app_reservar_canchas/controladores/validaciones_acceso_controlador.dart';
import 'package:app_reservar_canchas/servicios/servicio_autenticacion.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';

class informacion_usuario extends StatelessWidget {
  informacion_usuario({super.key});

  final validacionController = Get.put<ValidacionesDeAcceso>(
    ValidacionesDeAcceso(),
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: PopupMenuButton(
          //Siguiente linea: Hace que la lista se desplace hacia abajo y no tapar el MenuBottonS
          position: PopupMenuPosition.under,
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.blue[50],
            child: Text("Hola"),
          ),
          itemBuilder: (context) => [
            PopupMenuItem(value: 0, child: Text("Informacion")),
            PopupMenuItem(
              value: 0,
              child: Text("Cerrar Sesión"),
              onTap: () async {
                await AuthService().cerrarSesion();
                GetStorage().write('sesionIniciada', false);
                validacionController.cargando = false;

                if (!context.mounted) return;
                context.goNamed('login');
              },
            ),
          ],
        ),
      ),
    );
  }
}
