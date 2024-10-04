import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String text;

  const ConfirmDialog({super.key, required this.title, required this.text});

  static Future<bool> show(BuildContext context, String title, String text) async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(title: title, text: text),
    );

    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(text),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: const Text("Confirm"),
        ),
      ],
    );
  }
}
