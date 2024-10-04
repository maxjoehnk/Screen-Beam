import 'dart:convert';
import 'dart:typed_data';

import 'package:digital_signage/api/models/slide.dart';
import 'package:archive/archive_io.dart';

class SlideExporter {
  static Future<Uint8List> export(SlideModel slide, Map<String, Uint8List> images) async {
    for (var value in slide.layers) {
      if (value is ImageLayerModel) {
        if (!value.persisted) {
          images[value.id] = value.imageData!;
        }
      }
    }

    var archive = Archive();
    var json = jsonEncode(slide.toJson());
    archive.addFile(ArchiveFile('slide.json', -1, json));
    for (var entry in images.entries) {
      archive.addFile(ArchiveFile('images/${entry.key}', -1, entry.value));
    }
    var encoder = ZipEncoder();
    var stream = OutputStream();
    encoder.encode(archive, output: stream);
    var data = stream.getBytes();

    return Uint8List.fromList(data);
  }
}
