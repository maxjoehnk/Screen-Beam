import 'dart:developer';

import 'package:digital_signage/api/models/slide.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

Future<ImageLayerModel?> pickImage({ ImageLayerModel? previous }) async {
  var file = await ImagePicker().pickImage(source: ImageSource.gallery);
  if (file == null) {
    return previous;
  }
  String? mimeType = file.mimeType ?? lookupMimeType(file.path);
  if (mimeType == null) {
    throw Exception("Could not determine mime type for ${file.path}");
  }
  log("${file.path} ${file.name} $mimeType");
  var bytes = await file.readAsBytes();
  ImageLayerModel? next;
  if (previous != null) {
    next = previous.replaceImage(bytes, mimeType);
  }else {
    next = ImageLayerModel.create(bytes, mimeType);
  }

  return next;
}
