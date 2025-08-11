import 'package:app_reservar_canchas/controladores/reservas_controlador.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

    return Obx(() {
      final cancha = controller.canchas.firstWhere(
        (element) => element.id == canchaId,
      );

      //final fecha = controller.fechaActual(canchaId);
      //final horasReservadas = cancha.reservasPorFecha[fecha] ?? [];

      final seleccionadas = controller.obtener(canchaId);

      return StreamBuilder(
        stream: controller.horasOcupadasStream(canchaId),
        builder: (context, snapshot) {
          final horasReservadas = snapshot.data ?? <int>{};

          final horasDisponibles = List.generate(
            cancha.horaFin - cancha.horaInicio + 1,
            (i) => cancha.horaInicio + i,
          ).where((h) => !horasReservadas.contains(h)).toList();

          if (horasDisponibles.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: Text(
                  'No hay horas disponibles :( \n Porque no mejor otro dia?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }

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
                    onSelected: (_) => controller.accionHora(canchaId, hora),
                    selectedColor: Colors.green,
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
