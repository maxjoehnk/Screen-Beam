import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:digital_signage/api/clients/screen_api_client.dart';
import 'package:digital_signage/api/models/screen.dart';

class ScreensState {
  final List<ScreenModel> screens;
  final bool isLoading;
  final bool hasError;

  ScreensState(
      {required this.screens, this.isLoading = false, this.hasError = false});

  factory ScreensState.empty() {
    return ScreensState(screens: []);
  }

  ScreenModel? getScreenById(String id) {
    return screens.firstWhereOrNull((screen) => screen.id == id);
  }
}

class ScreensCubit extends Cubit<ScreensState> {
  final ScreensApiClient _screensApiClient;

  ScreensCubit(this._screensApiClient) : super(ScreensState.empty()) {
    fetchScreens();
  }

  void fetchScreens() async {
    emit(ScreensState(screens: [], isLoading: true));
    _screensApiClient.fetchScreens().then((screens) {
      emit(ScreensState(screens: screens));
    }).catchError((error) {
      log(error: error, error.toString());
      emit(ScreensState(screens: [], hasError: true));
    });
  }

  Future<void> addScreen(String name) async {
    await _screensApiClient.addScreen(name);
    fetchScreens();
  }

  void addSlide(String screenId, String slideId) async {
    await _screensApiClient.addSlide(screenId, slideId);
    fetchScreens();
  }

  void deleteSlide(String screenId, String slideId) async {
    await _screensApiClient.deleteSlide(screenId, slideId);
    fetchScreens();
  }

  void deleteScreen(String screenId) async {
    await _screensApiClient.deleteScreen(screenId);
    fetchScreens();
  }

  void reorderSlide(String screenId, int oldIndex, int newIndex) async {
    await _screensApiClient.reorderSlide(screenId, oldIndex, newIndex);
    fetchScreens();
  }
}
