import 'package:flutter/material.dart';

class AddSlideDialog extends StatefulWidget {
  const AddSlideDialog({super.key});

  @override
  State<AddSlideDialog> createState() => _AddSlideDialogState();
}

class _AddSlideDialogState extends State<AddSlideDialog> {
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Slide"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextFormField(
          autofocus: true,
          controller: _nameController,
          decoration: const InputDecoration(labelText: "Name"),
        ),
      ]),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_nameController.text),
          child: const Text("Add"),
        ),
      ],
    );
  }
}
