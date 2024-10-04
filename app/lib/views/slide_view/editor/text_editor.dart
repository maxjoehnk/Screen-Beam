import 'package:digital_signage/api/models/slide.dart';
import 'package:flutter/material.dart';

class TextEditor extends StatefulWidget {
  final TextLayerModel layer;
  final Function(TextLayerModel) onChange;
  final bool scrollable;

  const TextEditor(
      {super.key,
      required this.layer,
      required this.onChange,
      this.scrollable = true});

  @override
  State<TextEditor> createState() => _TextEditorState();
}

class _TextEditorState extends State<TextEditor> {
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    _textController.text = widget.layer.text;
    super.initState();
  }

  @override
  void didUpdateWidget(TextEditor oldWidget) {
    if (widget.layer.text != _textController.text) {
      _textController.text = widget.layer.text;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: widget.scrollable
            ? ListView(
                children: _children(textTheme, scrollable: true),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _children(textTheme),
              ),
      ),
    );
  }

  List<Widget> _children(TextTheme textTheme, {bool scrollable = false}) {
    var formField = TextFormField(
      maxLines: null,
      controller: _textController,
      onChanged: (value) => widget.onChange(widget.layer.copyWith(text: value)),
    );
    return [
      Text("Text", style: textTheme.titleLarge),
      if (scrollable)
        formField
      else
        Expanded(
          child: formField,
        ),
    ];
  }
}
