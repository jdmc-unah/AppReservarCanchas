import 'package:app_reservar_canchas/controladores/reservas_controlador.dart';
import 'package:app_reservar_canchas/modelos/cancha.dart';
import 'package:app_reservar_canchas/widgets/lista_horas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';

class CanchaCard extends StatelessWidget {
  CanchaCard({super.key, required this.canchaId});
  final int canchaId;

  //List<int> horasSeleccionadas = [];

  @override
  Widget build(BuildContext context) {
    final reservaControlador = Get.find<ReservasControlador>();

    return Obx(() {
      if (reservaControlador.canchas.isEmpty) {
        return Center(child: CircularProgressIndicator());
      }

      final cancha = reservaControlador.canchas.firstWhere(
        (element) => element.canchaId == canchaId,
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
              stackImgNameFav(cancha),
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
              _botonVerReservados(
                reservaControlador: reservaControlador,
                canchaId: canchaId,
                cancha: cancha,
              ),
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

class _botonVerReservados extends StatelessWidget {
  const _botonVerReservados({
    super.key,
    required this.reservaControlador,
    required this.canchaId,
    required this.cancha,
  });

  final ReservasControlador reservaControlador;
  final int canchaId;
  final Cancha cancha;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.59,
        top: 8,
      ),
      child: Container(
        height: 40,
        width: 130,
        child: ElevatedButton(
          onPressed: () {
            final fecha = reservaControlador.fechaActual(canchaId);
            final horas = cancha.reservasPorFecha[fecha] ?? [];

            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text('Horas reservadas - ${cancha.nombre}'),
                content: Text(
                  horas.isEmpty
                      ? 'Ninguna hora reservada.'
                      : horas.map((h) => "$h:00").join(', '),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cerrar'),
                  ),
                ],
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey[300],
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.visibility, color: Colors.white, size: 18),
              SizedBox(width: 4),
              Text(
                "Ver reservas",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _botonReserva extends StatelessWidget {
  const _botonReserva({
    super.key,
    required this.reservaControlador,
    required this.canchaId,
    required this.cancha,
  });

  final ReservasControlador reservaControlador;
  final int canchaId;
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
          onPressed: () {
            final seleccionadas = reservaControlador.obtener(canchaId);
            if (seleccionadas.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Debes seleccionar almenos una hora")),
              );
              return;
            }
            final fecha = reservaControlador.fechaActual(canchaId);
            final reservadasActuales = cancha.reservasPorFecha[fecha] ?? [];

            final nuevas = seleccionadas
                .where((hora) => !reservadasActuales.contains(hora))
                .toList();

            if (nuevas.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Todas las horas ya están reservadas")),
              );
              return;
            }

            //final fecha = reservaControlador.fechaActual(canchaId);
            if (!cancha.reservasPorFecha.containsKey(fecha)) {
              cancha.reservasPorFecha[fecha] = [];
            }
            cancha.reservasPorFecha[fecha]!.addAll(nuevas);

            reservaControlador.limpiar(canchaId);
            reservaControlador.canchas.refresh();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Reserva completada para cancha ${cancha.nombre}",
                ),
              ),
            );
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

  final int canchaId;

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
  final int canchaId;

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
          Text(
            cancha.ubicacion,
            style: TextStyle(fontSize: 17),
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

Stack stackImgNameFav(Cancha cancha) {
  //Widget stack permite poder sobreponer un widget sobre otro; como lo podemos suponer por su nombre.
  return Stack(
    alignment: Alignment.bottomLeft,
    children: [
      Image.network(
        "https://media.istockphoto.com/id/1176735816/photo/blue-tennis-court-and-illuminated-indoor-arena-with-fans-upper-front-view.jpg?s=1024x1024&w=is&k=20&c=u4i72shR1eXzojkcsVRPf4HdqakcOg2Mo0ucuaFtvXo=",
        fit: BoxFit.cover,
        width: double.infinity,
        height: 160,
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
            Text(
              "${cancha.nombre}",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'LPS ${cancha.precio}',
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
