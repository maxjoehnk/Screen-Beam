import 'package:digital_signage/api/models/slide.dart';
import 'package:digital_signage/views/slide_view/layer_list.dart';
import 'package:digital_signage/widgets/slide_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'layer_editor.dart';
import 'slide_editor_state.dart';

class SlideMobileView extends StatelessWidget {
  final SlideModel slide;
  final SlideLayerModel? selectedLayer;

  const SlideMobileView({super.key, required this.slide, this.selectedLayer});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Card(
            child: Expanded(child: SlidePreview(slide)),
          ),
          const TabBar(tabs: [
            Tab(text: "Layers"),
            Tab(text: "Properties"),
          ]),
          Expanded(
            child: TabBarView(children: [
              LayerList(slide: slide, selectedLayer: selectedLayer),
              selectedLayer == null
                  ? Container()
                  : Expanded(
                      child: LayerEditor(
                          layer: selectedLayer!,
                          onChange: (layer) => context
                              .read<SlideEditorCubit>()
                              .updateLayer(layer)),
                    )
            ]),
          ),
        ],
      ),
    );
  }
}
