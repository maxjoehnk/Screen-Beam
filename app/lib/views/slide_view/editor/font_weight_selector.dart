import 'package:digital_signage/extensions/map_ext.dart';
import 'package:flutter/material.dart';

const fontWeights = {
  100: "Thin",
  200: "Extra Light",
  300: "Light",
  400: "Regular",
  500: "Medium",
  600: "Semi Bold",
  700: "Bold",
  800: "Extra Bold",
  900: "Black",
};

class FontWeightSelector extends StatelessWidget {
  final int weight;
  final Function(int) onChange;

  const FontWeightSelector(this.weight, this.onChange, {super.key});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      decoration: const InputDecoration(label: Text("Font Weight")),
      value: weight,
      onChanged: (value) => onChange(value!),
      items: fontWeights.mapToList(
          (key, value) => DropdownMenuItem(value: key, child: Text(value))),
    );
  }
}
