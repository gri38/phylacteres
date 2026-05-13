import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

import '../models/speech_bubble.dart';
import 'bubble_layout_registry.dart';
import 'image_codec_service.dart';

class BubbleRenderer {
  const BubbleRenderer._();

  static final ImageCodecService _codecService = const ImageCodecService();
  static final Map<String, ui.Image> _assetCache = <String, ui.Image>{};

  static Future<Uint8List> renderCompositedImage({
    required Uint8List baseImageBytes,
    required Size baseSize,
    required List<SpeechBubbleData> bubbles,
    required String extension,
  }) async {
    await BubbleLayoutRegistry.instance.ensureLoaded();
    final image = await _codecService.decodeUiImage(baseImageBytes);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, baseSize.width, baseSize.height),
    );

    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(0, 0, baseSize.width, baseSize.height),
      Paint(),
    );

    for (final bubble in bubbles) {
      final bubbleSize = Size(
        bubble.widthFactor * baseSize.width,
        bubble.heightFactor * baseSize.height,
      );
      final center = Offset(
        bubble.center.dx * baseSize.width,
        bubble.center.dy * baseSize.height,
      );

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(bubble.rotation);
      canvas.translate(-bubbleSize.width / 2, -bubbleSize.height / 2);
      await paintBubbleAsset(canvas, bubbleSize, bubble);
      paintText(canvas, bubble, bubbleSize);
      canvas.restore();
    }

    final picture = recorder.endRecording();
    final rendered = await picture.toImage(
      baseSize.width.round(),
      baseSize.height.round(),
    );
    final pngBytes = (await rendered.toByteData(
      format: ui.ImageByteFormat.png,
    ))!.buffer.asUint8List();

    if (extension == '.png') {
      return pngBytes;
    }

    final decoded = img.decodeImage(pngBytes);
    if (decoded == null) {
      return pngBytes;
    }
    return Uint8List.fromList(img.encodeJpg(decoded, quality: 96));
  }

  static void paintText(Canvas canvas, SpeechBubbleData bubble, Size size) {
    if (bubble.text.trim().isEmpty) {
      return;
    }

    final padding = contentPadding(bubble, size);
    final rect = Rect.fromLTWH(
      padding.left,
      padding.top,
      size.width - padding.horizontal,
      size.height - padding.vertical,
    );

    final textPainter = TextPainter(
      text: bubble.buildStyledTextSpan(size),
      textAlign: bubble.textAlign,
      textDirection: TextDirection.ltr,
      maxLines: 12,
    )..layout(maxWidth: rect.width);

    final dy = rect.top + math.max(0, (rect.height - textPainter.height) / 2);
    textPainter.paint(canvas, Offset(rect.left, dy));
  }

  static EdgeInsets contentPadding(SpeechBubbleData bubble, Size size) {
    final jsonInsets = BubbleLayoutRegistry.instance.layoutForAsset(
      bubble.assetPath,
    );
    final template = BubbleTemplate.fromAssetPath(bubble.assetPath);
    final sourceInsets = jsonInsets ?? template?.bodyInsets;

    if (sourceInsets != null && template != null) {
      final rawInsets = sourceInsets.resolve(
        size,
        basePointeOnLeft: template.basePointeOnLeft,
        basePointeOnTop: template.basePointeOnTop,
        pointeOnLeft: bubble.tailOnLeft,
        pointeOnTop: bubble.tailOnTop,
      );
      final innerHorizontal = size.width * 0.03;
      final innerTop = size.height * 0.03;
      final innerBottom = size.height * 0.05;
      return EdgeInsets.fromLTRB(
        rawInsets.left + innerHorizontal,
        rawInsets.top + innerTop,
        rawInsets.right + innerHorizontal,
        rawInsets.bottom + innerBottom,
      );
    }

    final pointeSpace = bubble.tailStyle == TailStyle.thought
        ? size.height * 0.2
        : size.height * 0.24;
    final horizontal = size.width * 0.12;
    final vertical = size.height * 0.12;

    return EdgeInsets.fromLTRB(
      horizontal,
      vertical + (bubble.tailOnTop ? pointeSpace : 0),
      horizontal,
      vertical + (bubble.tailOnTop ? 0 : pointeSpace),
    );
  }

  static bool shouldFlipHorizontally(SpeechBubbleData bubble) {
    final template = BubbleTemplate.fromAssetPath(bubble.assetPath);
    if (template == null) {
      return !bubble.tailOnLeft;
    }
    return bubble.tailOnLeft != template.basePointeOnLeft;
  }

  static bool shouldFlipVertically(SpeechBubbleData bubble) {
    final template = BubbleTemplate.fromAssetPath(bubble.assetPath);
    if (template == null) {
      return !bubble.tailOnTop;
    }
    return bubble.tailOnTop != template.basePointeOnTop;
  }

  static Future<void> paintBubbleAsset(
    Canvas canvas,
    Size size,
    SpeechBubbleData bubble,
  ) async {
    final image = await _loadAssetImage(bubble.assetPath);
    final paint = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(
      shouldFlipHorizontally(bubble) ? -1 : 1,
      shouldFlipVertically(bubble) ? -1 : 1,
    );
    canvas.translate(-size.width / 2, -size.height / 2);
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
    canvas.restore();
  }

  static Future<ui.Image> _loadAssetImage(String assetPath) async {
    final cached = _assetCache[assetPath];
    if (cached != null) {
      return cached;
    }

    final data = await rootBundle.load(assetPath);
    final image = await _codecService.decodeUiImage(data.buffer.asUint8List());
    _assetCache[assetPath] = image;
    return image;
  }
}
