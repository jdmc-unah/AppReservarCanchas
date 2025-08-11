import 'package:app_reservar_canchas/modelos/cancha.dart';
import 'package:app_reservar_canchas/servicios/servicio_firestore_canchasdata.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

class ReservasControlador extends GetxController {
  final canchas = <Cancha>[].obs;

  /// horas seleccionadas por canchaId
  final _seleccion = <String, Set<int>>{}.obs;

  /// fecha por canchaId ("YYYY-MM-DD")
  final _fecha = <String, String>{}.obs;
  final usuarioDocId = RxnString();

  String _hoyMas(int dias) =>
      DateFormat('yyyy-MM-dd').format(DateTime.now().add(Duration(days: dias)));

  @override
  void onInit() {
    super.onInit();
    usuarioDocId.value = GetStorage().read('usuarioDocId');
    // cargar canchas
    FirestoreService.canchasStream().listen((lista) {
      canchas.assignAll(lista);
      // inicializa fecha mínima (mañana) por cancha si no existe
      for (final cancha in lista) {
        _fecha.putIfAbsent(cancha.id, () => _hoyMas(1));
        _seleccion.putIfAbsent(cancha.id, () => <int>{});
      }
    });
  }

  // fecha actual (string YYYY-MM-DD)
  String fechaActual(String canchaId) => _fecha[canchaId] ?? _hoyMas(1);
  void seleccionarFecha(String canchaId, DateTime dt) {
    _fecha[canchaId] = DateFormat('yyyy-MM-dd').format(dt);
    _fecha.refresh();
  }

  // selección local
  Set<int> _getSetRO(String id) => _seleccion[id] ?? <int>{};
  List<int> obtener(String id) => _getSetRO(id).toList()..sort();

  void accionHora(String canchaId, int hora) {
    final s = _getSetRO(canchaId);
    if (s.contains(hora)) {
      s.remove(hora);
    } else {
      s.add(hora);
    }
    _seleccion.refresh();
  }

  void limpiar(String canchaId) {
    _seleccion[canchaId] = <int>{};
    _seleccion.refresh();
  }

  Stream<Set<int>> horasOcupadasStream(String canchaId) {
    final fecha = fechaActual(canchaId);
    return FirestoreService.horasOcupadasStream(canchaId, fecha);
  }

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
    );

    limpiar(cancha.id);
    return null; // null = ok
  }
}
