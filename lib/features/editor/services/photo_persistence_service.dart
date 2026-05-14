import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

class PhotoPersistenceService {
  const PhotoPersistenceService();

  static const MethodChannel _mediaChannel = MethodChannel(
    'com.guillot.phylactere/media',
  );
  static const String _preferredOutputFolderName = 'Phylactères';

  Future<String> saveBytes({
    required Uint8List bytes,
    required String sourcePath,
    required String extension,
  }) async {
    if (Platform.isAndroid) {
      final savedLabel = await _mediaChannel.invokeMethod<String>('saveImage', {
        'bytes': bytes,
        'sourcePath': sourcePath,
        'extension': extension,
        'mimeType': _mimeTypeForExtension(extension),
      });
      if (savedLabel == null || savedLabel.isEmpty) {
        throw const FileSystemException(
          'Impossible de confirmer l’enregistrement de l’image.',
        );
      }
      return savedLabel;
    }

    final targetPath = buildOutputPath(sourcePath, extension);
    final targetFile = File(targetPath);
    await targetFile.parent.create(recursive: true);
    await targetFile.writeAsBytes(bytes, flush: true);
    await _refreshGallery(targetPath);
    return targetPath;
  }

  Future<void> shareBytes({
    required Uint8List bytes,
    required String sourcePath,
    required String extension,
  }) async {
    final fileName = buildShareFileName(sourcePath, extension);

    if (!Platform.isAndroid) {
      throw UnsupportedError(
        'Le partage est disponible uniquement sur Android dans cette version.',
      );
    }

    await _mediaChannel.invokeMethod<void>('shareImage', {
      'bytes': bytes,
      'fileName': fileName,
      'mimeType': _mimeTypeForExtension(extension),
    });
  }

  String buildShareFileName(String sourcePath, String extension) {
    final stem = p.basenameWithoutExtension(sourcePath);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${stem}_phylactere_$timestamp$extension';
  }

  String buildOutputPath(String sourcePath, String extension) {
    final sourceDirectory = p.dirname(sourcePath);
    final directory = _resolveOutputDirectory(sourceDirectory);
    final stem = p.basenameWithoutExtension(sourcePath);
    final baseName = '${stem}_phylactere';

    var index = 1;
    while (true) {
      final suffix = index.toString().padLeft(3, '0');
      final candidate = p.join(directory.path, '${baseName}_$suffix$extension');
      if (!File(candidate).existsSync()) {
        return candidate;
      }
      index++;
    }
  }

  String outputFolderName() => _preferredOutputFolderName;

  Directory _resolveOutputDirectory(String sourceDirectory) {
    final preferredDirectory = Directory(
      p.join(sourceDirectory, _preferredOutputFolderName),
    );
    if (preferredDirectory.existsSync()) {
      return preferredDirectory;
    }

    return preferredDirectory;
  }

  String _mimeTypeForExtension(String extension) => switch (extension) {
    '.png' => 'image/png',
    _ => 'image/jpeg',
  };

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
