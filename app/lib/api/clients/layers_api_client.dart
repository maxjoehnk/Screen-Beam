import 'package:digital_signage/api/models/slide.dart';
import 'http_client.dart';

class LayersApiClient {
  final HttpClient httpClient;

  LayersApiClient({required this.httpClient});

  uploadImage(String slideId, ImageLayerModel imageLayer) async {
    assert(imageLayer.imageData != null, 'image data must be set');
    final response = await httpClient.post(
      'slides/$slideId/layers/${imageLayer.id}',
      body: imageLayer.imageData!,
      headers: {'Content-Type': imageLayer.contentType},
    );

    if (response.statusCode != 204) {
      throw Exception('error uploading image');
    }
  }
}
