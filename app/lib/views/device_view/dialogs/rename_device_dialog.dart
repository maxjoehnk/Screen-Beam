import 'package:flutter/material.dart';

class RenameDeviceDialog extends StatefulWidget {
  final String name;

  const RenameDeviceDialog({required this.name, super.key});

  @override
  State<RenameDeviceDialog> createState() => _RenameDeviceDialogState();
}

class _RenameDeviceDialogState extends State<RenameDeviceDialog> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    _nameController.text = widget.name;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Rename Device"),
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
          child: const Text("Rename"),
        ),
      ],
    );
  }
}
