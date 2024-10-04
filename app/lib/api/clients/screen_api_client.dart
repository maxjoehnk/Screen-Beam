import 'dart:convert';

import 'package:digital_signage/api/models/screen.dart';

import 'http_client.dart';

class ScreensApiClient {
  final HttpClient httpClient;

  ScreensApiClient({required this.httpClient});

  Future<List<ScreenModel>> fetchScreens() async {
    final response = await httpClient.get('screens');

    if (response.statusCode != 200) {
      throw Exception('error getting screens');
    }

    final json = jsonDecode(utf8.decode(response.bodyBytes)) as List;
    return json.map((screen) => ScreenModel.fromJson(screen)).toList();
  }

  addScreen(String name) async {
    final response = await httpClient.post(
      'screens',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': name,
      }),
    );

    if (response.statusCode != 204) {
      throw Exception('error adding screen');
    }
  }

  addSlide(String screenId, String slideId) async {
    final response = await httpClient.post(
      'screens/$screenId/slides',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'slideId': slideId,
      }),
    );

    if (response.statusCode != 204) {
      throw Exception('error adding slide');
    }
  }

  deleteScreen(String screenId) async {
    final response = await httpClient.delete(
      'screens/$screenId',
    );

    if (response.statusCode != 204) {
      throw Exception('error removing screen');
    }
  }

  deleteSlide(String screenId, String slideId) async {
    final response = await httpClient.delete(
      'screens/$screenId/slides/$slideId',
    );

    if (response.statusCode != 204) {
      throw Exception('error removing slide');
    }
  }

  reorderSlide(String screenId, int oldIndex, int newIndex) async {
    final response = await httpClient.post(
      'screens/$screenId/slides/reorder',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'oldIndex': oldIndex,
        'newIndex': newIndex,
      }),
    );

    if (response.statusCode != 204) {
      throw Exception('error reordering slide');
    }
  }
}
