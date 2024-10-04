import 'package:digital_signage/api/models/screen.dart';
import 'package:flutter/material.dart';

class SelectScreenDialog extends StatefulWidget {
  final List<ScreenModel> screens;

  const SelectScreenDialog({required this.screens, super.key});

  @override
  State<SelectScreenDialog> createState() => _SelectScreenDialogState();
}

class _SelectScreenDialogState extends State<SelectScreenDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Screen"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var screen in widget.screens)
            ListTile(
              title: Text(screen.name),
              subtitle: Text("${screen.slides.length} Slide(s)"),
              onTap: () => Navigator.of(context).pop(screen),
            ),
        ]
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
      ],
    );
  }
}
