import 'package:digital_signage/api/models/slide.dart';
import 'package:flutter/material.dart';

import 'editor/image_layer_editor.dart';
import 'editor/text_layer_editor.dart';

class LayerEditor extends StatelessWidget {
  final SlideLayerModel layer;
  final Function(SlideLayerModel) onChange;

  const LayerEditor({super.key, required this.layer, required this.onChange});

  @override
  Widget build(BuildContext context) {
    if (layer is ImageLayerModel) {
      return ImageLayerEditor(layer as ImageLayerModel, onChange: onChange);
    } else if (layer is TextLayerModel) {
      return TextLayerEditor(layer as TextLayerModel, onChange: onChange);
    } else {
      return Container();
    }
  }
}
