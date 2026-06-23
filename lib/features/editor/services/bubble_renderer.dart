import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

import '../models/speech_bubble.dart';
import '../models/text_sticker.dart';
import 'bubble_layout_registry.dart';
import 'image_codec_service.dart';

class BubbleRenderer {
  const BubbleRenderer._();

  static final ImageCodecService _codecService = const ImageCodecService();
  static final Map<String, ui.Image> _assetCache = <String, ui.Image>{};

  static Future<ui.Image> loadAssetImage(String assetPath) {
    return _loadAssetImage(assetPath);
  }

  static Future<Uint8List> renderCompositedImage({
    required Uint8List baseImageBytes,
    required Size baseSize,
    required List<SpeechBubbleData> bubbles,
    required List<TextStickerData> textItems,
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

    for (final textItem in textItems) {
      final itemSize = Size(
        textItem.widthFactor * baseSize.width,
        textItem.heightFactor * baseSize.height,
      );
      final center = Offset(
        textItem.center.dx * baseSize.width,
        textItem.center.dy * baseSize.height,
      );

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(textItem.rotation);
      canvas.translate(-itemSize.width / 2, -itemSize.height / 2);
      paintTextSticker(canvas, textItem, itemSize);
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

    final rect = bubbleTextRect(bubble, size);

    final textPainter = TextPainter(
      text: bubble.buildStyledTextSpan(size),
      textAlign: bubble.textAlign,
      textDirection: TextDirection.ltr,
      maxLines: 12,
    )..layout(maxWidth: math.max(1.0, rect.width));

    textPainter.paint(
      canvas,
      resolveAlignedTextOffset(
        rect: rect,
        textPainter: textPainter,
        textAlign: bubble.textAlign,
      ),
    );
  }

  static void paintTextSticker(
    Canvas canvas,
    TextStickerData textItem,
    Size size,
  ) {
    final outerPadding = textItem.outerPadding(size);
    final innerPadding = textItem.innerPadding(size);
    final textStyle = textItem.textStyleFor(size);
    final availableWidth = size.width - outerPadding.horizontal;
    final availableHeight = size.height - outerPadding.vertical;
    final textWidth = math.max(0.0, availableWidth - innerPadding.horizontal);
    final textPainter = TextPainter(
      text: textItem.buildStyledTextSpan(size),
      textAlign: textItem.textAlign,
      textDirection: TextDirection.ltr,
      maxLines: 12,
    )..layout(maxWidth: math.max(1.0, textWidth));
    final singleLineHeight =
        (textStyle.fontSize ?? 0) * (textStyle.height ?? 1.15);
    final extraVerticalSafety = (textStyle.fontSize ?? 0) * 0.26;
    final contentHeight =
        math.max(textPainter.height, singleLineHeight) + extraVerticalSafety;
    final backgroundHeight = contentHeight + innerPadding.vertical;
    final backgroundTop =
        outerPadding.top + (availableHeight - backgroundHeight) / 2;
    final backgroundRect = Rect.fromLTWH(
      outerPadding.left,
      backgroundTop,
      availableWidth,
      backgroundHeight,
    );

    if (textItem.backgroundColor.a != 0) {
      final rrect = RRect.fromRectAndRadius(
        backgroundRect,
        Radius.circular(textItem.cornerRadius(size)),
      );
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = textItem.backgroundColor
          ..isAntiAlias = true,
      );
    }

    if (textItem.text.trim().isEmpty) {
      return;
    }

    final textRect = Rect.fromLTWH(
      backgroundRect.left + innerPadding.left,
      backgroundRect.top + innerPadding.top,
      backgroundRect.width - innerPadding.horizontal,
      backgroundRect.height - innerPadding.vertical,
    );
    textPainter.paint(
      canvas,
      resolveAlignedTextOffset(
        rect: textRect,
        textPainter: textPainter,
        textAlign: textItem.textAlign,
      ),
    );
  }

  static Rect bubbleTextRect(SpeechBubbleData bubble, Size size) {
    final padding = contentPadding(bubble, size);
    return Rect.fromLTWH(
      padding.left,
      padding.top,
      math.max(0.0, size.width - padding.horizontal),
      math.max(0.0, size.height - padding.vertical),
    );
  }

  static Offset resolveAlignedTextOffset({
    required Rect rect,
    required TextPainter textPainter,
    required TextAlign textAlign,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    final remainingWidth = math.max(0.0, rect.width - textPainter.width);
    final resolvedAlign = switch (textAlign) {
      TextAlign.start => textDirection == TextDirection.rtl
          ? TextAlign.right
          : TextAlign.left,
      TextAlign.end => textDirection == TextDirection.rtl
          ? TextAlign.left
          : TextAlign.right,
      _ => textAlign,
    };
    final dx = switch (resolvedAlign) {
      TextAlign.center => rect.left + (remainingWidth / 2),
      TextAlign.right => rect.left + remainingWidth,
      _ => rect.left,
    };
    final dy = rect.top + math.max(0.0, (rect.height - textPainter.height) / 2);
    return Offset(dx, dy);
  }

  static EdgeInsets contentPadding(SpeechBubbleData bubble, Size size) {
    final template = BubbleTemplate.fromAssetPath(bubble.assetPath);
    final stretchSpec = template?.stretchSpec;
    if (template != null && stretchSpec != null) {
      return stretchSpec.resolveContentPadding(
        size,
        basePointeOnLeft: template.basePointeOnLeft,
        basePointeOnTop: template.basePointeOnTop,
        pointeOnLeft: bubble.tailOnLeft,
        pointeOnTop: bubble.tailOnTop,
      );
    }

    final jsonInsets = BubbleLayoutRegistry.instance.layoutForAsset(
      bubble.assetPath,
    );
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
    paintLoadedBubbleAsset(canvas, size, bubble, image);
  }

  static void paintLoadedBubbleAsset(
    Canvas canvas,
    Size size,
    SpeechBubbleData bubble,
    ui.Image image,
  ) {
    final stretchSpec = BubbleTemplate.fromAssetPath(
      bubble.assetPath,
    )?.stretchSpec;
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
    if (stretchSpec != null) {
      _paintScaledStretchBubble(canvas, image, size, stretchSpec, paint);
    } else {
      canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        Rect.fromLTWH(0, 0, size.width, size.height),
        paint,
      );
    }
    canvas.restore();
  }

  static void _paintScaledStretchBubble(
    Canvas canvas,
    ui.Image image,
    Size size,
    BubbleStretchSpec stretchSpec,
    Paint paint,
  ) {
    final imageWidth = image.width.toDouble();
    final imageHeight = image.height.toDouble();
    final sourceLeft = stretchSpec.centerSlice.left;
    final sourceTop = stretchSpec.centerSlice.top;
    final sourceRight = imageWidth - stretchSpec.centerSlice.right;
    final sourceBottom = imageHeight - stretchSpec.centerSlice.bottom;
    final scale = stretchSpec.uniformScaleFor(size);

    final leftWidth = sourceLeft * scale;
    final topHeight = sourceTop * scale;
    final rightWidth = sourceRight * scale;
    final bottomHeight = sourceBottom * scale;
    final centerWidth = math.max(0.0, size.width - leftWidth - rightWidth);
    final centerHeight = math.max(0.0, size.height - topHeight - bottomHeight);

    void drawPatch(Rect src, Rect dst) {
      if (src.width <= 0 ||
          src.height <= 0 ||
          dst.width <= 0 ||
          dst.height <= 0) {
        return;
      }
      canvas.drawImageRect(image, src, dst, paint);
    }

    final leftX = 0.0;
    final centerX = leftWidth;
    final rightX = size.width - rightWidth;
    final topY = 0.0;
    final middleY = topHeight;
    final bottomY = size.height - bottomHeight;

    drawPatch(
      Rect.fromLTWH(0, 0, sourceLeft, sourceTop),
      Rect.fromLTWH(leftX, topY, leftWidth, topHeight),
    );
    drawPatch(
      Rect.fromLTWH(sourceLeft, 0, stretchSpec.centerSlice.width, sourceTop),
      Rect.fromLTWH(centerX, topY, centerWidth, topHeight),
    );
    drawPatch(
      Rect.fromLTWH(stretchSpec.centerSlice.right, 0, sourceRight, sourceTop),
      Rect.fromLTWH(rightX, topY, rightWidth, topHeight),
    );
    drawPatch(
      Rect.fromLTWH(0, sourceTop, sourceLeft, stretchSpec.centerSlice.height),
      Rect.fromLTWH(leftX, middleY, leftWidth, centerHeight),
    );
    drawPatch(
      stretchSpec.centerSlice,
      Rect.fromLTWH(centerX, middleY, centerWidth, centerHeight),
    );
    drawPatch(
      Rect.fromLTWH(
        stretchSpec.centerSlice.right,
        sourceTop,
        sourceRight,
        stretchSpec.centerSlice.height,
      ),
      Rect.fromLTWH(rightX, middleY, rightWidth, centerHeight),
    );
    drawPatch(
      Rect.fromLTWH(
        0,
        stretchSpec.centerSlice.bottom,
        sourceLeft,
        sourceBottom,
      ),
      Rect.fromLTWH(leftX, bottomY, leftWidth, bottomHeight),
    );
    drawPatch(
      Rect.fromLTWH(
        sourceLeft,
        stretchSpec.centerSlice.bottom,
        stretchSpec.centerSlice.width,
        sourceBottom,
      ),
      Rect.fromLTWH(centerX, bottomY, centerWidth, bottomHeight),
    );
    drawPatch(
      Rect.fromLTWH(
        stretchSpec.centerSlice.right,
        stretchSpec.centerSlice.bottom,
        sourceRight,
        sourceBottom,
      ),
      Rect.fromLTWH(rightX, bottomY, rightWidth, bottomHeight),
    );
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
