import 'package:digital_signage/api/models/slide.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart' hide ColorModel;

class ColorFormField extends StatelessWidget {
  final Widget? label;
  final ColorModel color;
  final Function(ColorModel) onChange;

  const ColorFormField(
      {super.key, required this.color, required this.onChange, this.label});

  @override
  Widget build(BuildContext context) {
    return ColorPicker(pickerColor: color.flutterColor, onColorChanged: (color) {
      onChange(ColorModel.fromColor(color));
    }, colorPickerWidth: 150);
  }
}
