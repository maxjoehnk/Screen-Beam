import 'package:digital_signage/api/models/slide.dart';
import 'package:digital_signage/widgets/color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShadowEditor extends StatefulWidget {
  final TextLayerModel layer;
  final Function(TextLayerModel) onChange;
  final bool scrollable;

  const ShadowEditor({super.key, required this.layer, required this.onChange, this.scrollable = true});

  @override
  State<ShadowEditor> createState() => _ShadowEditorState();
}

class _ShadowEditorState extends State<ShadowEditor> {
  final TextEditingController _xController = TextEditingController();
  final TextEditingController _yController = TextEditingController();

  @override
  void initState() {
    _xController.text = widget.layer.shadow?.xOffset.toString() ?? "";
    _yController.text = widget.layer.shadow?.yOffset.toString() ?? "";
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ShadowEditor oldWidget) {
    _xController.text = widget.layer.shadow?.xOffset.toString() ?? "";
    _yController.text = widget.layer.shadow?.yOffset.toString() ?? "";
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Card(
        child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: widget.scrollable ? ListView(
        children: _children(textTheme),
      ) : Column(
        mainAxisSize: MainAxisSize.min,
        children: _children(textTheme),
      )
    ));
  }

  List<Widget> _children(TextTheme textTheme) {
    return [
        Row(
          children: [
            Expanded(child: Text("Shadow", style: textTheme.titleLarge)),
            Switch(
              value: widget.layer.shadow != null,
              onChanged: (value) {
                if (value) {
                  widget.onChange(
                      widget.layer.copyWith(shadow: TextShadowModel.empty()));
                } else {
                  widget.onChange(widget.layer.clearShadow());
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _xController,
                  decoration: const InputDecoration(label: Text("X Offset")),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) => widget.onChange(widget.layer.copyWith(
                      shadow: widget.layer.shadow
                          ?.copyWith(xOffset: int.parse(value)))),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _yController,
                  decoration: const InputDecoration(label: Text("Y Offset")),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) => widget.onChange(widget.layer.copyWith(
                      shadow: widget.layer.shadow
                          ?.copyWith(yOffset: int.parse(value)))),
                ),
              ),
            ),
          ],
        ),
        ColorFormField(
          color: widget.layer.shadow?.color ??
              ColorModel(red: 0, green: 0, blue: 0, alpha: 255),
          label: const Text("Shadow Color"),
          onChange: (color) => widget.onChange(widget.layer
              .copyWith(shadow: widget.layer.shadow?.copyWith(color: color))),
        )
      ];
  }
}
