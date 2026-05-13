import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import 'speech_bubble.dart';

class TextStickerData {
  const TextStickerData({
    required this.id,
    required this.center,
    required this.widthFactor,
    required this.heightFactor,
    required this.rotation,
    required this.text,
    required this.textColor,
    required this.backgroundColor,
    required this.font,
    required this.isBold,
    required this.isItalic,
    required this.fontScaleFactor,
    required this.textAlign,
    required this.styleRanges,
  });

  factory TextStickerData.create({
    required String id,
    Offset center = const Offset(0.5, 0.5),
  }) {
    return TextStickerData(
      id: id,
      center: center,
      widthFactor: 0.38,
      heightFactor: 0.18,
      rotation: 0,
      text: '',
      textColor: AppColors.bubbleOutline,
      backgroundColor: Colors.transparent,
      font: BubbleFontOption.sans,
      isBold: false,
      isItalic: false,
      fontScaleFactor: 0.22,
      textAlign: TextAlign.center,
      styleRanges: const [],
    );
  }

  final String id;
  final Offset center;
  final double widthFactor;
  final double heightFactor;
  final double rotation;
  final String text;
  final Color textColor;
  final Color backgroundColor;
  final BubbleFontOption font;
  final bool isBold;
  final bool isItalic;
  final double fontScaleFactor;
  final TextAlign textAlign;
  final List<BubbleTextStyleRange> styleRanges;

  TextStyle textStyleFor(Size size) {
    final fontSize = math.min(size.width, size.height) * fontScaleFactor;
    return font.resolveTextStyle(
      fontSize: fontSize,
      color: textColor,
      bold: isBold,
      italic: isItalic,
    );
  }

  EdgeInsets outerPadding(Size size) {
    final padding = math.max(4.0, math.min(size.width, size.height) * 0.04);
    return EdgeInsets.all(padding);
  }

  EdgeInsets innerPadding(Size size) {
    final horizontal = math.max(10.0, size.width * 0.055);
    final vertical = math.max(7.0, size.height * 0.08);
    return EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
  }

  double cornerRadius(Size size) {
    return math.max(
      12.0,
      math.min(22.0, math.min(size.width, size.height) * 0.16),
    );
  }

  TextSpan buildStyledTextSpan(
    Size size, {
    String? overrideText,
    String? placeholderText,
    Color? placeholderColor,
  }) {
    final displayText = overrideText ?? text;
    final baseStyle = textStyleFor(size);

    if (displayText.isEmpty) {
      return TextSpan(
        text: placeholderText ?? '',
        style: baseStyle.copyWith(
          color: placeholderColor ?? baseStyle.color?.withAlpha(140),
        ),
      );
    }

    if (styleRanges.isEmpty) {
      return TextSpan(text: displayText, style: baseStyle);
    }

    final ranges = styleRanges
        .where(
          (range) =>
              range.start < range.end && range.start < displayText.length,
        )
        .map(
          (range) => BubbleTextStyleRange(
            start: range.start.clamp(0, displayText.length),
            end: range.end.clamp(0, displayText.length),
            font: range.font,
            textColor: range.textColor,
          ),
        )
        .where((range) => range.start < range.end)
        .toList();

    if (ranges.isEmpty) {
      return TextSpan(text: displayText, style: baseStyle);
    }

    final boundaries = <int>{0, displayText.length};
    for (final range in ranges) {
      boundaries
        ..add(range.start)
        ..add(range.end);
    }
    final ordered = boundaries.toList()..sort();

    final children = <InlineSpan>[];
    for (var index = 0; index < ordered.length - 1; index++) {
      final start = ordered[index];
      final end = ordered[index + 1];
      if (start >= end) {
        continue;
      }

      var segmentFont = font;
      var segmentColor = textColor;
      for (final range in ranges) {
        if (start >= range.start && end <= range.end) {
          if (range.font != null) {
            segmentFont = range.font!;
          }
          if (range.textColor != null) {
            segmentColor = range.textColor!;
          }
        }
      }

      children.add(
        TextSpan(
          text: displayText.substring(start, end),
          style: segmentFont.resolveTextStyle(
            fontSize: baseStyle.fontSize ?? 14,
            color: segmentColor,
            bold: isBold,
            italic: isItalic,
            height: baseStyle.height ?? 1.15,
          ),
        ),
      );
    }

    return TextSpan(style: baseStyle, children: children);
  }

