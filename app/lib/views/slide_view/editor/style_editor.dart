import 'package:digital_signage/api/models/slide.dart';
import 'package:digital_signage/widgets/color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'font_style_selector.dart';
import 'font_weight_selector.dart';

class StyleEditor extends StatefulWidget {
  final TextLayerModel layer;
  final Function(TextLayerModel) onChange;
  final bool scrollable;

  const StyleEditor(
      {super.key,
      required this.layer,
      required this.onChange,
      this.scrollable = true});

  @override
  State<StyleEditor> createState() => _StyleEditorState();
}

class _StyleEditorState extends State<StyleEditor> {
  final TextEditingController _xController = TextEditingController();
  final TextEditingController _yController = TextEditingController();
  final TextEditingController _fontSizeController = TextEditingController();
  final TextEditingController _textHeightController = TextEditingController();

  @override
  void initState() {
    _xController.text = widget.layer.x.toString();
    _yController.text = widget.layer.y.toString();
    _fontSizeController.text = widget.layer.fontSize.toString();
    _textHeightController.text = widget.layer.lineHeight?.toString() ?? "";
    super.initState();
  }

  @override
  void didUpdateWidget(StyleEditor oldWidget) {
    _xController.text = widget.layer.x.toString();
    _yController.text = widget.layer.y.toString();
    _fontSizeController.text = widget.layer.fontSize.toString();
    _textHeightController.text = widget.layer.lineHeight?.toString() ?? "";
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
                children: _children(textTheme),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _children(textTheme),
              ),
      ),
    );
  }

  List<Widget> _children(TextTheme textTheme) {
    return [
      Text("Style", style: textTheme.titleLarge),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _xController,
                decoration: const InputDecoration(label: Text("X")),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9\-]'))
                ],
                onChanged: (value) =>
                    widget.onChange(widget.layer.copyWith(x: int.parse(value))),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _yController,
                decoration: const InputDecoration(label: Text("Y")),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9\-]'))
                ],
                onChanged: (value) =>
                    widget.onChange(widget.layer.copyWith(y: int.parse(value))),
              ),
            ),
          ),
          Expanded(
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<TextAlignModel>(
                  decoration: const InputDecoration(label: Text("Alignment")),
                  value: widget.layer.alignment,
                  onChanged: (value) =>
                      widget.onChange(widget.layer.copyWith(alignment: value)),
                  items: const [
                    DropdownMenuItem(
                        value: TextAlignModel.Start, child: Text("Start")),
                    DropdownMenuItem(
                        value: TextAlignModel.Center, child: Text("Center")),
                    DropdownMenuItem(
                        value: TextAlignModel.End, child: Text("End"))
                  ],
                )),
          )
        ],
      ),
      Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _fontSizeController,
                decoration: const InputDecoration(label: Text("Font Size")),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) => widget.onChange(
                    widget.layer.copyWith(fontSize: int.parse(value))),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _textHeightController,
                decoration: const InputDecoration(label: Text("Line Height")),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) => widget.onChange(
                    widget.layer.copyWith(lineHeight: int.parse(value))),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FontStyleSelector(
                widget.layer.italic,
                (value) => widget.onChange(widget.layer.copyWith(italic: value)),
              ),
            ),
          ),
        ],
      ),
      Row(
        children: [
          Flexible(
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(label: Text("Font")),
                  value: widget.layer.font,
                  onChanged: (value) =>
                      widget.onChange(widget.layer.copyWith(font: value)),
                  items: const [
                    DropdownMenuItem(value: "Arial", child: Text("Arial")),
                    DropdownMenuItem(value: "Ubuntu", child: Text("Ubuntu")),
                    DropdownMenuItem(
                        value: "Liberation Sans", child: Text("Liberation Sans")),
                  ],
                )),
          ),
          Flexible(
            child: FontWeightSelector(
              widget.layer.fontWeight,
              (value) => widget.onChange(widget.layer.copyWith(weight: value)),
            ),
          )
        ],
      ),
      ColorFormField(
        color: widget.layer.color,
        label: const Text("Text Color"),
        onChange: (color) =>
            widget.onChange(widget.layer.copyWith(color: color)),
      )
    ];
  }
}
