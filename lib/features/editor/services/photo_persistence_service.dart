import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

class PhotoPersistenceService {
  const PhotoPersistenceService();

  static const MethodChannel _mediaChannel = MethodChannel(
    'com.guillot.phylactere/media',
  );

  Future<void> saveBytes({
    required Uint8List bytes,
    required String targetPath,
  }) async {
    final targetFile = File(targetPath);
    await targetFile.writeAsBytes(bytes, flush: true);
    await _refreshGallery(targetPath);
  }

  String buildSiblingPath(String sourcePath, String extension) {
    final folder = p.dirname(sourcePath);
    final stem = p.basenameWithoutExtension(sourcePath);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return p.join(folder, '${stem}_phylactere_$timestamp$extension');
  }

  Future<void> _refreshGallery(String path) async {
    if (!Platform.isAndroid) {
      return;
    }

    try {
      await _mediaChannel.invokeMethod<void>('scanFile', {'path': path});
    } on PlatformException {
      // The file is already written; missing gallery refresh is non-blocking.
    }
  }
}
