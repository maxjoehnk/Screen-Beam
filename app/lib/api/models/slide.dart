import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'slide.g.dart';

@JsonSerializable()
class SlideModel {
  final String id;
  final String name;
  final List<SlideLayerModel> layers;
  final int screenUsage;

  SlideModel({required this.id, required this.name, required this.layers, required this.screenUsage});

  factory SlideModel.fromJson(Map<String, dynamic> json) =>
      _$SlideModelFromJson(json);

  Map<String, dynamic> toJson() => _$SlideModelToJson(this);
}

@JsonSerializable(createFactory: false)
abstract class SlideLayerModel {
  final String id;
  final String? label;

  String type;

  SlideLayerModel({required this.id, this.label, required this.type});

  factory SlideLayerModel.fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'image':
        return ImageLayerModel.fromJson(json);
      case 'text':
        return TextLayerModel.fromJson(json);
      default:
        throw Exception('Unknown layer type');
    }
  }

  SlideLayerModel setName(String name);
}

@JsonSerializable()
class ImageLayerModel extends SlideLayerModel {
  @JsonKey(includeFromJson: false, includeToJson: false)
  final Uint8List? imageData;

  final String contentType;

  @JsonKey(includeFromJson: false, includeToJson: false, defaultValue: true)
  final bool persisted;

  ImageLayerModel(
      {required super.id,
        super.label,
      required this.contentType,
      this.imageData,
      this.persisted = true})
      : super(type: "image");

  factory ImageLayerModel.create(Uint8List data, String contentType) {
    return ImageLayerModel(
      id: const Uuid().v4(),
      contentType: contentType,
      imageData: data,
      persisted: false,
    );
  }

  factory ImageLayerModel.fromJson(Map<String, dynamic> json) =>
      _$ImageLayerModelFromJson(json);

  Map<String, dynamic> toJson() => _$ImageLayerModelToJson(this);

  ImageLayerModel replaceImage(Uint8List data, String contentType) {
    return ImageLayerModel(
      id: id,
      contentType: contentType,
      imageData: data,
      persisted: false,
      label: label,
    );
  }

  @override
  SlideLayerModel setName(String? name) {
    return ImageLayerModel(
      id: id,
      contentType: contentType,
      imageData: imageData,
      persisted: persisted,
      label: name?.isEmpty == false ? name : null,
    );
  }
}

@JsonSerializable()
class TextLayerModel extends SlideLayerModel {
  final String text;
  final String font;
  final int x;
  final int y;
  final int fontSize;
  final int? lineHeight;
  final ColorModel color;
  final TextShadowModel? shadow;
  final TextAlignModel alignment;
  final int fontWeight;
  final bool italic;

  TextLayerModel(
      {required super.id,
        super.label,
      required this.text,
      required this.font,
      required this.x,
      required this.y,
      required this.fontSize,
      this.lineHeight,
      required this.color,
      this.alignment = TextAlignModel.Start,
      this.shadow,
      this.fontWeight = 400,
      this.italic = false})
      : super(type: "text");

  factory TextLayerModel.empty() {
    return TextLayerModel(
      id: const Uuid().v4(),
      text: 'Text',
      font: 'Arial',
      x: 0,
      y: 0,
      fontSize: 24,
      color: ColorModel.white(),
    );
  }

  factory TextLayerModel.fromJson(Map<String, dynamic> json) =>
      _$TextLayerModelFromJson(json);

  Map<String, dynamic> toJson() => _$TextLayerModelToJson(this);

  TextLayerModel copyWith(
      {String? text,
      String? font,
      int? x,
      int? y,
      int? fontSize,
      int? lineHeight,
      ColorModel? color,
      TextShadowModel? shadow,
      TextAlignModel? alignment,
      int? weight,
      bool? italic,
      String? label
      }) {
    return TextLayerModel(
      id: id,
      text: text ?? this.text,
      font: font ?? this.font,
      x: x ?? this.x,
      y: y ?? this.y,
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      color: color ?? this.color,
      shadow: shadow ?? this.shadow,
      alignment: alignment ?? this.alignment,
      fontWeight: weight ?? this.fontWeight,
      italic: italic ?? this.italic,
      label: (label ?? this.label)?.isEmpty == false ? (label ?? this.label) : null,
    );
  }

  TextLayerModel clearShadow() {
    return TextLayerModel(
      id: id,
      text: text,
      font: font,
      x: x,
      y: y,
      fontSize: fontSize,
      lineHeight: lineHeight,
      color: color,
      alignment: alignment,
      fontWeight: fontWeight,
      italic: italic,
    );
  }

  @override
  SlideLayerModel setName(String? name) {
    return copyWith(
      label: name,
    );
  }
}

enum TextAlignModel {
  @JsonValue("start")
  Start,
  @JsonValue("center")
  Center,
  @JsonValue("end")
  End
}

extension TextAlignModelExtension on TextAlignModel {
  TextAlign toFlutterAlignment() {
    switch (this) {
      case TextAlignModel.Start:
        return TextAlign.left;
      case TextAlignModel.Center:
        return TextAlign.center;
      case TextAlignModel.End:
        return TextAlign.right;
    }
  }
}

@JsonSerializable()
class ColorModel {
  final int red;
  final int green;
  final int blue;
  final int alpha;

  ColorModel(
      {required this.red,
      required this.green,
      required this.blue,
      required this.alpha});

  factory ColorModel.white() {
    return ColorModel(
      red: 255,
      green: 255,
      blue: 255,
      alpha: 255,
    );
  }

  factory ColorModel.fromJson(Map<String, dynamic> json) =>
      _$ColorModelFromJson(json);

  Map<String, dynamic> toJson() => _$ColorModelToJson(this);

  Color get flutterColor => Color.fromARGB(alpha, red, green, blue);

  static ColorModel fromColor(Color color) {
    return ColorModel(
      red: color.red,
      green: color.green,
      blue: color.blue,
      alpha: color.alpha,
    );
  }
}

@JsonSerializable()
class TextShadowModel {
  final int xOffset;
  final int yOffset;
  final ColorModel color;

  TextShadowModel(
      {required this.xOffset, required this.yOffset, required this.color});

  factory TextShadowModel.empty() {
    return TextShadowModel(
      xOffset: 4,
      yOffset: 4,
      color: ColorModel(red: 0, green: 0, blue: 0, alpha: 128),
    );
  }

  factory TextShadowModel.fromJson(Map<String, dynamic> json) =>
      _$TextShadowModelFromJson(json);

  Map<String, dynamic> toJson() => _$TextShadowModelToJson(this);

  TextShadowModel copyWith({int? xOffset, int? yOffset, ColorModel? color}) {
    return TextShadowModel(
      xOffset: xOffset ?? this.xOffset,
      yOffset: yOffset ?? this.yOffset,
      color: color ?? this.color,
    );
  }
}
