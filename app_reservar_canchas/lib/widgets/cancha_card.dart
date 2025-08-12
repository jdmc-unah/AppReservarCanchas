import 'package:app_reservar_canchas/controladores/reservas_controlador.dart';
import 'package:app_reservar_canchas/modelos/cancha.dart';
import 'package:app_reservar_canchas/widgets/lista_horas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';

class CanchaCard extends StatelessWidget {
  CanchaCard({super.key, required this.canchaId});
  final String canchaId;

  //List<int> horasSeleccionadas = [];

  @override
  Widget build(BuildContext context) {
    final reservaControlador = Get.find<ReservasControlador>();

    return Obx(() {
      if (reservaControlador.canchas.isEmpty) {
        return Center(child: CircularProgressIndicator());
      }

      final cancha = reservaControlador.canchas.firstWhere(
        (element) => element.id == canchaId,
      );
      return Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        elevation: 4,
        child: Container(
          //color: Colors.lime[100],
          //height: 400,
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              stackImgNameFav(cancha, context),

              _ubicacionRating(cancha: cancha),

              ListaHoras(canchaId: canchaId),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _botonCalendario(canchaId: canchaId),
                  Column(
                    children: [
                      _fechaActualTxt(
                        reservaControlador: reservaControlador,
                        canchaId: canchaId,
                      ),
                      _botonReserva(
                        reservaControlador: reservaControlador,
                        canchaId: canchaId,
                        cancha: cancha,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10),
              // _botonVerReservados(
              //   reservaControlador: reservaControlador,
              //   canchaId: canchaId,
              //   cancha: cancha,
              // ),
              SizedBox(height: 10),

              //Aca empieza
              //_botonVerReservados(reservaControlador: reservaControlador, canchaId: canchaId, cancha: cancha), //aqui termina visibilidad
              // SingleChildScrollView(
              //   scrollDirection: Axis.horizontal,
              //   child: Row(children: [Card()]),
              // ),
            ],
          ),
        ),
      );
    });
  }
}

// class _botonVerReservados extends StatelessWidget {
//   const _botonVerReservados({
//     super.key,
//     required this.reservaControlador,
//     required this.canchaId,
//     required this.cancha,
//   });

//   final ReservasControlador reservaControlador;
//   final String canchaId;
//   final Cancha cancha;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.only(
//         left: MediaQuery.of(context).size.width * 0.59,
//         top: 8,
//       ),
//       child: Container(
//         height: 40,
//         width: 130,
//         child: ElevatedButton(
//           onPressed: () {
//             final fecha = reservaControlador.fechaActual(canchaId);
//             final horas = cancha.reservasPorFecha[fecha] ?? [];

//             showDialog(
//               context: context,
//               builder: (_) => AlertDialog(
//                 title: Text('Horas reservadas - ${cancha.nombre}'),
//                 content: Text(
//                   horas.isEmpty
//                       ? 'Ninguna hora reservada.'
//                       : horas.map((h) => "$h:00").join(', '),
//                 ),
//                 actions: [
//                   TextButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: Text('Cerrar'),
//                   ),
//                 ],
//               ),
//             );
//           },
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.blueGrey[300],
//             shadowColor: Colors.transparent,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//           child: Row(
//             children: [
//               Icon(Icons.visibility, color: Colors.white, size: 18),
//               SizedBox(width: 4),
//               Text(
//                 "Ver reservas",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 10,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class _botonReserva extends StatelessWidget {
  const _botonReserva({
    super.key,
    required this.reservaControlador,
    required this.canchaId,
    required this.cancha,
  });

  final ReservasControlador reservaControlador;
  final String canchaId;
  final Cancha cancha;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 1 /*MediaQuery.of(context).size.width * 0.59*/,
      ),
      child: Container(
        height: 40,
        width: 130,
        child: ElevatedButton(
          onPressed: () async {
            context.goNamed(
              'pago',
              extra: {
                "cancha": cancha,
                "reservasControlador": reservaControlador,
              },
            );
            // final error = await reservaControlador.reservar(
            //   userId: GetStorage().read('usuarioDocId'),
            //   cancha: cancha,
            // );

            // if (error != null) {
            //   ScaffoldMessenger.of(
            //     context,
            //   ).showSnackBar(SnackBar(content: Text(error)));
            //   return;
            // }

            // ScaffoldMessenger.of(context).showSnackBar(
            //   SnackBar(
            //     content: Text(
            //       'Reserva completada para cancha ${cancha.nombre}',
            //     ),
            //   ),
            // );
          },

          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightGreen[300],
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.check, color: Colors.white),
              SizedBox(width: 3),
              Text(
                "Reservar",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _botonCalendario extends StatelessWidget {
  const _botonCalendario({super.key, required this.canchaId});

  final String canchaId;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.lightGreen[300],
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),

      icon: Icon(Icons.calendar_today, color: Colors.white),
      label: Text(
        'Elegir fecha',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      onPressed: () async {
        final reservaControlador = Get.find<ReservasControlador>();
        final nuevaFecha = await showDatePicker(
          context: context,
          initialDate: DateTime.now().add(Duration(days: 1)),
          firstDate: DateTime.now().add(Duration(days: 1)),
          lastDate: DateTime(2030),
        );
        if (nuevaFecha != null) {
          reservaControlador.seleccionarFecha(canchaId, nuevaFecha);
          reservaControlador.limpiar(canchaId);
        }
      },
    );
  }
}

