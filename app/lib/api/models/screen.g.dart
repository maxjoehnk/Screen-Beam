// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'screen.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScreenModel _$ScreenModelFromJson(Map<String, dynamic> json) => ScreenModel(
      id: json['id'] as String,
      name: json['name'] as String,
      slides: (json['slides'] as List<dynamic>)
          .map((e) => SlideModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      monitorUsage: (json['monitorUsage'] as num).toInt(),
    );

Map<String, dynamic> _$ScreenModelToJson(ScreenModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slides': instance.slides,
      'monitorUsage': instance.monitorUsage,
    };
