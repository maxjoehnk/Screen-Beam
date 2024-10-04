import 'package:digital_signage/api/models/slide.dart';
import 'package:digital_signage/states/server_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SlidePreview extends StatelessWidget {
  final SlideModel slide;

  const SlidePreview(this.slide, {super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
        aspectRatio: 16 / 9,
        child: LayoutBuilder(
          builder: (context, constraints) {
            var scaleFactor = constraints.maxWidth / 1920;
            return Transform.scale(
              scale: scaleFactor,
              child: OverflowBox(
                maxHeight: constraints.maxHeight / scaleFactor,
                maxWidth: constraints.maxWidth / scaleFactor,
                minHeight: 0,
                minWidth: 0,
                child: Container(
                  width: 1920,
                  height: 1080,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                      children: slide.layers
                          .map((layer) => LayerPreview(layer))
                          .toList()),
                ),
              ),
            );
          },
        ));
  }
}

class LayerPreview extends StatelessWidget {
  final SlideLayerModel layer;

  const LayerPreview(this.layer, {super.key});

  @override
  Widget build(BuildContext context) {
    if (layer is ImageLayerModel) {
      return ImageLayerPreview(layer as ImageLayerModel);
    } else if (layer is TextLayerModel) {
      TextLayerModel textLayer = layer as TextLayerModel;
      return Positioned(
        top: textLayer.y.toDouble(),
        left: textLayer.x.toDouble(),
        child: SizedBox(
          width: 1920,
          height: 1080,
          child: Text(textLayer.text,
              textAlign: textLayer.alignment.toFlutterAlignment(),
              style: TextStyle(
                  shadows: [
                    if (textLayer.shadow != null)
                      Shadow(
                          color: textLayer.shadow!.color.flutterColor,
                          offset: Offset(textLayer.shadow!.xOffset.toDouble(),
                              textLayer.shadow!.yOffset.toDouble()))
                  ],
                  fontFamily: textLayer.font,
                  fontSize: textLayer.fontSize.toDouble(),
                  fontWeight: mapFontWeight(textLayer.fontWeight),
                  fontStyle: textLayer.italic ? FontStyle.italic : FontStyle.normal,
                  height: (textLayer.lineHeight?.toDouble() ?? textLayer.fontSize.toDouble()) /
                      textLayer.fontSize.toDouble(),
                  color: textLayer.color.flutterColor)),
        ),
      );
    } else {
      return Container();
    }
  }
}

class ImageLayerPreview extends StatelessWidget {
  final ImageLayerModel layer;

  const ImageLayerPreview(this.layer, {super.key});

  @override
  Widget build(BuildContext context) {
    if (layer.persisted) {
      return BlocBuilder<ServerCubit, ServerState>(
        builder: (context, state) {
          return Image.network('${state.selectedServer!.baseUrl}/layers/${layer.id}/data');
        },
      );
    }
    if (layer.imageData != null) {
      return Image.memory(layer.imageData!);
    }
    return Container();
  }
}

FontWeight mapFontWeight(int weight) {
  switch (weight) {
    case 100:
      return FontWeight.w100;
    case 200:
      return FontWeight.w200;
    case 300:
      return FontWeight.w300;
    case 400:
      return FontWeight.w400;
    case 500:
      return FontWeight.w500;
    case 600:
      return FontWeight.w600;
    case 700:
      return FontWeight.w700;
    case 800:
      return FontWeight.w800;
    case 900:
      return FontWeight.w900;
    default:
      return FontWeight.w400;
  }
}
