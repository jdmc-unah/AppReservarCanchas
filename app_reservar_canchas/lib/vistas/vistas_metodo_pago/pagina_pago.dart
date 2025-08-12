import 'package:app_reservar_canchas/controladores/reservas_controlador.dart';
import 'package:app_reservar_canchas/modelos/cancha.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_reservar_canchas/vistas/vistas_metodo_pago/agregar_tarjeta.dart';
import 'package:app_reservar_canchas/widgets/widgets_metodo_pago/widget_tarjeta.dart';
import 'package:app_reservar_canchas/controladores/metodo_pago/controlador_tarjeta.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';

class PaymentMethodsPage extends StatelessWidget {
  final Cancha? cancha;
  final ReservasControlador? reservasControlador;
  PaymentMethodsPage({this.cancha, this.reservasControlador, Key? key})
    : super(key: key);
  final PaymentController controller = Get.put(PaymentController());

  void _showSnackBar(
    BuildContext context,
    String message, {
    Color color = Colors.black,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handlePayment(BuildContext context) async {
    if (controller.selectedCardId == null) {
      _showSnackBar(
        context,
        'Debe seleccionar una tarjeta.',
        color: Colors.red,
      );
    } else {
      _showSnackBar(
        context,
        'El pago a sido realizado con exito.',
        color: Colors.green,
      );

      final ReservasControlador reservasControlador =
          Get.find<ReservasControlador>();
      final error = await reservasControlador.reservar(
        userId: GetStorage().read('usuarioDocId'),
        cancha: cancha!,
      );

      if (error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
        return;
      }
      context.goNamed("inicio");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reserva completada para cancha ${cancha!.nombre}'),
        ),
      );
    }
    //Logica de la reserva luego del pago:
  }

  Future<void> _deleteCard(BuildContext context, String docId) async {
    bool confirm =
        await Get.dialog<bool>(
          AlertDialog(
            title: Text('Confirmar eliminación'),
            content: Text('¿Estás seguro de que deseas eliminar esta tarjeta?'),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: Text('Eliminar'),
              ),
            ],
          ),
          barrierDismissible: false,
        ) ??
        false;

    if (confirm) {
      try {
        await FirebaseFirestore.instance
            .collection('tarjetas')
            .doc(docId)
            .delete();
        if (controller.selectedCardId == docId) {
          controller.setSelectedCard(null);
        }
        _showSnackBar(
          context,
          'Tarjeta eliminada con éxito!',
          color: Colors.green,
        );
      } catch (e) {
        _showSnackBar(
          context,
          'Error al eliminar la tarjeta: $e',
          color: Colors.red,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed('inicio'); // o context.go('/inicio')
            }
          },
        ),
        title: Text('Volver'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Método de pago',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Tarjetas de crédito y débito',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('tarjetas')
                  .where('idUser', isEqualTo: GetStorage().read("usuarioDocId"))
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Algo salió mal');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.data!.docs.isEmpty) {
                  return const Text('No tienes tarjetas guardadas.');
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot doc = snapshot.data!.docs[index];
                    Map<String, dynamic> data =
                        doc.data()! as Map<String, dynamic>;
                    String docId = doc.id;

                    return GestureDetector(
                      onTap: () {
                        controller.setSelectedCard(
                          controller.selectedCardId == docId ? null : docId,
                        );
                      },
                      child: Obx(() {
                        bool isSelected = controller.selectedCardId == docId;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? Colors.orange
                                  : Colors.transparent,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Stack(
                            children: [
                              CardWidget(
                                cardNumber: enmascararNumeroTarjeta(
                                  formatearNumeroTarjeta(
                                    data["numero_tarjeta"],
                                  ),
                                ),
                                cardHolderName: data['nombre_titular'],
                                expiryDate: data['fecha_expiracion'],
                                cardColor: Color(data['color']),
                              ),
                              if (isSelected)
                                const Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Icon(
                                    Icons.check_circle,
                                    color: Colors.orange,
                                    size: 24,
                                  ),
                                ),
                              Positioned(
                                top: 10,
                                left: 10,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                  onPressed: () => _deleteCard(context, docId),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 10),
            _buildAddCardButton(context),
            const SizedBox(height: 20),
            _buildPayButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCardButton(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.to(() => AddCardPage());
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: const Row(
          children: [
            Icon(Icons.add_circle_outline, color: Colors.black),
            SizedBox(width: 10),
            Text(
              'Agregar tarjeta',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF9866),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: () => _handlePayment(context),
        child: const Text(
          'Pagar',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}

// Formatea el número de tarjeta separando cada 4 dígitos
String formatearNumeroTarjeta(String numero) {
  // Elimina cualquier espacio previo
  final limpio = numero.replaceAll(RegExp(r'\s+'), '');
  final buffer = StringBuffer();
  for (var i = 0; i < limpio.length; i++) {
    buffer.write(limpio[i]);
    if ((i + 1) % 4 == 0 && i + 1 != limpio.length) {
      buffer.write(' ');
    }
  }
  return buffer.toString();
}

// Enmascara el número de tarjeta dejando visibles solo los últimos 4 dígitos
String enmascararNumeroTarjeta(String numero) {
  final limpio = numero.replaceAll(RegExp(r'\s+'), '');
  if (limpio.length < 4) return numero;
  final ultimos4 = limpio.substring(limpio.length - 4);
  return '**** **** **** $ultimos4';
}
