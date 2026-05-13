import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

enum BubbleShape {
  oval('Arrondie'),
  roundedRect('Rectangle arrondi'),
  cloud('Pensée');

  const BubbleShape(this.label);

  final String label;
}

enum TailStyle { direct, thought }

class BubbleBodyInsets {
  const BubbleBodyInsets({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  final double left;
  final double top;
  final double right;
  final double bottom;

  EdgeInsets resolve(
    Size size, {
    required bool basePointeOnLeft,
    required bool basePointeOnTop,
    required bool pointeOnLeft,
    required bool pointeOnTop,
  }) {
    var resolvedLeft = left;
    var resolvedTop = top;
    var resolvedRight = right;
    var resolvedBottom = bottom;

    if (basePointeOnLeft != pointeOnLeft) {
      (resolvedLeft, resolvedRight) = (resolvedRight, resolvedLeft);
    }
    if (basePointeOnTop != pointeOnTop) {
      (resolvedTop, resolvedBottom) = (resolvedBottom, resolvedTop);
    }

    return EdgeInsets.fromLTRB(
      resolvedLeft * size.width,
      resolvedTop * size.height,
      resolvedRight * size.width,
      resolvedBottom * size.height,
    );
  }
}

enum BubbleFontOption {
  sans('Sans'),
  serif('Serif'),
  mono('Mono'),
  condensed('Condensée');

  const BubbleFontOption(this.label);

  final String label;

  String get familyName => switch (this) {
    BubbleFontOption.sans => 'sans-serif',
    BubbleFontOption.serif => 'serif',
    BubbleFontOption.mono => 'monospace',
    BubbleFontOption.condensed => 'sans-serif-condensed',
  };
}

class BubbleTemplate {
  const BubbleTemplate({
    required this.id,
    required this.label,
    required this.shape,
    required this.tailStyle,
    required this.assetPath,
    required this.basePointeOnLeft,
    required this.basePointeOnTop,
    required this.bodyInsets,
  });

  final String id;
  final String label;
  final BubbleShape shape;
  final TailStyle tailStyle;
  final String assetPath;
  final bool basePointeOnLeft;
  final bool basePointeOnTop;
  final BubbleBodyInsets bodyInsets;

  static const values = <BubbleTemplate>[
    BubbleTemplate(
      id: '378d6cdda0d93f58ef20bf27c4fade20',
      label: '',
      shape: BubbleShape.roundedRect,
      tailStyle: TailStyle.thought,
      assetPath: 'assets/bubbles/378d6cdda0d93f58ef20bf27c4fade20.png',
      basePointeOnLeft: false,
      basePointeOnTop: false,
      bodyInsets: BubbleBodyInsets(
        left: 0.035,
        top: 0.228,
        right: 0.186,
        bottom: 0.111,
      ),
    ),
    BubbleTemplate(
      id: '4b7c3e451eae42079481bca799a571ab',
      label: '',
      shape: BubbleShape.oval,
      tailStyle: TailStyle.direct,
      assetPath: 'assets/bubbles/4b7c3e451eae42079481bca799a571ab.png',
      basePointeOnLeft: false,
      basePointeOnTop: false,
      bodyInsets: BubbleBodyInsets(
        left: 0.073,
        top: 0.204,
        right: 0.143,
        bottom: 0.33,
      ),
    ),
    BubbleTemplate(
      id: '7095dec1a152676f4ce1e27683179a7c',
      label: '',
      shape: BubbleShape.oval,
      tailStyle: TailStyle.direct,
      assetPath: 'assets/bubbles/7095dec1a152676f4ce1e27683179a7c.png',
      basePointeOnLeft: false,
      basePointeOnTop: false,
      bodyInsets: BubbleBodyInsets(
        left: 0.114,
        top: 0.224,
        right: 0.105,
        bottom: 0.354,
      ),
    ),
    BubbleTemplate(
      id: '712096f0bc7811f7251fea46fd2dd4d7',
      label: '',
      shape: BubbleShape.oval,
      tailStyle: TailStyle.direct,
      assetPath: 'assets/bubbles/712096f0bc7811f7251fea46fd2dd4d7.png',
      basePointeOnLeft: true,
      basePointeOnTop: false,
      bodyInsets: BubbleBodyInsets(
        left: 0.069,
        top: 0.178,
        right: 0.068,
        bottom: 0.365,
      ),
    ),
    BubbleTemplate(
      id: '79ed4fb2f3b29936663a4119af775f07',
      label: '',
      shape: BubbleShape.roundedRect,
      tailStyle: TailStyle.direct,
      assetPath: 'assets/bubbles/79ed4fb2f3b29936663a4119af775f07.png',
      basePointeOnLeft: false,
      basePointeOnTop: false,
      bodyInsets: BubbleBodyInsets(
        left: 0.071,
        top: 0.053,
        right: 0.06,
        bottom: 0.125,
      ),
    ),
    BubbleTemplate(
      id: '8f62e5bc0f9df9a6fd6bd3397da132ed',
      label: '',
      shape: BubbleShape.roundedRect,
      tailStyle: TailStyle.direct,
      assetPath: 'assets/bubbles/8f62e5bc0f9df9a6fd6bd3397da132ed.png',
      basePointeOnLeft: true,
      basePointeOnTop: false,
      bodyInsets: BubbleBodyInsets(
        left: 0.031,
        top: 0.021,
        right: 0.048,
        bottom: 0.268,
      ),
    ),
    BubbleTemplate(
      id: '90c8e598aa220e65a7fdb4cf5fc85db5',
      label: '',
      shape: BubbleShape.cloud,
      tailStyle: TailStyle.thought,
      assetPath: 'assets/bubbles/90c8e598aa220e65a7fdb4cf5fc85db5.png',
      basePointeOnLeft: false,
      basePointeOnTop: false,
      bodyInsets: BubbleBodyInsets(
        left: 0.073,
        top: 0.098,
        right: 0.074,
        bottom: 0.316,
      ),
    ),
    BubbleTemplate(
      id: 'b633ca6d48f5a8b9e9cc0cc658aa6ba1',
      label: '',
      shape: BubbleShape.cloud,
      tailStyle: TailStyle.direct,
      assetPath: 'assets/bubbles/b633ca6d48f5a8b9e9cc0cc658aa6ba1.png',
      basePointeOnLeft: false,
      basePointeOnTop: false,
      bodyInsets: BubbleBodyInsets(
        left: 0.166,
        top: 0.11,
        right: 0.144,
        bottom: 0.318,
      ),
    ),
    BubbleTemplate(
      id: 'e76f65029d5db84ff5fb6849b924d80b',
      label: '',
      shape: BubbleShape.roundedRect,
      tailStyle: TailStyle.direct,
      assetPath: 'assets/bubbles/e76f65029d5db84ff5fb6849b924d80b.png',
      basePointeOnLeft: false,
      basePointeOnTop: false,
      bodyInsets: BubbleBodyInsets(
        left: 0.073,
        top: 0.062,
        right: 0.058,
        bottom: 0.249,
      ),
    ),
  ];

  static BubbleTemplate? fromAssetPath(String assetPath) {
    for (final template in values) {
      if (template.assetPath == assetPath) {
        return template;
      }
    }
    return null;
  }

  SpeechBubbleData createBubble({
    required String bubbleId,
    Offset center = const Offset(0.5, 0.5),
  }) {
    return SpeechBubbleData(
      id: bubbleId,
      center: center,
      widthFactor: 0.34,
      heightFactor: 0.24,
      rotation: 0,
      shape: shape,
      tailStyle: tailStyle,
      assetPath: assetPath,
      tailOnTop: basePointeOnTop,
      tailOnLeft: basePointeOnLeft,
      text: '',
      fillColor: Colors.white,
      textColor: AppColors.bubbleOutline,
      font: BubbleFontOption.sans,
      fontScaleFactor: 0.22,
      textAlign: TextAlign.center,
      styleRanges: const [],
    );
  }
}

class BubbleTextStyleRange {
  const BubbleTextStyleRange({
    required this.start,
    required this.end,
    this.font,
    this.textColor,
  });

  final int start;
  final int end;
  final BubbleFontOption? font;
  final Color? textColor;

  bool get hasOverrides => font != null || textColor != null;

  BubbleTextStyleRange copyWith({
    int? start,
    int? end,
    BubbleFontOption? font,
    bool clearFont = false,
    Color? textColor,
    bool clearTextColor = false,
  }) {
    return BubbleTextStyleRange(
      start: start ?? this.start,
      end: end ?? this.end,
      font: clearFont ? null : font ?? this.font,
      textColor: clearTextColor ? null : textColor ?? this.textColor,
    );
  }
}

class SpeechBubbleData {
  const SpeechBubbleData({
    required this.id,
    required this.center,
    required this.widthFactor,
    required this.heightFactor,
    required this.rotation,
    required this.shape,
    required this.tailStyle,
    required this.assetPath,
    required this.tailOnTop,
    required this.tailOnLeft,
    required this.text,
    required this.fillColor,
    required this.textColor,
    required this.font,
    required this.fontScaleFactor,
    required this.textAlign,
    required this.styleRanges,
  });

  final String id;
  final Offset center;
  final double widthFactor;
  final double heightFactor;
  final double rotation;
  final BubbleShape shape;
  final TailStyle tailStyle;
  final String assetPath;
  final bool tailOnTop;
  final bool tailOnLeft;
  final String text;
  final Color fillColor;
  final Color textColor;
  final BubbleFontOption font;
  final double fontScaleFactor;
  final TextAlign textAlign;
  final List<BubbleTextStyleRange> styleRanges;

  TextStyle textStyleFor(Size size) {
    final fontSize = math.min(size.width, size.height) * fontScaleFactor;
    return TextStyle(
      fontFamily: font.familyName,
      fontSize: fontSize,
      color: textColor,
      height: 1.15,
      fontWeight: FontWeight.w500,
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

      var segmentStyle = baseStyle;
      for (final range in ranges) {
        if (start >= range.start && end <= range.end) {
          if (range.font != null) {
            segmentStyle = segmentStyle.copyWith(
              fontFamily: range.font!.familyName,
            );
          }
          if (range.textColor != null) {
            segmentStyle = segmentStyle.copyWith(color: range.textColor);
          }
        }
      }

      children.add(
        TextSpan(text: displayText.substring(start, end), style: segmentStyle),
      );
    }

    return TextSpan(style: baseStyle, children: children);
  }

  SpeechBubbleData applyFontStyle(
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

  SpeechBubbleData applyTextColorStyle(
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

  SpeechBubbleData copyWith({
    Offset? center,
    double? widthFactor,
    double? heightFactor,
    double? rotation,
    BubbleShape? shape,
    TailStyle? tailStyle,
    String? assetPath,
    bool? tailOnTop,
    bool? tailOnLeft,
    String? text,
    Color? fillColor,
    Color? textColor,
    BubbleFontOption? font,
    double? fontScaleFactor,
    TextAlign? textAlign,
    List<BubbleTextStyleRange>? styleRanges,
  }) {
    return SpeechBubbleData(
      id: id,
      center: center ?? this.center,
      widthFactor: widthFactor ?? this.widthFactor,
      heightFactor: heightFactor ?? this.heightFactor,
      rotation: rotation ?? this.rotation,
      shape: shape ?? this.shape,
      tailStyle: tailStyle ?? this.tailStyle,
      assetPath: assetPath ?? this.assetPath,
      tailOnTop: tailOnTop ?? this.tailOnTop,
      tailOnLeft: tailOnLeft ?? this.tailOnLeft,
      text: text ?? this.text,
      fillColor: fillColor ?? this.fillColor,
      textColor: textColor ?? this.textColor,
      font: font ?? this.font,
      fontScaleFactor: fontScaleFactor ?? this.fontScaleFactor,
      textAlign: textAlign ?? this.textAlign,
      styleRanges: styleRanges ?? this.styleRanges,
    );
  }
}
