import 'package:get/get.dart';

class ControladorFiltros extends GetxController {
  // Valores del filtro
  final textoNombre = ''.obs;
  final tipo = RxnString();
  final precioMin = 0.0.obs;
  final precioMax = 1000.0.obs;

  // Precios rango.
  var limiteMin = 0.0;
  var limiteMax = 1000.0;

  void limpiar() {
    textoNombre.value = '';
    tipo.value = null;
    precioMin.value = limiteMin;
    precioMax.value = limiteMax;
  }
}
