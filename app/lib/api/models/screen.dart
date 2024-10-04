import 'package:json_annotation/json_annotation.dart';

import 'slide.dart';

part 'screen.g.dart';

@JsonSerializable()
class ScreenModel {
  final String id;
  final String name;
  final List<SlideModel> slides;
  final int monitorUsage;

  ScreenModel({required this.id, required this.name, required this.slides, required this.monitorUsage});

  factory ScreenModel.fromJson(Map<String, dynamic> json) => _$ScreenModelFromJson(json);

  Map<String, dynamic> toJson() => _$ScreenModelToJson(this);
}

