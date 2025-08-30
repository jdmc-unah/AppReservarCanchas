import 'package:app_reservar_canchas/controladores/validaciones_acceso_controlador.dart';
import 'package:app_reservar_canchas/servicios/servicio_autenticacion.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';

class informacion_usuario extends StatelessWidget {
  informacion_usuario({super.key});
  int index = 0;

  final validacionController = Get.put<ValidacionesDeAcceso>(
    ValidacionesDeAcceso(),
  );

  final avatar = GetStorage().read('usuarioAvatar');

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        //El wiget PopupMenuButton nos permite mostrar un menu emergente al presionar el boton.
        child: PopupMenuButton(
          //Siguiente linea: Hace que la lista se desplace hacia abajo y no tapar el MenuBottonS
          position: PopupMenuPosition.under,
          child: avatar.toString().length == 1
              ? CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blue[50],
                  child: Text(avatar),
                )
              : CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blue[50],
                  backgroundImage: NetworkImage(avatar),
                ),

          itemBuilder: (context) => [
            //Al presionar redigire a la pantalla informacion
            PopupMenuItem(
              value: 0,
              child: Text("Informacion"),
              onTap: () => context.pushNamed('informacion'),
            ),
            //Al presionar cierra la sesion del usuario
            PopupMenuItem(
              value: 0,
              child: Text("Cerrar Sesión"),
              onTap: () async {
                await AuthService().cerrarSesion();

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
