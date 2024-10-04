import 'dart:convert';

import 'package:digital_signage/api/models/slide.dart';

import 'http_client.dart';

class SlidesApiClient {
  final HttpClient httpClient;

  SlidesApiClient({required this.httpClient});

  Future<List<SlideModel>> fetchSlides() async {
    final response = await httpClient.get('slides');

    if (response.statusCode != 200) {
      throw Exception('error getting slides');
    }

    final json = jsonDecode(utf8.decode(response.bodyBytes)) as List;
    return json.map((slide) => SlideModel.fromJson(slide)).toList();
  }

  addSlide(String name, { String? id }) async {
    final response = await httpClient.post(
      'slides',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String?>{
        'name': name,
        'id': id,
      }),
    );

    if (response.statusCode != 204) {
      throw Exception('error adding slide');
    }
  }

  updateSlide(SlideModel slide) async {
    final response = await httpClient.put(
      'slides/${slide.id}',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(slide.toJson()),
    );

    if (response.statusCode != 204) {
      throw Exception('error updating slide');
    }
  }

  deleteSlide(String slideId) async {
    final response = await httpClient.delete(
      'slides/$slideId',
    );

    if (response.statusCode != 204) {
      throw Exception('error removing slide');
    }
  }
}
