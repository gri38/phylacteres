import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/speech_bubble.dart';
import '../models/text_sticker.dart';
import 'bubble_text_editing_controller.dart';

class TextStickerOverlay extends StatelessWidget {
  const TextStickerOverlay({
    super.key,
    required this.textItem,
    required this.displaySize,
    required this.selected,
    required this.isEditingText,
    required this.textController,
    required this.textFocusNode,
    required this.onTap,
    required this.onScaleStart,
    required this.onScaleUpdate,
    required this.onScaleEnd,
  });

  final TextStickerData textItem;
  final Size displaySize;
  final bool selected;
  final bool isEditingText;
  final BubbleTextEditingController? textController;
  final FocusNode? textFocusNode;
  final VoidCallback onTap;
  final GestureScaleStartCallback onScaleStart;
  final GestureScaleUpdateCallback onScaleUpdate;
  final GestureScaleEndCallback onScaleEnd;

  @override
  Widget build(BuildContext context) {
    final width = textItem.widthFactor * displaySize.width;
    final height = textItem.heightFactor * displaySize.height;
    final left = textItem.center.dx * displaySize.width - width / 2;
    final top = textItem.center.dy * displaySize.height - height / 2;
    final itemSize = Size(width, height);
    final outerPadding = textItem.outerPadding(itemSize);
    final innerPadding = textItem.innerPadding(itemSize);
    final radius = textItem.cornerRadius(itemSize);
    final textStyle = textItem.textStyleFor(itemSize);

    if (isEditingText && textController != null) {
      textController!.styledSpanBuilder = (text) =>
          textItem.buildStyledTextSpan(itemSize, overrideText: text);
    }

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: Transform.rotate(
        angle: textItem.rotation,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: isEditingText ? null : onTap,
          onScaleStart: isEditingText ? null : onScaleStart,
          onScaleUpdate: isEditingText ? null : onScaleUpdate,
          onScaleEnd: isEditingText ? null : onScaleEnd,
          child: Padding(
            padding: outerPadding,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final currentText = textController?.text ?? textItem.text;
                final measureText = currentText.isEmpty && selected
                    ? 'Touchez encore pour ecrire'
                    : currentText;
                final textMeasurement =
                    TextPainter(
                      text: textItem.buildStyledTextSpan(
                        itemSize,
                        overrideText: measureText,
                        placeholderText: measureText,
                        placeholderColor:
                            textItem.font == BubbleFontOption.outlined
                            ? Colors.black.withAlpha(160)
                            : textItem.textColor.withAlpha(153),
                      ),
                      textAlign: textItem.textAlign,
                      textDirection: TextDirection.ltr,
                    )..layout(
                      maxWidth: math.max(
                        0,
                        constraints.maxWidth - innerPadding.horizontal,
                      ),
                    );
                final singleLineHeight =
                    (textStyle.fontSize ?? 0) * (textStyle.height ?? 1.15);
                final extraVerticalSafety = (textStyle.fontSize ?? 0) * 0.26;
                final contentHeight =
                    math.max(textMeasurement.height, singleLineHeight) +
                    extraVerticalSafety;
                final boxHeight = contentHeight + innerPadding.vertical;

                return OverflowBox(
                  alignment: Alignment.center,
                  minWidth: 0,
                  maxWidth: constraints.maxWidth,
                  minHeight: 0,
                  maxHeight: double.infinity,
                  child: SizedBox(
                    width: constraints.maxWidth,
                    height: boxHeight,
                    child: CustomPaint(
                      painter: selected
                          ? _DashedSelectionPainter(
                              color: Theme.of(context).colorScheme.primary,
                              radius: radius,
                            )
                          : null,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: textItem.backgroundColor,
                          borderRadius: BorderRadius.circular(radius),
                        ),
                        child: Padding(
                          padding: innerPadding,
                          child: isEditingText
                              ? TextField(
                                  key: ValueKey(
                                    '${textItem.id}_${textItem.font.name}_${textItem.textColor.toARGB32()}_${textItem.backgroundColor.toARGB32()}_${textItem.fontScaleFactor}_${textItem.textAlign.name}_${textItem.isBold}_${textItem.isItalic}_${textItem.styleRanges.length}',
                                  ),
                                  controller: textController,
                                  focusNode: textFocusNode,
                                  expands: true,
                                  maxLines: null,
                                  minLines: null,
                                  keyboardType: TextInputType.multiline,
                                  cursorColor:
                                      textItem.font == BubbleFontOption.outlined
                                      ? Colors.black
                                      : textItem.textColor,
                                  textAlign: textItem.textAlign,
                                  textAlignVertical: TextAlignVertical.center,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  style: textStyle,
                                  strutStyle: StrutStyle.fromTextStyle(
                                    textStyle,
                                    forceStrutHeight: true,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Ecrire...',
                                    hintStyle: textStyle.copyWith(
                                      color:
                                          textItem.font ==
                                              BubbleFontOption.outlined
                                          ? Colors.black.withAlpha(140)
                                          : textItem.textColor.withAlpha(125),
                                    ),
                                    border: InputBorder.none,
                                    isCollapsed: true,
                                  ),
                                )
                              : Align(
                                  alignment: Alignment.center,
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: RichText(
                                      textAlign: textItem.textAlign,
                                      textWidthBasis: TextWidthBasis.parent,
                                      text: textItem.buildStyledTextSpan(
                                        itemSize,
                                        placeholderText: selected
                                            ? 'Touchez encore pour ecrire'
                                            : '',
                                        placeholderColor:
                                            textItem.font ==
                                                BubbleFontOption.outlined
                                            ? Colors.black.withAlpha(160)
                                            : textItem.textColor.withAlpha(153),
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedSelectionPainter extends CustomPainter {
  const _DashedSelectionPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(1.5),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    final dashPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = color;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        const dash = 8.0;
        const gap = 5.0;
        final segment = metric.extractPath(
          distance,
          math.min(distance + dash, metric.length),
        );
        canvas.drawPath(segment, dashPaint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedSelectionPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}
