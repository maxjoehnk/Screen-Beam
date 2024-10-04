import 'package:digital_signage/states/slides_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'slide_editor_state.dart';
import 'slide_view.dart';

class SlideViewRoute extends StatelessWidget {
  final String slideId;

  const SlideViewRoute({super.key, required this.slideId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SlidesCubit, SlidesState>(builder: (context, state) {
      var slide = state.getSlideById(slideId);

      if (slide == null) {
        return Scaffold(
          appBar: AppBar(
              leading: const BackButton(), title: const Text("Loading...")),
          body: Container(),
        );
      }

      return BlocProvider(
          create: (context) => SlideEditorCubit(
              OnlineSlideEditorContext(context.read(), context.read())),
          child: SlideDetails(slide: slide, onBack: () => context.go('/')));
    });
  }
}
