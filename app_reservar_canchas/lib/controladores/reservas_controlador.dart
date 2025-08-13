import 'package:app_reservar_canchas/controladores/filtro_controlador.dart';
import 'package:app_reservar_canchas/modelos/cancha.dart';
import 'package:app_reservar_canchas/servicios/servicio_firestore_canchasdata.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

//Controlador de estado para la gestion de canchas y reservas en la app
class ReservasControlador extends GetxController {
  final canchas = <Cancha>[].obs;

  /// horas seleccionadas por canchaId
  final _seleccion = <String, Set<int>>{}.obs;

  /// Fecha seleccionada por cada cancha en formato "YYYY-MM-DD".
  final _fecha = <String, String>{}.obs;
  //Id del documento del usuario
  final usuarioDocId = RxnString();
  late final ControladorFiltros filtros;
  // Retorna la fecha actual + [dias] en formato "YYYY-MM-DD".
  String _hoyMas(int dias) =>
      DateFormat('yyyy-MM-dd').format(DateTime.now().add(Duration(days: dias)));

  @override
  void onInit() {
    super.onInit();
    usuarioDocId.value = GetStorage().read('usuarioDocId');
    filtros = Get.put(ControladorFiltros());
    // Escucha cambios en la lista de canchas desde Firestore.
    FirestoreService.canchasStream().listen((lista) {
      canchas.assignAll(lista);
      // inicializa fecha mínima (mañana) por cancha si no existe
      for (final cancha in lista) {
        _fecha.putIfAbsent(cancha.id, () => _hoyMas(1));
        _seleccion.putIfAbsent(cancha.id, () => <int>{});
      }

      // actualizar límites de precio a partir de los datos reales
      if (canchas.isNotEmpty) {
        final precios = canchas.map((c) => c.precio.toDouble()).toList();
        double minP = precios.reduce((a, b) => a < b ? a : b);
        double maxP = precios.reduce((a, b) => a > b ? a : b);

        filtros.limiteMin = minP.floorToDouble();
        filtros.limiteMax = maxP.ceilToDouble();

        // si el usuario no ha tocado el slider, sincroniza con límites
        if (filtros.precioMin.value == 0.0 &&
            filtros.precioMax.value == 1000.0) {
          filtros.precioMin.value = filtros.limiteMin;
          filtros.precioMax.value = filtros.limiteMax;
        }
      }
    });
  }

  //Devulve la lista de canchas filtradas según nombre, tipo y rango de precio.
  List<Cancha> get canchasFiltradas {
    final q = filtros.textoNombre.value.trim().toLowerCase();
    final tipoSel = filtros.tipo.value;
    final pMin = filtros.precioMin.value;
    final pMax = filtros.precioMax.value;

    return canchas.where((c) {
      if (q.isNotEmpty && !c.nombre.toLowerCase().contains(q)) return false;
      if (tipoSel != null &&
          (c.tipo.toString().toLowerCase() != tipoSel.toLowerCase()))
        return false;
      final precio = c.precio.toDouble();
      if (precio < pMin || precio > pMax) return false;
      return true;
    }).toList();
  }

  //Obtiene la fecha seleccionada para una cancha
  // fecha actual (string YYYY-MM-DD)
  String fechaActual(String canchaId) => _fecha[canchaId] ?? _hoyMas(1);

  // Actualiza la fecha seleccionada para una cancha
  void seleccionarFecha(String canchaId, DateTime dt) {
    _fecha[canchaId] = DateFormat('yyyy-MM-dd').format(dt);
    _fecha.refresh();
  }

  // selección local
  Set<int> _getSetRO(String id) => _seleccion[id] ?? <int>{};
  // Retorna la lista de horas seleccionadas para una cancha
  List<int> obtener(String id) => _getSetRO(id).toList()..sort();

  // Agrega o quita una hora de la selección para una cancha
  void accionHora(String canchaId, int hora) {
    final s = _getSetRO(canchaId);
    if (s.contains(hora)) {
      s.remove(hora);
    } else {
      s.add(hora);
    }
    _seleccion.refresh();
  }

  // Limpia todas las horas seleccionadas para una cancha
  void limpiar(String canchaId) {
    _seleccion[canchaId] = <int>{};
    _seleccion.refresh();
  }

  // Devuelve un stream con las horas ocupadas de una cancha en la fecha seleccionada
  Stream<Set<int>> horasOcupadasStream(String canchaId) {
    final fecha = fechaActual(canchaId);
    return FirestoreService.horasOcupadasStream(canchaId, fecha);
  }

  // Crea una reserva para un usuario en una cancha con las horas seleccionadas
  // Retorna un mensaje de error en caso de problema
  Future<String?> reservar({
    required String userId,
    required Cancha cancha,
  }) async {
    final horas = obtener(cancha.id);
    if (horas.isEmpty) return 'Debes seleccionar al menos una hora';

    final fecha = fechaActual(cancha.id);
    final total = horas.length * cancha.precio;

    final uDocId = usuarioDocId.value ?? GetStorage().read('usuarioDocId');
    if (uDocId == null || (uDocId as String).isEmpty) {
      return 'Inicia sesión para reservar';
    }

    await FirestoreService.crearReserva(
      userId: uDocId,
      canchaId: cancha.id,
      canchaNombre: cancha.nombre,
      fecha: fecha,
      horas: horas,
      total: total,
      tipo: cancha.tipo,
    );

    limpiar(cancha.id);
    return null; // null, en este contexto, todo esta bien :)
  }
}
