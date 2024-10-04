import 'package:digital_signage/api/models/slide.dart';
import 'package:digital_signage/widgets/slide_preview.dart';
import 'package:flutter/material.dart';

class SelectSlideDialog extends StatefulWidget {
  final List<SlideModel> slides;

  const SelectSlideDialog({required this.slides, super.key});

  @override
  State<SelectSlideDialog> createState() => _SelectSlideDialogState();
}

class _SelectSlideDialogState extends State<SelectSlideDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Slide"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        for (var slide in widget.slides)
          Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(slide),
              child: Stack(
                  children: [
                    SizedBox(height: 150, child: SlidePreview(slide)),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        color: Colors.black.withOpacity(0.5),
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(slide.name),
                          ],
                        ),
                      ),
                    ),
                  ]),
            ),
          ),
      ]),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
      ],
    );
  }
}
