import 'package:app_reservar_canchas/widgets/widgets_metodo_pago/vista_tarjeta.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';

class PaginaResumenUsuario extends StatelessWidget {
  const PaginaResumenUsuario({super.key});

  @override
  Widget build(BuildContext context) {
    final idUsuario = GetStorage().read<String>('usuarioDocId')!;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mi cuenta'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.history), text: 'Historial de reservas'),
              Tab(icon: Icon(Icons.credit_card), text: 'Métodos de pago'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _HistorialReservas(idUsuario: idUsuario),
            _MetodosPago(idUsuario: idUsuario),
          ],
        ),
      ),
    );
  }
}

class _HistorialReservas extends StatelessWidget {
  const _HistorialReservas({required this.idUsuario});
  final String idUsuario;

  IconData iconoDeporte(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'soccer':
        return Icons.sports_soccer;
      case 'basketball':
        return Icons.sports_basketball;
      case 'tenis':
        return Icons.sports_tennis;
      case 'padel':
        return Icons.sports_cricket;
      case 'volleybal':
        return Icons.sports_volleyball;
    }
    return Icons.sports;
  }

  bool _estaDisponible(Map<String, dynamic> datos, {int minutosBloqueo = 0}) {
    final estado = (datos['estado'] ?? '').toString().toLowerCase();
    if (estado == 'cancelada') return false;

    final fechaStr = (datos['fecha'] ?? '').toString().trim();
    if (fechaStr.isEmpty) return false;

    int? horaInicio = datos['horaInicio'] is int
        ? datos['horaInicio'] as int
        : null;
    if (horaInicio == null) {
      final listaHoras = (datos['horasReservadas'] ?? []) as List?;
      final horasOrdenadas = listaHoras?.whereType<int>().toList()?..sort();
      if (horasOrdenadas != null && horasOrdenadas.isNotEmpty) {
        horaInicio = horasOrdenadas.first;
      }
    }
    if (horaInicio == null) return false;

    final partes = fechaStr.split('-');
    final anio = int.parse(partes[0]);
    final mes = int.parse(partes[1]);
    final dia = int.parse(partes[2]);

    final inicioReserva = DateTime(
      anio,
      mes,
      dia,
      horaInicio,
    ).subtract(Duration(minutes: minutosBloqueo));

    return DateTime.now().isBefore(inicioReserva);
  }

  String _formatearFecha(String fecha) {
    final partes = fecha.split('-');
    return (partes.length == 3)
        ? '${partes[2]}/${partes[1]}/${partes[0]}'
        : fecha;
  }

  String _formatearHoras(Map<String, dynamic> datos) {
    final listaHoras = (datos['horasReservadas'] ?? []) as List<dynamic>;
    final horasOrdenadas = listaHoras.whereType<int>().toList()..sort();
    if (horasOrdenadas.isNotEmpty) return horasOrdenadas.join(', ');
    final hInicio = datos['horaInicio'], hFin = datos['horaFin'];
    if (hInicio != null && hFin != null) return '$hInicio–$hFin';
    if (hInicio != null) return '$hInicio';
    return '—';
  }

  @override
  Widget build(BuildContext context) {
    final consulta = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(idUsuario)
        .collection('reservas')
        .orderBy('fecha', descending: true)
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: consulta,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final documentos = snapshot.data?.docs ?? [];
        if (documentos.isEmpty) {
          return const Center(child: Text('Sin reservas registradas'));
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
          itemCount: documentos.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, indice) {
            final datos = documentos[indice].data();
            final nombreCancha = (datos['canchaNombre'] ?? '—').toString();
            final fecha = (datos['fecha'] ?? '').toString();
            final estado = (datos['estado'] ?? '—').toString();
            final total = datos['total']?.toString() ?? '—';
            final horas = _formatearHoras(datos);
            final disponible = _estaDisponible(datos);

            return Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Icon(
                          iconoDeporte(datos['tipo'] ?? ''),
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        nombreCancha,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        'Fecha: ${_formatearFecha(fecha)}  •  Horas: $horas',
                      ),
                      trailing: Chip(
                        label: Text(
                          disponible ? 'DISPONIBLE' : 'NO DISPONIBLE',
                        ),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.money, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Total: L. $total',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        Text(
                          (estado ?? 'confirmada') == 'confirmada'
                              ? "Pago confirmado"
                              : "Pago pendiente",
                          style: const TextStyle(color: Colors.black45),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class ControladorTarjetas extends GetxController {
  final idTarjetaSeleccionada = RxnString();
  void establecerTarjetaSeleccionada(String? id) =>
      idTarjetaSeleccionada.value = id;
}

class _MetodosPago extends StatelessWidget {
  final idUsuario;
  const _MetodosPago({required this.idUsuario, super.key});

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance
        .collection('tarjetas')
        .where('idUser', isEqualTo: idUsuario)
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Algo salió mal'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final documentos = snapshot.data?.docs ?? [];
        if (documentos.isEmpty) {
          return Center(
            child: ElevatedButton.icon(
              onPressed: () => context.pushNamed('agregarTarjeta'),
              icon: const Icon(Icons.add),
              label: const Text('¿Quieres agregar una tarjeta?'),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: documentos.length + 1,
          itemBuilder: (context, indice) {
            if (indice == documentos.length) {
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.pushNamed('agregarTarjeta'),
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar otra tarjeta'),
                  ),
                ),
              );
            }

            final documento = documentos[indice];
            final datos = documento.data();
            final idDocumento = documento.id;

            final numeroTarjeta = datos['numero_tarjeta'];
            final nombreTitular = datos['nombre_titular'];
            final fechaExpiracion = datos['fecha_expiracion'];
            final colorTarjeta = datos['color'];

            String enmascararNumeroTarjeta(String numero) {
              final limpio = numero.replaceAll(RegExp(r'\s+'), '');
              if (limpio.length < 4) return numero;
              final ultimos4 = limpio.substring(limpio.length - 4);
              return '**** **** **** $ultimos4';
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: CardPreviewWidget(
                      cardNumber: enmascararNumeroTarjeta(numeroTarjeta),
                      cardHolderName: nombreTitular.isEmpty
                          ? '—'
                          : nombreTitular,
                      expiryDate: fechaExpiracion.isEmpty
                          ? '—'
                          : fechaExpiracion,
                      cardColor: Color(colorTarjeta),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: IconButton(
                      tooltip: 'Eliminar tarjeta',
                      icon: const Icon(Icons.delete, color: Colors.white),
                      onPressed: () => _eliminarTarjeta(context, idDocumento),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _eliminarTarjeta(
    BuildContext context,
    String idDocumento,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmado =
        await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Eliminar tarjeta'),
            content: const Text('¿Seguro que deseas eliminar esta tarjeta?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmado) return;

    try {
      await FirebaseFirestore.instance
          .collection('tarjetas')
          .doc(idDocumento)
          .delete();
      messenger.showSnackBar(
        const SnackBar(content: Text('Tarjeta eliminada')),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
    }
  }
}
