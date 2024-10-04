import 'package:digital_signage/api/models/slide.dart';
import 'package:digital_signage/widgets/slide_preview.dart';
import 'package:flutter/material.dart';

import '../image_layer_service.dart';

class ImageLayerEditor extends StatelessWidget {
  final ImageLayerModel layer;
  final Function(ImageLayerModel) onChange;

  const ImageLayerEditor(this.layer, {super.key, required this.onChange});

  @override
  Widget build(BuildContext context) {
    var isMobile = MediaQuery.sizeOf(context).width < 600;
    return Card(
        child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Image", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Flexible(
            child: isMobile
                ? Column(children: [
                    Flexible(child: ImageLayerPreview(layer)),
                    Center(
                      child: _replaceImageButton(),
                    )
                  ])
                : Row(children: [
                    Flexible(child: ImageLayerPreview(layer)),
                    Expanded(
                      child: Center(
                        child: _replaceImageButton(),
                      ),
                    )
                  ]),
          ),
        ],
      ),
    ));
  }

  List<Widget> _children() {
    return [
      Flexible(child: ImageLayerPreview(layer)),
      Center(
        child: _replaceImageButton(),
      )
    ];
  }

  TextButton _replaceImageButton() {
    return TextButton(
      child: const Text("Replace Image"),
      onPressed: () async {
        var replacedImageLayer = await pickImage(previous: layer);
        if (replacedImageLayer == null) {
          return;
        }
        onChange(replacedImageLayer);
      },
    );
  }
}
