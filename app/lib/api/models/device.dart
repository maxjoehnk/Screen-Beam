import 'package:json_annotation/json_annotation.dart';

import 'screen.dart';

part 'device.g.dart';

@JsonSerializable()
class DeviceModel {
  final String id;
  final String? name;
  final String hostname;
  final String address;
  final String version;
  final List<DeviceMonitorModel> monitors;

  DeviceModel({required this.id, this.name, required this.hostname, required this.address, required this.version, required this.monitors});

  factory DeviceModel.fromJson(Map<String, dynamic> json) => _$DeviceModelFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceModelToJson(this);
}

@JsonSerializable()
class DeviceMonitorModel {
  final String identifier;
  final int width;
  final int height;
  final ScreenModel? screen;

  DeviceMonitorModel({required this.identifier, required this.width, required this.height, this.screen});

  factory DeviceMonitorModel.fromJson(Map<String, dynamic> json) => _$DeviceMonitorModelFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceMonitorModelToJson(this);
}

