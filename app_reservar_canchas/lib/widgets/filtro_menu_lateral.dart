import 'package:app_reservar_canchas/controladores/filtro_controlador.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

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
          padding: EdgeInsets.only(left: 16, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filtros', style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: 16),

              // Buscar por nombre
              Text(
                'Buscar por nombre',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              SizedBox(height: 8),
              TextField(
                controller: controladorTexto,
                decoration: InputDecoration(
                  hintText: 'Ej: Chamaco Guifarro',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              // Tipo de deporte
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
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text('Todos'),
                      selected: seleccionado == null,
                      onSelected: (_) => filtros.tipo.value = null,
                    ),
                    for (final t in opciones)
                      ChoiceChip(
                        label: Text(t),
                        selected: seleccionado == t,
                        onSelected: (_) => filtros.tipo.value = t,
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

              // Botones
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
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
                      onPressed: () {
                        // Solo cierra; la pantalla que muestra la lista debe escuchar los cambios de filtros
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
