import 'package:digital_signage/api/models/slide.dart';
import 'package:digital_signage/widgets/slide_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'layer_editor.dart';
import 'layer_list.dart';
import 'slide_editor_state.dart';

class SlideDesktopView extends StatelessWidget {
  final SlideModel slide;
  final SlideLayerModel? selectedLayer;

  const SlideDesktopView({super.key, required this.slide, this.selectedLayer});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Preview",
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        Expanded(child: SlidePreview(slide)),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Layers",
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 8),
                          Expanded(child: LayerList(slide: slide, selectedLayer: selectedLayer)),
                        ],
                      ),
                    ),
                  ))
            ],
          ),
        ),
        Expanded(
            child: selectedLayer == null
                ? Container()
                : LayerEditor(
                layer: selectedLayer!,
                onChange: (layer) =>
                    context.read<SlideEditorCubit>().updateLayer(layer)))
      ],
    );
  }
}
