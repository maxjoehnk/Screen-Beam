import 'package:digital_signage/api/models/slide.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'shadow_editor.dart';
import 'style_editor.dart';
import 'text_editor.dart';

class TextLayerEditor extends StatelessWidget {
  final TextLayerModel layer;
  final Function(TextLayerModel) onChange;

  const TextLayerEditor(this.layer, {super.key, required this.onChange});

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.sizeOf(context).width < 600) {
      return ListView(shrinkWrap: true, children: [
        SizedBox(height: 200, child: TextEditor(layer: layer, onChange: onChange, scrollable: false)),
        StyleEditor(layer: layer, onChange: onChange, scrollable: false),
        ShadowEditor(layer: layer, onChange: onChange, scrollable: false),
      ]);
    }
    return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: TextEditor(layer: layer, onChange: onChange)),
          Expanded(child: StyleEditor(layer: layer, onChange: onChange)),
          Expanded(child: ShadowEditor(layer: layer, onChange: onChange)),
        ]);
  }
}
