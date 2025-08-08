import 'package:flutter/material.dart';

import 'package:app_reservar_canchas/controladores/reservas_controlador.dart';

import 'package:app_reservar_canchas/vistas/pagina_inicio.dart';
import 'package:app_reservar_canchas/vistas/vistas_login/login.dart';
import 'package:app_reservar_canchas/vistas/vistas_login/registro.dart';

import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app_reservar_canchas/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Get.put(ReservasControlador());
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: GoRouter(
        initialLocation: '/login',
        routes: [
          GoRoute(
            name: 'login',
            path: '/login',
            builder: (context, state) => Login(),

            routes: [
              GoRoute(
                name: 'registro',
                path: '/registro',
                builder: (context, state) => Registro(),
              ),
            ],
          ),

          GoRoute(
            name: 'inicio',
            path: '/inicio',
            builder: (context, state) {
              return PaginaInicio();
            },
          ),
        ],
      ),
    );
  }
}
