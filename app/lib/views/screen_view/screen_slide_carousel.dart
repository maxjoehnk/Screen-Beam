import 'package:digital_signage/api/models/screen.dart';
import 'package:digital_signage/api/models/slide.dart';
import 'package:digital_signage/states/screens_state.dart';
import 'package:digital_signage/states/slides_state.dart';
import 'package:digital_signage/widgets/confirm_dialog.dart';
import 'package:digital_signage/widgets/slide_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'dialogs/select_slide_dialog.dart';

class ScreenSlideCarousel extends StatefulWidget {
  final ScreenModel screen;

  const ScreenSlideCarousel({super.key, required this.screen});

  @override
  State<ScreenSlideCarousel> createState() => _ScreenSlideCarouselState();
}

class _ScreenSlideCarouselState extends State<ScreenSlideCarousel> {
  final PageController _controller = PageController();

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
                      context: context,
                      builder: (context) => SelectSlideDialog(slides: slides));
                  if (slide != null) {
                    if (!context.mounted) {
                      return;
                    }
                    context
                        .read<ScreensCubit>()
                        .addSlide(widget.screen.id, slide.id);
                  }
                },
                child: const Text("Add Slide"))
          ],
        ),
      );
    }
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800, minWidth: 0),
        child: Column(
          children: [
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 500, minHeight: 0),
                child: PageView(
                  controller: _controller,
                  children: widget.screen.slides.map((slide) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                            constraints: const BoxConstraints(
                                maxHeight: 500, minHeight: 0),
                            padding: const EdgeInsets.all(16),
                            child: SlidePreview(slide)),
                        Expanded(
                          child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(slide.name, style: textTheme.titleLarge),
                                      Expanded(child: Container()),
                                      Row(children: [
                                        TextButton(
                                            onPressed: () {
                                              ConfirmDialog.show(
                                                  context,
                                                  "Remove Slide",
                                                  "Remove Slide ${slide.name}?")
                                                  .then((confirmed) {
                                                if (confirmed) {
                                                  context
                                                      .read<ScreensCubit>()
                                                      .deleteSlide(
                                                      widget.screen.id, slide.id);
                                                }
                                              });
                                            },
                                            style: ButtonStyle(
                                                foregroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.red)),
                                            child: const Text("Remove Slide")),
                                      ])
                                    ]),
                              )),
                        )
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SmoothPageIndicator(
              controller: _controller,
              count: widget.screen.slides.length,
              effect: const ExpandingDotsEffect(),
              onDotClicked: (index) => _controller.animateToPage(index,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
