// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slide.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SlideModel _$SlideModelFromJson(Map<String, dynamic> json) => SlideModel(
      id: json['id'] as String,
      name: json['name'] as String,
      layers: (json['layers'] as List<dynamic>)
          .map((e) => SlideLayerModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      screenUsage: (json['screenUsage'] as num).toInt(),
    );

Map<String, dynamic> _$SlideModelToJson(SlideModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'layers': instance.layers,
      'screenUsage': instance.screenUsage,
    };

Map<String, dynamic> _$SlideLayerModelToJson(SlideLayerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'type': instance.type,
    };

ImageLayerModel _$ImageLayerModelFromJson(Map<String, dynamic> json) =>
    ImageLayerModel(
      id: json['id'] as String,
      label: json['label'] as String?,
      contentType: json['contentType'] as String,
    )..type = json['type'] as String;

Map<String, dynamic> _$ImageLayerModelToJson(ImageLayerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'type': instance.type,
      'contentType': instance.contentType,
    };

TextLayerModel _$TextLayerModelFromJson(Map<String, dynamic> json) =>
    TextLayerModel(
      id: json['id'] as String,
      label: json['label'] as String?,
      text: json['text'] as String,
      font: json['font'] as String,
      x: (json['x'] as num).toInt(),
      y: (json['y'] as num).toInt(),
      fontSize: (json['fontSize'] as num).toInt(),
      lineHeight: (json['lineHeight'] as num?)?.toInt(),
      color: ColorModel.fromJson(json['color'] as Map<String, dynamic>),
      alignment:
          $enumDecodeNullable(_$TextAlignModelEnumMap, json['alignment']) ??
              TextAlignModel.Start,
      shadow: json['shadow'] == null
          ? null
          : TextShadowModel.fromJson(json['shadow'] as Map<String, dynamic>),
      fontWeight: (json['fontWeight'] as num?)?.toInt() ?? 400,
      italic: json['italic'] as bool? ?? false,
    )..type = json['type'] as String;

Map<String, dynamic> _$TextLayerModelToJson(TextLayerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'type': instance.type,
      'text': instance.text,
      'font': instance.font,
      'x': instance.x,
      'y': instance.y,
      'fontSize': instance.fontSize,
      'lineHeight': instance.lineHeight,
      'color': instance.color,
      'shadow': instance.shadow,
      'alignment': _$TextAlignModelEnumMap[instance.alignment]!,
      'fontWeight': instance.fontWeight,
      'italic': instance.italic,
    };

const _$TextAlignModelEnumMap = {
  TextAlignModel.Start: 'start',
  TextAlignModel.Center: 'center',
  TextAlignModel.End: 'end',
};

ColorModel _$ColorModelFromJson(Map<String, dynamic> json) => ColorModel(
      red: (json['red'] as num).toInt(),
      green: (json['green'] as num).toInt(),
      blue: (json['blue'] as num).toInt(),
      alpha: (json['alpha'] as num).toInt(),
    );

Map<String, dynamic> _$ColorModelToJson(ColorModel instance) =>
    <String, dynamic>{
      'red': instance.red,
      'green': instance.green,
      'blue': instance.blue,
      'alpha': instance.alpha,
    };

TextShadowModel _$TextShadowModelFromJson(Map<String, dynamic> json) =>
    TextShadowModel(
      xOffset: (json['xOffset'] as num).toInt(),
      yOffset: (json['yOffset'] as num).toInt(),
      color: ColorModel.fromJson(json['color'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TextShadowModelToJson(TextShadowModel instance) =>
    <String, dynamic>{
      'xOffset': instance.xOffset,
      'yOffset': instance.yOffset,
      'color': instance.color,
    };
