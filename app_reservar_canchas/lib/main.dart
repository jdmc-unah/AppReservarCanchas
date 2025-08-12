import 'package:app_reservar_canchas/controladores/filtro_controlador.dart';
import 'package:app_reservar_canchas/estilos/colores.dart';
import 'package:app_reservar_canchas/modelos/cancha.dart';
import 'package:app_reservar_canchas/vistas/informacion.dart';
import 'package:app_reservar_canchas/vistas/vistas_metodo_pago/agregar_tarjeta.dart';
import 'package:app_reservar_canchas/vistas/vistas_metodo_pago/pagina_pago.dart';
import 'package:flutter/material.dart';

import 'package:app_reservar_canchas/controladores/reservas_controlador.dart';

import 'package:app_reservar_canchas/vistas/pagina_inicio.dart';
import 'package:app_reservar_canchas/vistas/vistas_login/login.dart';
import 'package:app_reservar_canchas/vistas/vistas_login/registro.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app_reservar_canchas/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await GetStorage.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Get.put(ReservasControlador(), permanent: true);
  Get.put(ControladorFiltros(), permanent: true);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colores.fondoPrimario,
          selectionColor: Colores.fondoPrimario,
          selectionHandleColor: Colores.fondoPrimario,
        ),
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: GoRouter(
        navigatorKey: Get.key,
        redirect: (context, state) {
          final sesionIniciada = GetStorage().read('sesionIniciada') ?? false;
          final rutaActual = state.fullPath;
          if (!sesionIniciada && rutaActual == '/inicio') {
            return '/login';
          }
        },
        initialLocation: '/inicio',
        routes: [
          // GoRoute(
          //   name: 'nueva',
          //   path: '/nueva',
          //   builder: (context, state) => AgregarCanchaPage(),
          // ),
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
          GoRoute(
            name: 'pago',
            path: '/pago',
            builder: (context, state) {
              final extra = state.extra;
              final reservasControlador = Get.find<ReservasControlador>();
              Cancha? cancha;

              if (extra is Cancha) {
                cancha = extra;
              } else if (extra is Map<String, dynamic>) {
                cancha = extra['cancha'] as Cancha?;
              }

              return PaymentMethodsPage(cancha: cancha);
            },

            routes: [
              GoRoute(
                name: 'agregarTarjeta',
                path: '/agregarTarjeta',
                builder: (context, state) => AddCardPage(),
              ),
            ],
          ),

          GoRoute(
            name: 'informacion',
            path: '/informacion',
            builder: (context, state) => PaginaResumenUsuario(),
          ),
        ],
      ),
    );
  }
}
