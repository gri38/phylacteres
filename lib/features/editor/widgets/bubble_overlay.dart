import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models/speech_bubble.dart';
import '../services/bubble_renderer.dart';
import 'bubble_text_editing_controller.dart';

class BubbleOverlay extends StatelessWidget {
  const BubbleOverlay({
    super.key,
    required this.bubble,
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

  final SpeechBubbleData bubble;
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
    final template = BubbleTemplate.fromAssetPath(bubble.assetPath);
    final stretchSpec = template?.stretchSpec;
    final width = bubble.widthFactor * displaySize.width;
    final height = bubble.heightFactor * displaySize.height;
    final left = bubble.center.dx * displaySize.width - width / 2;
    final top = bubble.center.dy * displaySize.height - height / 2;
    final bubbleSize = Size(width, height);
    final bubbleTextStyle = bubble.textStyleFor(bubbleSize);

    if (isEditingText && textController != null) {
      textController!.styledSpanBuilder = (text) =>
          bubble.buildStyledTextSpan(bubbleSize, overrideText: text);
    }

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: Transform.rotate(
        angle: bubble.rotation,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: isEditingText ? null : onTap,
          onScaleStart: isEditingText ? null : onScaleStart,
          onScaleUpdate: isEditingText ? null : onScaleUpdate,
          onScaleEnd: isEditingText ? null : onScaleEnd,
          child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              blurRadius: 18,
                              spreadRadius: 2,
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withAlpha(90),
                            ),
                          ]
                        : null,
                  ),
                  child: stretchSpec == null
                      ? Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.diagonal3Values(
                            BubbleRenderer.shouldFlipHorizontally(bubble)
                                ? -1
                                : 1,
                            BubbleRenderer.shouldFlipVertically(bubble)
                                ? -1
                                : 1,
                            1,
                          ),
                          child: Image.asset(
                            bubble.assetPath,
                            fit: BoxFit.fill,
                          ),
                        )
                      : _StretchBubbleAsset(bubble: bubble),
                ),
              ),
              Padding(
                padding: BubbleRenderer.contentPadding(bubble, bubbleSize),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final currentText = textController?.text ?? bubble.text;
                    final textMeasurement = TextPainter(
                      text: bubble.buildStyledTextSpan(
                        bubbleSize,
                        overrideText: currentText,
                        placeholderText: selected
                            ? 'Touchez encore pour écrire'
                            : '',
                        placeholderColor: bubble.textColor.withAlpha(153),
                      ),
                      textAlign: bubble.textAlign,
                      textDirection: TextDirection.ltr,
                    )..layout(maxWidth: constraints.maxWidth);
                    final singleLineHeight =
                        (bubbleTextStyle.fontSize ?? 0) *
                        (bubbleTextStyle.height ?? 1.15);
                    final extraVerticalSafety =
                        (bubbleTextStyle.fontSize ?? 0) * 0.26;
                    final centeredTextHeight =
                        math.max(textMeasurement.height, singleLineHeight) +
                        extraVerticalSafety;

                    if (isEditingText) {
                      return OverflowBox(
                        alignment: Alignment.center,
                        minWidth: 0,
                        maxWidth: constraints.maxWidth,
                        minHeight: 0,
                        maxHeight: double.infinity,
                        child: SizedBox(
                          width: constraints.maxWidth,
                          height: centeredTextHeight,
                          child: TextField(
                            key: ValueKey(
                              '${bubble.id}_${bubble.font.name}_${bubble.textColor.toARGB32()}_${bubble.fontScaleFactor}_${bubble.textAlign.name}_${bubble.isBold}_${bubble.isItalic}_${bubble.styleRanges.length}',
                            ),
                            controller: textController,
                            focusNode: textFocusNode,
                            expands: true,
                            maxLines: null,
                            minLines: null,
                            keyboardType: TextInputType.multiline,
                            cursorColor:
                                bubble.font == BubbleFontOption.outlined
                                ? Colors.black
                                : bubble.textColor,
                            textAlign: bubble.textAlign,
                            textAlignVertical: TextAlignVertical.center,
                            textCapitalization: TextCapitalization.sentences,
                            style: bubbleTextStyle,
                            strutStyle: StrutStyle.fromTextStyle(
                              bubbleTextStyle,
                              forceStrutHeight: true,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Écrire…',
                              hintStyle: bubbleTextStyle.copyWith(
                                color: bubble.font == BubbleFontOption.outlined
                                    ? Colors.black.withAlpha(140)
                                    : bubble.textColor.withAlpha(125),
                              ),
                              border: InputBorder.none,
                              isCollapsed: true,
                            ),
                          ),
                        ),
                      );
                    }

                    return OverflowBox(
                      alignment: Alignment.center,
                      minWidth: 0,
                      maxWidth: constraints.maxWidth,
                      minHeight: 0,
                      maxHeight: double.infinity,
                      child: SizedBox(
                        width: constraints.maxWidth,
                        height: centeredTextHeight,
                        child: Align(
                          alignment: Alignment.center,
                          child: RichText(
                            textAlign: bubble.textAlign,
                            text: bubble.buildStyledTextSpan(
                              bubbleSize,
                              placeholderText: selected
                                  ? 'Touchez encore pour écrire'
                                  : '',
                              placeholderColor: bubble.textColor.withAlpha(153),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StretchBubbleAsset extends StatelessWidget {
  const _StretchBubbleAsset({required this.bubble});

  final SpeechBubbleData bubble;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ui.Image>(
      future: BubbleRenderer.loadAssetImage(bubble.assetPath),
      builder: (context, snapshot) {
        final image = snapshot.data;
        if (image == null) {
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.diagonal3Values(
              BubbleRenderer.shouldFlipHorizontally(bubble) ? -1 : 1,
              BubbleRenderer.shouldFlipVertically(bubble) ? -1 : 1,
              1,
            ),
            child: Image.asset(bubble.assetPath, fit: BoxFit.fill),
          );
        }

        return CustomPaint(
          painter: _StretchBubblePainter(bubble: bubble, image: image),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _StretchBubblePainter extends CustomPainter {
  const _StretchBubblePainter({required this.bubble, required this.image});

  final SpeechBubbleData bubble;
  final ui.Image image;

  @override
  void paint(Canvas canvas, Size size) {
    BubbleRenderer.paintLoadedBubbleAsset(canvas, size, bubble, image);
  }

  @override
  bool shouldRepaint(covariant _StretchBubblePainter oldDelegate) {
    return oldDelegate.image != image || oldDelegate.bubble != bubble;
  }
}
