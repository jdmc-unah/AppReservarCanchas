import 'dart:convert';
import 'package:app_reservar_canchas/modelos/cancha.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// final Map<int, List<int>> baseTemporal = {
//   1: [8, 9, 13],
//   2: [10, 14],
// };

class ReservasControlador extends GetxController {
  final canchas = <Cancha>[].obs;
  final reservasSeleccionadas = <int, List<int>>{}.obs;
  final fechasSeleccionadas = <int, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    cargarDesdeAsset();
  }

  Future<void> cargarDesdeAsset() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/canchas_test.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);
      cargarDesdeJson(jsonList);
    } catch (e) {
      print("Error al cargar JSON de canchas: $e");
    }
  }

  void cargarDesdeJson(List<dynamic> jsonList) {
    canchas.value = jsonList.map((e) => Cancha.fromJson(e)).toList();
  }

  void seleccionarFecha(int canchaId, DateTime fecha) {
    fechasSeleccionadas[canchaId] = DateFormat('yyyy-MM-dd').format(fecha);
  }

  String fechaActual(int canchaId) {
    return fechasSeleccionadas[canchaId] ??
        DateFormat('yyyy-MM-dd').format(DateTime.now().add(Duration(days: 1)));
  }

  void accionHora(int canchaId, int hora) {
    reservasSeleccionadas[canchaId] ??= [];
    final lista = reservasSeleccionadas[canchaId]!;
    if (lista.contains(hora)) {
      lista.remove(hora);
    } else {
      lista.add(hora);
    }
    reservasSeleccionadas.refresh();
  }

  void limpiar(int canchaId) {
    if (reservasSeleccionadas.containsKey(canchaId)) {
      reservasSeleccionadas[canchaId]!.clear();
      reservasSeleccionadas.refresh();
    }
  }

  List<int> obtener(int canchaId) {
    return reservasSeleccionadas[canchaId] ?? [];
  }

  // void cargarDesdeBase(int canchaId) {
  //   final horas = baseTemporal[canchaId] ?? [];
  //   reservasSeleccionadas[canchaId] = List.from(horas); // copia segura
  //   reservasSeleccionadas.refresh();
  // }
}
