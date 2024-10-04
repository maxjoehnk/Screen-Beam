// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceModel _$DeviceModelFromJson(Map<String, dynamic> json) => DeviceModel(
      id: json['id'] as String,
      name: json['name'] as String?,
      hostname: json['hostname'] as String,
      address: json['address'] as String,
      version: json['version'] as String,
      monitors: (json['monitors'] as List<dynamic>)
          .map((e) => DeviceMonitorModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DeviceModelToJson(DeviceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'hostname': instance.hostname,
      'address': instance.address,
      'version': instance.version,
      'monitors': instance.monitors,
    };

DeviceMonitorModel _$DeviceMonitorModelFromJson(Map<String, dynamic> json) =>
    DeviceMonitorModel(
      identifier: json['identifier'] as String,
      width: (json['width'] as num).toInt(),
      height: (json['height'] as num).toInt(),
      screen: json['screen'] == null
          ? null
          : ScreenModel.fromJson(json['screen'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DeviceMonitorModelToJson(DeviceMonitorModel instance) =>
    <String, dynamic>{
      'identifier': instance.identifier,
      'width': instance.width,
      'height': instance.height,
      'screen': instance.screen,
    };
