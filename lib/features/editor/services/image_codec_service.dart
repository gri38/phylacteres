import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:image/image.dart' as img;

class ImageCodecService {
  const ImageCodecService();

  Future<ui.Image> decodeUiImage(Uint8List bytes) async {
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    final descriptor = await ui.ImageDescriptor.encoded(buffer);
    final codec = await descriptor.instantiateCodec();
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  Future<ui.Size> decodeImageSize(Uint8List bytes) async {
    final image = await decodeUiImage(bytes);
    return ui.Size(image.width.toDouble(), image.height.toDouble());
  }

  Future<Uint8List> normalizeSourceBytes(
    Uint8List bytes,
    String extension,
  ) async {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      return bytes;
    }

    final baked = img.bakeOrientation(decoded);
    return Uint8List.fromList(encodeRaster(baked, extension));
  }

  List<int> encodeRaster(img.Image image, String extension) {
    if (extension == '.png') {
      return img.encodePng(image);
    }
    return img.encodeJpg(image, quality: 96);
  }

  String normalizedExtension(String extension) {
    if (extension.toLowerCase() == '.png') {
      return '.png';
    }
    return '.jpg';
  }
}
