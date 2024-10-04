import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:digital_signage/api/clients/http_client.dart';
import 'package:digital_signage/api/clients/layers_api_client.dart';
import 'package:digital_signage/api/clients/slide_api_client.dart';
import 'package:digital_signage/api/models/slide.dart';
import 'package:digital_signage/slide_export/slide_exporter.dart';
import 'package:file_selector/file_selector.dart';

class SlideEditorState {
  final SlideModel? slide;
  final SlideLayerModel? selectedLayer;
  final bool hasChanges;

  final bool canDelete;

  SlideEditorState(
      {this.slide,
      this.selectedLayer,
      this.canDelete = true,
      this.hasChanges = false});

  factory SlideEditorState.empty() {
    return SlideEditorState();
  }
}

abstract class SlideEditorContext {
  bool get canDelete;

  Future<void> saveSlide(SlideModel slide);
}

class OnlineSlideEditorContext implements SlideEditorContext {
  final LayersApiClient _layersApiClient;
  final SlidesApiClient _slidesApiClient;

  OnlineSlideEditorContext(this._slidesApiClient, this._layersApiClient);

  @override
  bool get canDelete => true;

  @override
  Future<void> saveSlide(SlideModel slide) async {
    for (var layer in slide.layers) {
      if (layer is ImageLayerModel && layer.imageData != null) {
        await _layersApiClient.uploadImage(slide.id, layer);
      }
    }
    await _slidesApiClient.updateSlide(slide);
  }
}

class SlideEditorCubit extends Cubit<SlideEditorState> {
  final SlideEditorContext _context;

  SlideEditorCubit(this._context) : super(SlideEditorState.empty());

  void openSlide(SlideModel slide) {
    _emitState(slide: slide);
  }

  Future<void> save() async {
    if (state.slide == null) {
      return;
    }
    await _context.saveSlide(state.slide!);
    _emitState(
        slide: state.slide,
        selectedLayer: state.selectedLayer,
        hasChanges: false);
  }

  void selectLayer(SlideLayerModel layer) {
    _emitState(
        slide: state.slide, selectedLayer: layer, hasChanges: state.hasChanges);
  }

  void addLayer(SlideLayerModel layer) {
    if (state.slide == null) {
      return;
    }
    SlideModel slide = state.slide!;
    slide.layers.add(layer);

    _emitState(slide: slide, selectedLayer: layer, hasChanges: true);
  }

  void renameLayer(SlideLayerModel layer, String name) {
    if (state.slide == null) {
      return;
    }
    var index = state.slide!.layers.indexOf(layer);
    SlideLayerModel newLayer = layer.setName(name);
    state.slide!.layers[index] = newLayer;

    _emitState(
        slide: state.slide,
        selectedLayer: state.selectedLayer,
        hasChanges: true);
  }

  void removeLayer(SlideLayerModel layer) {
    if (state.slide == null) {
      return;
    }
    SlideModel slide = state.slide!;
    slide.layers.remove(layer);
    SlideLayerModel? selectedLayer =
        state.selectedLayer == layer ? null : state.selectedLayer;

    _emitState(slide: slide, selectedLayer: selectedLayer, hasChanges: true);
  }

  void updateLayer(SlideLayerModel layer) {
    var index = state.slide!.layers.indexOf(state.selectedLayer!);
    state.slide!.layers[index] = layer;

    _emitState(slide: state.slide, selectedLayer: layer, hasChanges: true);
  }

  void rename(String name) {
    SlideModel slide = SlideModel(
        id: state.slide!.id,
        name: name,
        layers: state.slide!.layers,
        screenUsage: state.slide!.screenUsage);
    _emitState(
        slide: slide, selectedLayer: state.selectedLayer, hasChanges: true);
  }

  void _emitState(
      {required SlideModel? slide,
      SlideLayerModel? selectedLayer,
      bool? hasChanges}) {
    emit(SlideEditorState(
        slide: slide,
        selectedLayer: selectedLayer,
        hasChanges: hasChanges ?? state.hasChanges,
        canDelete: _context.canDelete
    ));
  }

  void export(String path, Map<String, Uint8List> images) async {
    var archive = await SlideExporter.export(state.slide!, images);
    var file = XFile.fromData(archive);
    file.saveTo(path);
  }

  Future<Map<String, Uint8List>> fetchImages(HttpClient httpClient) async {
    Map<String, Uint8List> images = {};
    for (var value in state.slide!.layers) {
      if (value is ImageLayerModel) {
        if (value.persisted) {
          var response = await httpClient.get('layers/${value.id}/data');
          if (response.statusCode == 200) {
            images[value.id] = response.bodyBytes;
          }
        }
      }
    }

    return images;
  }
}
