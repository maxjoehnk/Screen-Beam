import 'dart:developer';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:digital_signage/api/clients/layers_api_client.dart';
import 'package:digital_signage/api/clients/slide_api_client.dart';
import 'package:digital_signage/api/models/slide.dart';

import '../slide_export/slide_importer.dart';

class SlidesState {
  final List<SlideModel> slides;
  final bool isLoading;
  final bool hasError;

  SlidesState(
      {required this.slides, this.isLoading = false, this.hasError = false});

  factory SlidesState.empty() {
    return SlidesState(slides: []);
  }

  SlideModel? getSlideById(String id) {
    return slides.firstWhereOrNull((element) => element.id == id);
  }
}

class SlidesCubit extends Cubit<SlidesState> {
  final LayersApiClient _layersApiClient;
  final SlidesApiClient _slidesApiClient;

  SlidesCubit(this._slidesApiClient, this._layersApiClient) : super(SlidesState.empty()) {
    fetchSlides();
  }

  void fetchSlides() async {
    emit(SlidesState(slides: [], isLoading: true));
    _slidesApiClient.fetchSlides().then((slides) {
      emit(SlidesState(slides: slides));
    }).catchError((error) {
      log(error: error, error.toString());
      emit(SlidesState(slides: [], hasError: true));
    });
  }

  Future<void> import(Uint8List data) async {
    var slide = await SlideImporter.import(data);
    await _slidesApiClient.addSlide(slide.name, id: slide.id);
    for (var layer in slide.layers) {
      if (layer is ImageLayerModel && layer.imageData != null) {
        await _layersApiClient.uploadImage(slide.id, layer);
      }
    }
    await _slidesApiClient.updateSlide(slide);
    fetchSlides();
  }

  Future<void> addSlide(String name) async {
    await _slidesApiClient.addSlide(name);
    fetchSlides();
  }

  Future<void> deleteSlide(String slideId) async {
    await _slidesApiClient.deleteSlide(slideId);
    fetchSlides();
  }
}
