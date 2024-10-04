import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:digital_signage/api/models/slide.dart';

class SlideImporter {
  static Future<SlideModel> import(Uint8List data) async {
    InputStream stream = InputStream(data);
    ZipDecoder decoder = ZipDecoder();
    Archive archive = decoder.decodeBuffer(stream);
    ArchiveFile slideJson = archive.findFile('slide.json')!;
    SlideModel slideModel = SlideModel.fromJson(jsonDecode(utf8.decode(slideJson.content as Uint8List)));
    List<SlideLayerModel> layers = [];
    for (var layer in slideModel.layers) {
      if (layer is ImageLayerModel) {
        var imageFile = archive.findFile('images/${layer.id}');
        if (imageFile != null) {
          layers.add(layer.replaceImage(imageFile.content, layer.contentType));
        }
      }else {
        layers.add(layer);
      }
    }

    return SlideModel(
      id: slideModel.id,
      name: slideModel.name,
      layers: layers,
      screenUsage: slideModel.screenUsage
    );
  }
}
