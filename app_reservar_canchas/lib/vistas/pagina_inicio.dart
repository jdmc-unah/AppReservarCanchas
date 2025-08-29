import 'package:app_reservar_canchas/controladores/filtro_controlador.dart';
import 'package:app_reservar_canchas/controladores/validaciones_acceso_controlador.dart';
import 'package:app_reservar_canchas/estilos/colores.dart';
import 'package:app_reservar_canchas/servicios/servicio_autenticacion.dart';
import 'package:app_reservar_canchas/servicios/servicio_firestore.dart';
import 'package:app_reservar_canchas/widgets/cancha_card.dart';
import 'package:app_reservar_canchas/widgets/filtro_menu_lateral.dart';
import 'package:app_reservar_canchas/controladores/reservas_controlador.dart';
import 'package:app_reservar_canchas/widgets/widgets_login/login_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';
import '../widgets/informacion_usuario.dart';

class PaginaInicio extends StatelessWidget {
  PaginaInicio({super.key});

  //Ingresar telefono si se registra con google
  final _auth = AuthService();
  final _fire = FirestoreService();
  final _telefono = TextEditingController();
  final _filtros = Get.find<ControladorFiltros>();

  @override
  Widget build(BuildContext context) {
    if (GetStorage().read('usuarioTelefono') == null) {
      _actualizarTelefono(context);
    }

    final reservaControlador = Get.find<ReservasControlador>();

    return Scaffold(
      appBar: AppBar(
        title: Text("Book & Play"),
        centerTitle: true,
        toolbarHeight: 72,
        actions: [informacion_usuario()],
      ),
      drawer: filtro_menu_lateral(),
      body: Obx(() {
        final _ = (
          _filtros.textoNombre.value,
          _filtros.tipo.value,
          _filtros.precioMin.value,
          _filtros.precioMax.value,
          reservaControlador.canchas.length,
        );
        final canchas = reservaControlador.canchasFiltradas;

        if (canchas.isEmpty) {
          return Center(
            child: Text(
              'No hay canchas disponibles por el momento.',
              style: TextStyle(fontSize: 18, color: Colores.fondoAlternativo),
              textAlign: TextAlign.center,
            ),
          );
        }

        return ListView.builder(
          itemCount: canchas.length,
          itemBuilder: (context, index) {
            return CanchaCard(canchaId: canchas[index].id);
          },
        );
      }),
    );
  }

  void _actualizarTelefono(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return PopScope(
            canPop: false,
            child: AlertDialog(
              title: Text('¡Bienvenido!'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LoginTextField(
                    topText: 'Ingresa tu telefono para continuar',
                    hintText: '99999999',
                    prefixIcon: Icons.phone,
                    controller: _telefono,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _auth.cerrarSesion();
                    context.goNamed('login');
                  },
                  child: Text('Salir'),
                ),
                TextButton(
                  child: Text('Aceptar'),
                  onPressed: () async {
                    //Valida telefono
                    int tel;
                    try {
                      tel = int.parse(_telefono.text);
                    } catch (e) {
                      ValidacionesDeAcceso.mostrarSnackBar(
                        context,
                        'Cerrar',
                        'El telefono debe ser solo numeros ',
                        true,
                        () {},
                      );
                      return;
                    }

                    if (_telefono.text.length != 8) {
                      ValidacionesDeAcceso.mostrarSnackBar(
                        context,
                        'Cerrar',
                        'El telefono debe ser de 8 digitos ',
                        true,
                        () {},
                      );
                      return;
                    }

                    //Actualiza firestore y variable local
                    await _fire.actualizarTelefono(tel);
                    GetStorage().write('usuarioTelefono', tel);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Color.fromARGB(255, 20, 122, 73),
                        action: null,
                        content: Text(
                          'Los datos han sido actualizados',
                          style: TextStyle(color: Colores.textoSecundario),
                        ),
                      ),
                    );

                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        },
      );
    });
  }
}
