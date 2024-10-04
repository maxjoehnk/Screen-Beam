import 'package:digital_signage/api/models/slide.dart';
import 'package:digital_signage/states/slides_state.dart';
import 'package:digital_signage/views/slide_view/slide_desktop_view.dart';
import 'package:digital_signage/widgets/confirm_dialog.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'dialogs/rename_slide_dialog.dart';
import 'slide_editor_state.dart';
import 'slide_mobile_view.dart';

class SlideDetails extends StatefulWidget {
  final SlideModel slide;
  final Function() onBack;

  const SlideDetails({super.key, required this.slide, required this.onBack});

  @override
  State<SlideDetails> createState() => _SlideDetailsState();
}

class _SlideDetailsState extends State<SlideDetails> {
  @override
  void initState() {
    super.initState();
    context.read<SlideEditorCubit>().openSlide(widget.slide);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SlideEditorCubit, SlideEditorState>(
      builder: (context, state) {
        return Scaffold(
            appBar: AppBar(
              leading: BackButton(onPressed: widget.onBack),
              title: Text("Slide ${state.slide!.name}"),
              actions: [
                TextButton(
                    onPressed: () async {
                      String? name = await showDialog(
                          context: context,
                          builder: (context) =>
                              RenameSlideDialog(name: state.slide!.name));
                      if (name == null) {
                        return;
                      }
                      if (!context.mounted) {
                        return;
                      }
                      context.read<SlideEditorCubit>().rename(name);
                    },
                    child: const Text("Rename")),
                if (state.canDelete) TextButton(
                    onPressed: () {
                      ConfirmDialog.show(context, "Delete Slide",
                              "Delete Slide ${state.slide!.name}?")
                          .then((confirmed) {
                        if (confirmed) {
                          context
                              .read<SlidesCubit>()
                              .deleteSlide(state.slide!.id);
                          context.go('/');
                        }
                      });
                    },
                    child: const Text("Delete")),
                TextButton(
                    onPressed: () async {
                      FileSaveLocation? saveLocation = await getSaveLocation(
                        acceptedTypeGroups: [
                          XTypeGroup(
                            label: 'zip',
                            extensions: ['zip'],
                          ),
                        ],
                        suggestedName: state.slide!.name.isEmpty ? 'Slide.zip' : '${state.slide!.name}.zip',
                      );
                      if (saveLocation == null) {
                        return;
                      }
                      if (!context.mounted) {
                        return;
                      }
                      var editorCubit = context.read<SlideEditorCubit>();
                      var images = await editorCubit.fetchImages(context.read());
                      editorCubit.export(saveLocation.path, images);
                    },
                    child: const Text("Export")),
              ],
            ),
            body: buildContent(context, state),
            floatingActionButton: !state.hasChanges
                ? null
                : FloatingActionButton.extended(
                    onPressed: () => context.read<SlideEditorCubit>().save(),
                    label: const Text("Save"),
                    icon: const Icon(Icons.save),
                  ));
      },
    );
  }

  Widget buildContent(BuildContext context, SlideEditorState state) {
    if (MediaQuery.sizeOf(context).width < 600) {
      return SlideMobileView(
          slide: widget.slide, selectedLayer: state.selectedLayer);
    }
    return SlideDesktopView(
        slide: widget.slide, selectedLayer: state.selectedLayer);
  }
}
