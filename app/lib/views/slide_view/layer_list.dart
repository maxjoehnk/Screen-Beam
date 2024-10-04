import 'package:digital_signage/api/models/slide.dart';
import 'package:digital_signage/extensions/string_ext.dart';
import 'package:digital_signage/views/slide_view/dialogs/name_layer_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'image_layer_service.dart';
import 'slide_editor_state.dart';

class LayerList extends StatelessWidget {
  final SlideModel slide;
  final SlideLayerModel? selectedLayer;

  const LayerList({super.key, required this.slide, this.selectedLayer});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: ListView(
              children: slide.layers.map((layer) {
            return ListTile(
                title: layer.label != null ? Text(layer.label!) : Text(layer.type.toCapitalCase()),
                subtitle: layer.label != null ? Text(layer.type.toCapitalCase()) : null,
                selected: selectedLayer == layer,
                onTap: () =>
                    context.read<SlideEditorCubit>().selectLayer(layer),
                trailing: PopupMenuButton(itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem(child: const Text("Rename"), onTap: () async {
                      var name = await showDialog(context: context, builder: (context) => NameLayerDialog(name: layer.label));
                      if (name == null) {
                        return;
                      }

                      context.read<SlideEditorCubit>().renameLayer(layer, name);
                    }),
                    PopupMenuItem(child: const Text("Delete"), onTap: () => context.read<SlideEditorCubit>().removeLayer(layer)),
                  ];
                }));
          }).toList()),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(children: [
            FilledButton(
                onPressed: () => context
                    .read<SlideEditorCubit>()
                    .addLayer(TextLayerModel.empty()),
                child: const Text("Add Text")),
            const SizedBox(width: 8),
            FilledButton(
                onPressed: () async {
                  var layer = await pickImage();
                  if (layer == null) {
                    return;
                  }
                  if (!context.mounted) {
                    return;
                  }
                  context.read<SlideEditorCubit>().addLayer(layer);
                },
                child: const Text("Add Image")),
          ]),
        )
      ],
    );
  }
}