class _fechaActualTxt extends StatelessWidget {
  const _fechaActualTxt({
    super.key,
    required this.reservaControlador,
    required this.canchaId,
  });

  final ReservasControlador reservaControlador;
  final String canchaId;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final fecha = reservaControlador.fechaActual(canchaId);
      return Text(
        "Fecha: $fecha",
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black45),
      );
    });
  }
}

class _ubicacionRating extends StatelessWidget {
  _ubicacionRating({required this.cancha});
  Cancha cancha;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 3.0),
      child: Row(
        children: [
          Icon(Icons.location_on_outlined, size: 17),
          SizedBox(width: 4),
          Expanded(
            child: Text(
              cancha.ubicacion,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ), //Variable ubicacion
          Spacer(),
          //SizedBox(width: 105),
          RatingBarIndicator(
            rating: cancha.rating, //Variable rating
            itemCount: 5,
            itemSize: 18,
            direction: Axis.horizontal,
            itemBuilder: (context, index) =>
                Icon(Icons.star, color: Colors.amber),
          ),
        ],
      ),
    );
  }
}

// class HorasSeleccionada extends StatelessWidget {
//   const HorasSeleccionada({
//     super.key,
//     required this.horasSeleccionadas,
//   });

//   final List<int> horasSeleccionadas;

//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       scrollDirection: Axis.horizontal,
//       itemCount: 24,
//       itemBuilder: (context, index) {
//         final hora = index;
//         final estaSeleccionado = horasSeleccionadas.contains(hora);
//         return Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 4),
//           child: ChoiceChip(
//             label: Text("${index}:00"),
//             selected: estaSeleccionado,
//             onSelected: (bool seleccionado) {

//             },
//           ),
//         );
//       },
//     );
//   }
// }

Stack stackImgNameFav(Cancha cancha, BuildContext context) {
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

  String textoTipo(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'soccer':
        return "Fútbol";
      case 'basketball':
        return 'Baloncesto';
      case 'tenis':
        return 'Tenis';
      case 'padel':
        return 'Padel';
      case 'volleybal':
        return 'Voleibol';
    }
    return tipo;
  }

  String imgUrl = cancha.url;
  const kDefaultCanchaImg =
      "https://media.istockphoto.com/id/1176735816/photo/blue-tennis-court-and-illuminated-indoor-arena-with-fans-upper-front-view.jpg?s=1024x1024&w=is&k=20&c=u4i72shR1eXzojkcsVRPf4HdqakcOg2Mo0ucuaFtvXo=";
  if (imgUrl == "urlpaginaweb") {
    imgUrl = kDefaultCanchaImg;
  }
  //Widget stack permite poder sobreponer un widget sobre otro; como lo podemos suponer por su nombre.
  return Stack(
    alignment: Alignment.bottomLeft,
    children: [
      Image.network(
        imgUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 160,
      ),
      Positioned(
        top: 8,
        right: 8,
        child: IconButton(
          icon: Icon(Icons.info_outline, color: Colors.white),
          tooltip: "Información",
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(
              Colors.black.withOpacity(0.4),
            ),
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text(cancha.nombre),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("📄 ${cancha.descripcion}"),
                      SizedBox(height: 10),
                      Text("📞 ${cancha.telefono}"),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Cerrar"),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
      Positioned(
        top: 8,
        left: 8,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(iconoDeporte(cancha.tipo), size: 14, color: Colors.white),
              SizedBox(width: 6),
              Text(
                textoTipo(cancha.tipo),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "${cancha.nombre}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              'LPS ${cancha.precio.toPrecision(2)}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
