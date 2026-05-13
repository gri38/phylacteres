import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

import '../models/speech_bubble.dart';

class BubbleLayoutRegistry {
  BubbleLayoutRegistry._();

  static final BubbleLayoutRegistry instance = BubbleLayoutRegistry._();

  Future<void>? _loading;
  final Map<String, BubbleBodyInsets> _layouts =
      <String, BubbleBodyInsets>{};

  Future<void> ensureLoaded() {
    return _loading ??= _load();
  }

  BubbleBodyInsets? layoutForAsset(String assetPath) {
    final fileName = assetPath.split('/').last;
    return _layouts[fileName];
  }

  Future<void> _load() async {
    try {
      final rawJson = await rootBundle.loadString('assets/bubbles/layouts.json');
      final decoded = jsonDecode(rawJson);
      if (decoded is! Map<String, dynamic>) {
        return;
      }

      for (final entry in decoded.entries) {
        final value = entry.value;
        if (value is! Map<String, dynamic>) {
          continue;
        }

        final x1 = (value['x1'] as num?)?.toDouble();
        final y1 = (value['y1'] as num?)?.toDouble();
        final x2 = (value['x2'] as num?)?.toDouble();
        final y2 = (value['y2'] as num?)?.toDouble();
        if (x1 != null && y1 != null && x2 != null && y2 != null) {
          final assetSize = await _readAssetSize(entry.key);
          if (assetSize != null && assetSize.width > 0 && assetSize.height > 0) {
            _layouts[entry.key] = BubbleBodyInsets(
              left: x1 / assetSize.width,
              top: y1 / assetSize.height,
              right: (assetSize.width - x2) / assetSize.width,
              bottom: (assetSize.height - y2) / assetSize.height,
            );
          }
          continue;
        }

        final left = (value['left'] as num?)?.toDouble();
        final top = (value['top'] as num?)?.toDouble();
        final right = (value['right'] as num?)?.toDouble();
        final bottom = (value['bottom'] as num?)?.toDouble();
        if (left != null && top != null && right != null && bottom != null) {
          _layouts[entry.key] = BubbleBodyInsets(
            left: left,
            top: top,
            right: right,
            bottom: bottom,
          );
        }
      }
    } catch (_) {
      // Falls back to the hardcoded defaults in BubbleTemplate.
    }
  }

  Future<_AssetSize?> _readAssetSize(String fileName) async {
    final bytes = await rootBundle.load('assets/bubbles/$fileName');
    final decoded = img.decodeImage(bytes.buffer.asUint8List());
    if (decoded == null) {
      return null;
    }
    return _AssetSize(
      width: decoded.width.toDouble(),
      height: decoded.height.toDouble(),
    );
  }
}

class _AssetSize {
  const _AssetSize({required this.width, required this.height});

  final double width;
  final double height;
}
