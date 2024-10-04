import 'package:flutter/material.dart';

class FontStyleSelector extends StatelessWidget {
  final bool italic;
  final Function(bool) onChange;

  const FontStyleSelector(this.italic, this.onChange, {super.key});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<bool>(
      decoration: const InputDecoration(label: Text("Font Style")),
      value: italic,
      onChanged: (value) => onChange(value!),
      items: const [
        DropdownMenuItem(value: false, child: Text("Normal")),
        DropdownMenuItem(value: true, child: Text("Italic")),
      ],
    );
  }
}
