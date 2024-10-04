import 'package:collection/collection.dart';
import 'package:digital_signage/api/models/slide.dart';
import 'package:digital_signage/states/screens_state.dart';
import 'package:digital_signage/states/slides_state.dart';
import 'package:digital_signage/views/screen_view/screen_slide_carousel.dart';
import 'package:digital_signage/widgets/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'dialogs/select_slide_dialog.dart';
import 'screen_slide_list.dart';

enum ViewMode {
  Carousel,
  List,
}

class ScreenViewRoute extends StatefulWidget {
  final String screenId;

  const ScreenViewRoute({super.key, required this.screenId});

  @override
  State<ScreenViewRoute> createState() => _ScreenViewRouteState();
}

class _ScreenViewRouteState extends State<ScreenViewRoute> {
  ViewMode viewMode = ViewMode.List;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScreensCubit, ScreensState>(builder: (context, state) {
      var screen = state.getScreenById(widget.screenId);

      if (screen == null) {
        return Scaffold(
          appBar: AppBar(leading: const BackButton(), title: const Text("Loading...")),
          body: Container(),
        );
      }

      return Scaffold(
          appBar: AppBar(
            leading: BackButton(onPressed: () => context.go('/')),
            title: Text("Screen ${screen.name}"),
            actions: [
              _viewMode(ViewMode.List, Icons.view_list),
              _viewMode(ViewMode.Carousel, Icons.view_carousel_outlined),
              TextButton(
                  onPressed: () {
                    ConfirmDialog.show(context, "Delete Screen", "Delete Screen ${screen.name}?")
                        .then((confirmed) {
                      if (confirmed) {
                        context.read<ScreensCubit>().deleteScreen(screen.id);
                        context.go('/');
                      }
                    });
                  },
                  child: const Text("Delete Screen")),
            ],
          ),
          body: viewMode == ViewMode.List
              ? ScreenSlideList(screen: screen)
              : ScreenSlideCarousel(screen: screen),
          floatingActionButton: screen.slides.isEmpty
              ? null
              : FloatingActionButton.extended(
                  onPressed: () async {
                    var slides = context
                        .read<SlidesCubit>()
                        .state
                        .slides
                        .where((s) => screen.slides.none((ss) => ss.id == s.id))
                        .toList();
                    SlideModel? slide = await showDialog(
                        context: context, builder: (context) => SelectSlideDialog(slides: slides));
                    if (slide != null) {
                      if (!context.mounted) {
                        return;
                      }
                      context.read<ScreensCubit>().addSlide(widget.screenId, slide.id);
                    }
                  },
                  label: const Text("Add Slide"),
                  icon: const Icon(Icons.add),
                ));
    });
  }

  Widget _viewMode(ViewMode viewMode, IconData icon) {
    return IconButton(
        isSelected: this.viewMode == viewMode,
        color: this.viewMode == viewMode ? Theme.of(context).colorScheme.primary : null,
        onPressed: () => setState(() => this.viewMode = viewMode),
        icon: Icon(icon));
  }
}
