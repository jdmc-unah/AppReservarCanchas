import 'package:app_reservar_canchas/widgets/cancha_card.dart';
import 'package:app_reservar_canchas/widgets/filtro_menu_lateral.dart';
import 'package:app_reservar_canchas/controladores/reservas_controlador.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/informacion_usuario.dart';

class PaginaInicio extends StatelessWidget {
  const PaginaInicio({super.key});

  @override
  Widget build(BuildContext context) {
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
        final canchas = reservaControlador.canchas;

        if (canchas.isEmpty) {
          return Center(
            child: Text(
              'No hay canchas disponibles por el momento.',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
          );
        }

        return ListView.builder(
          itemCount: canchas.length,
          itemBuilder: (context, index) {
            return CanchaCard(canchaId: canchas[index].canchaId);
          },
        );
      }),
    );
  }
}
