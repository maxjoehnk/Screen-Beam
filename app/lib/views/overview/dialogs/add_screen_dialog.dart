import 'package:flutter/material.dart';

class AddScreenDialog extends StatefulWidget {
  const AddScreenDialog({super.key});

  @override
  State<AddScreenDialog> createState() => _AddScreenDialogState();
}

class _AddScreenDialogState extends State<AddScreenDialog> {
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Screen"),
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
