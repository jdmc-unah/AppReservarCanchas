import 'package:app_reservar_canchas/controladores/reservas_controlador.dart';
import 'package:app_reservar_canchas/estilos/colores.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Lo siguiente nos permite mostras una lista de opciones de forma horizontal
// En este caso se trata de las horas disponibles
// Que a su vez nos permite hacer una seleccion de las mismas.
class ListaHoras extends StatelessWidget {
  //Variable que contiene las horas que han sido reservadas.
  // final List<int> horasReservadas;

  final String canchaId;

  const ListaHoras({
    super.key,
    required this.canchaId,
    // required this.horasReservadas,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReservasControlador>();

    // final horasDisponibles = List.generate(
    //   24,
    //   (i) => i,
    // ).where((h) => !horasReservadas.contains(h)).toList();
    // return Obx(() {
    //   final seleccionadas = controller.obtener(canchaId);

    //Obtenemos la informacion de la cancha correspondiente al ID.
    return Obx(() {
      final cancha = controller.canchas.firstWhere(
        (element) => element.id == canchaId,
      );

      //final fecha = controller.fechaActual(canchaId);
      //final horasReservadas = cancha.reservasPorFecha[fecha] ?? [];

      //Esta variable nos permite obtener las horas que han sido seleccionadas actualmente
      final seleccionadas = controller.obtener(canchaId);

      //Este nos permite escuchar las horas en tiempo real
      return StreamBuilder(
        stream: controller.horasOcupadasStream(canchaId),
        builder: (context, snapshot) {
          final horasReservadas = snapshot.data ?? <int>{};
          //Calcula y devuelve las horas disponibles
          final horasDisponibles = List.generate(
            cancha.horaFin - cancha.horaInicio + 1,
            (i) => cancha.horaInicio + i,
          ).where((h) => !horasReservadas.contains(h)).toList();

          //En caso de no tener horas disponibles muestra un mensaje
          if (horasDisponibles.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: Text(
                  'No hay horarios disponibles :( \n        Prueba elegir otro día',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colores.bordeSecundario,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }
          // Nos devuelve la lista horizonal de horas disponibles
          return SizedBox(
            height: 50,
            child: ListView.builder(
              itemCount: horasDisponibles.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final hora = horasDisponibles[index];
                final isSelected = seleccionadas.contains(hora);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text("${hora}:00"),
                    selected: isSelected,
                    labelStyle: TextStyle(color: Colores.fondoComplementoN),
                    onSelected: (_) => controller.accionHora(canchaId, hora),
                    selectedColor: Colores.fondoSecundario,
                    checkmarkColor: Colores.fondoPrimario,
                  ),
                );
              },
            ),
          );
        },
      );
    });
  }
}
