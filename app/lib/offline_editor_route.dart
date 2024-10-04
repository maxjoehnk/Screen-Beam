import 'package:digital_signage/api/models/slide.dart';
import 'package:digital_signage/states/server_state.dart';
import 'package:digital_signage/views/slide_view/slide_view.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import 'slide_export/slide_exporter.dart';
import 'views/slide_view/slide_editor_state.dart';

class OfflineEditorRoute extends StatefulWidget {
  const OfflineEditorRoute({super.key});

  @override
  State<OfflineEditorRoute> createState() => _OfflineEditorRouteState();
}

class _OfflineEditorRouteState extends State<OfflineEditorRoute>
    implements SlideEditorContext {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => SlideEditorCubit(this),
        child: SlideDetails(
            slide: SlideModel(
                id: Uuid().v4(), name: '', layers: [], screenUsage: 0),
            onBack: () => context.read<ServerCubit>().closeOfflineEditor()));
  }

  @override
  Future<void> saveSlide(SlideModel slide) async {
    FileSaveLocation? saveLocation = await getSaveLocation(
      acceptedTypeGroups: [
        XTypeGroup(
          label: 'zip',
          extensions: ['zip'],
        ),
      ],
      suggestedName: slide.name.isEmpty ? 'Slide.zip' : '${slide.name}.zip',
    );
    if (saveLocation == null) {
      throw Exception('Operation was cancelled');
    }
    if (!context.mounted) {
      throw Exception('Context is not mounted');
    }
    var archive = await SlideExporter.export(slide, {});
    var file = XFile.fromData(archive);
    file.saveTo(saveLocation.path);
  }

  @override
  bool get canDelete => false;
}
