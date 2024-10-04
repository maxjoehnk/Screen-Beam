import 'package:digital_signage/api/models/screen.dart';
import 'package:digital_signage/api/models/slide.dart';
import 'package:digital_signage/states/screens_state.dart';
import 'package:digital_signage/states/slides_state.dart';
import 'package:digital_signage/widgets/confirm_dialog.dart';
import 'package:digital_signage/widgets/slide_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'dialogs/select_slide_dialog.dart';

class ScreenSlideList extends StatefulWidget {
  final ScreenModel screen;

  const ScreenSlideList({super.key, required this.screen});

  @override
  State<ScreenSlideList> createState() => _ScreenSlideListState();
}

class _ScreenSlideListState extends State<ScreenSlideList> {
  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    if (widget.screen.slides.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("No slides added yet", style: textTheme.titleLarge),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: () async {
                  var slides = context.read<SlidesCubit>().state.slides;
                  SlideModel? slide = await showDialog(
                      context: context, builder: (context) => SelectSlideDialog(slides: slides));
                  if (slide != null) {
                    if (!context.mounted) {
                      return;
                    }
                    context.read<ScreensCubit>().addSlide(widget.screen.id, slide.id);
                  }
                },
                child: const Text("Add Slide"))
          ],
        ),
      );
    }
    return ReorderableListView.builder(
      itemCount: widget.screen.slides.length,
      onReorder: (oldIndex, newIndex) {
        context.read<ScreensCubit>().reorderSlide(widget.screen.id, oldIndex, newIndex);
      },
      buildDefaultDragHandles: false,
      itemBuilder: (context, index) {
        SlideModel slide = widget.screen.slides[index];
        return ListTile(
          key: ValueKey(slide.id),
          contentPadding: const EdgeInsets.all(4),
          leading: ReorderableDragStartListener(index: index, child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              clipBehavior: Clip.antiAlias,
              child: SlidePreview(slide))),
          title: Text(slide.name),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              ConfirmDialog.show(context, "Remove Slide", "Remove Slide ${slide.name}?")
                  .then((confirmed) {
                if (confirmed) {
                  context.read<ScreensCubit>().deleteSlide(widget.screen.id, slide.id);
                }
              });
            },
          ),
        );
      },
    );
  }
}
