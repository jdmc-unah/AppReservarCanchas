import 'package:flutter/material.dart';

class filtro_menu_lateral extends StatelessWidget {
  const filtro_menu_lateral({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.55,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [Text("Filtros", style: TextStyle(fontSize: 16))],
        ),
      ),
    );
  }
}
