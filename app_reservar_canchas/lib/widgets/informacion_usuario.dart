import 'package:flutter/material.dart';

class informacion_usuario extends StatelessWidget {
  const informacion_usuario({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: PopupMenuButton(
          //Siguiente linea: Hace que la lista se desplace hacia abajo y no tapar el MenuBottonS
          position: PopupMenuPosition.under,
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.blue[50],
            child: Text("Hola"),
          ),
          itemBuilder: (context) => [
            PopupMenuItem(value: 0, child: Text("Informacion")),
            PopupMenuItem(value: 0, child: Text("Informacion")),
          ],
        ),
      ),
    );
  }
}