  TextStickerData applyFontStyle(
    BubbleFontOption nextFont, {
    TextSelection? selection,
  }) {
    if (_hasSelection(selection, text.length)) {
      final normalized = _normalizedSelection(selection!, text.length);
      return copyWith(
        styleRanges: [
          ...styleRanges,
          BubbleTextStyleRange(
            start: normalized.start,
            end: normalized.end,
            font: nextFont,
          ),
        ],
      );
    }

    return copyWith(
      font: nextFont,
      styleRanges: _clearOverrides(clearFont: true),
    );
  }

  TextStickerData applyTextColorStyle(
    Color nextColor, {
    TextSelection? selection,
  }) {
    if (_hasSelection(selection, text.length)) {
      final normalized = _normalizedSelection(selection!, text.length);
      return copyWith(
        styleRanges: [
          ...styleRanges,
          BubbleTextStyleRange(
            start: normalized.start,
            end: normalized.end,
            textColor: nextColor,
          ),
        ],
      );
    }

    return copyWith(
      textColor: nextColor,
      styleRanges: _clearOverrides(clearTextColor: true),
    );
  }

  TextStickerData applyBoldStyle(bool nextBold) {
    return copyWith(isBold: nextBold);
  }

  TextStickerData applyItalicStyle(bool nextItalic) {
    return copyWith(isItalic: nextItalic);
  }

  List<BubbleTextStyleRange> _clearOverrides({
    bool clearFont = false,
    bool clearTextColor = false,
  }) {
    return styleRanges
        .map(
          (range) => range.copyWith(
            clearFont: clearFont,
            clearTextColor: clearTextColor,
          ),
        )
        .where((range) => range.hasOverrides)
        .toList();
  }

  static bool _hasSelection(TextSelection? selection, int textLength) {
    if (selection == null || !selection.isValid || selection.isCollapsed) {
      return false;
    }
    final start = selection.start.clamp(0, textLength);
    final end = selection.end.clamp(0, textLength);
    return start != end;
  }

  static TextSelection _normalizedSelection(
    TextSelection selection,
    int textLength,
  ) {
    final start = selection.start.clamp(0, textLength);
    final end = selection.end.clamp(0, textLength);
    return TextSelection(
      baseOffset: math.min(start, end),
      extentOffset: math.max(start, end),
    );
  }

  TextStickerData copyWith({
    Offset? center,
    double? widthFactor,
    double? heightFactor,
    double? rotation,
    String? text,
    Color? textColor,
    Color? backgroundColor,
    BubbleFontOption? font,
    bool? isBold,
    bool? isItalic,
    double? fontScaleFactor,
    TextAlign? textAlign,
    List<BubbleTextStyleRange>? styleRanges,
  }) {
    return TextStickerData(
      id: id,
      center: center ?? this.center,
      widthFactor: widthFactor ?? this.widthFactor,
      heightFactor: heightFactor ?? this.heightFactor,
      rotation: rotation ?? this.rotation,
      text: text ?? this.text,
      textColor: textColor ?? this.textColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      font: font ?? this.font,
      isBold: isBold ?? this.isBold,
      isItalic: isItalic ?? this.isItalic,
      fontScaleFactor: fontScaleFactor ?? this.fontScaleFactor,
      textAlign: textAlign ?? this.textAlign,
      styleRanges: styleRanges ?? this.styleRanges,
    );
  }
}
