import 'package:app_reservar_canchas/controladores/filtro_controlador.dart';
import 'package:app_reservar_canchas/estilos/colores.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class filtro_menu_lateral extends StatelessWidget {
  filtro_menu_lateral({super.key});

  @override
  Widget build(BuildContext context) {
    final filtros = Get.find<ControladorFiltros>();
    final controladorTexto = TextEditingController(
      text: filtros.textoNombre.value,
    );
    controladorTexto.addListener(() {
      filtros.textoNombre.value = controladorTexto.text.trim();
    });

    return SafeArea(
      child: Drawer(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filtros', style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: 16),

              //* Buscar por nombre
              Text(
                'Buscar por nombre',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              SizedBox(height: 8),
              TextField(
                controller: controladorTexto,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colores.fondoPrimario),
                  ),
                  hintText: 'Ej: Chamaco Guifarro',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              //* Tipo de deporte
              Text('Tipo', style: Theme.of(context).textTheme.labelLarge),
              SizedBox(height: 8),
              Obx(() {
                final seleccionado = filtros.tipo.value;
                final opciones = [
                  'soccer',
                  'basketball',
                  'tenis',
                  'padel',
                  'volleyball',
                ];
                //Este widget permite trabajar como de un Row se tratara pero hace saltos de lineas.
                //Nos muestra los distintos tipos de canchas que se pueden seleccionar en el filtro.
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    //ChoiceChip como lo dice su nombre se utiliza para elegir una opcion dentro de un conjunto.
                    //Esta permite poder seleccionar la opcion de Todos
                    ChoiceChip(
                      selectedColor: Colores.fondoSecundario,
                      checkmarkColor: Colores.fondoPrimario,
                      label: Text('Todos'),
                      selected: seleccionado == null,
                      onSelected: (_) => filtros.tipo.value = null,
                    ),
                    //Este permite seleccionar la opcion unica de los tipos, por lo tanto, genera dinamicamente los
                    //los elementos de la lista opciones.
                    for (final tipo in opciones)
                      ChoiceChip(
                        checkmarkColor: Colores.fondoPrimario,
                        selectedColor: Colores.fondoSecundario,
                        label: Text(tipo),
                        selected: seleccionado == tipo,
                        onSelected: (_) => filtros.tipo.value = tipo,
                      ),
                  ],
                );
              }),
              SizedBox(height: 16),

              // Rango de precio
              Text('Precio', style: Theme.of(context).textTheme.labelLarge),
              SizedBox(height: 8),
              Obx(() {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'L. ${filtros.precioMin.value.toStringAsFixed(0)} - L. ${filtros.precioMax.value.toStringAsFixed(0)}',
                    ),
                    RangeSlider(
                      activeColor: Colores.fondoPrimario,
                      inactiveColor: Colores.fondoSecundario,
                      min: filtros.limiteMin,
                      max: filtros.limiteMax,
                      values: RangeValues(
                        filtros.precioMin.value,
                        filtros.precioMax.value,
                      ),
                      divisions: 20,
                      labels: RangeLabels(
                        filtros.precioMin.value.toStringAsFixed(0),
                        filtros.precioMax.value.toStringAsFixed(0),
                      ),
                      onChanged: (r) {
                        filtros.precioMin.value = r.start;
                        filtros.precioMax.value = r.end;
                      },
                    ),
                  ],
                );
              }),
              Spacer(),

              // Botones de Limpiar o Aplicar
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: ButtonStyle(
                        overlayColor: WidgetStateProperty.all(
                          Colores.fondoSecundario,
                        ),
                        foregroundColor: WidgetStateProperty.all(
                          Colores.fondoPrimario,
                        ),
                      ),
                      onPressed: () {
                        filtros.limpiar();
                        Navigator.of(context).maybePop();
                      },
                      child: Text('Limpiar'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      style: ButtonStyle(
                        overlayColor: WidgetStateProperty.all(
                          Colores.fondoAlternativo,
                        ),
                        backgroundColor: WidgetStateProperty.all(
                          Colores.fondoPrimario,
                        ),
                      ),
                      onPressed: () {
                        // Cierra la pantalla que muestra la lista debe escuchar los cambios de filtros asi que no ocupa algun otro tipo de funcion.
                        Navigator.of(context).maybePop();
                      },
                      icon: Icon(Icons.check),
                      label: Text('Aplicar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
