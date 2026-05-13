import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../models/speech_bubble.dart';
import 'bubble_overlay.dart';
import 'bubble_text_editing_controller.dart';
import 'selected_bubble_toolbar.dart';

typedef BubbleTapCallback = void Function(String bubbleId);
typedef BubbleScaleStartCallback =
    void Function(
      SpeechBubbleData bubble,
      ScaleStartDetails details,
      Size displaySize,
    );
typedef BubbleScaleUpdateCallback =
    void Function(
      SpeechBubbleData bubble,
      ScaleUpdateDetails details,
      Size displaySize,
    );

class EditorCanvas extends StatelessWidget {
  const EditorCanvas({
    super.key,
    required this.imageBytes,
    required this.imageSize,
    required this.bubbles,
    required this.selectedBubbleId,
    required this.selectedBubble,
    required this.isEditingText,
    required this.textController,
    required this.textFocusNode,
    required this.transformationController,
    required this.canvasKey,
    required this.onClearSelection,
    required this.onBubbleTap,
    required this.onBubbleScaleStart,
    required this.onBubbleScaleUpdate,
    required this.onBubbleScaleEnd,
    required this.onChangeShape,
    required this.onFlipHorizontal,
    required this.onFlipVertical,
    required this.onDeleteSelectedBubble,
  });

  final Uint8List imageBytes;
  final Size imageSize;
  final List<SpeechBubbleData> bubbles;
  final String? selectedBubbleId;
  final SpeechBubbleData? selectedBubble;
  final bool isEditingText;
  final BubbleTextEditingController textController;
  final FocusNode textFocusNode;
  final TransformationController transformationController;
  final GlobalKey canvasKey;
  final VoidCallback onClearSelection;
  final BubbleTapCallback onBubbleTap;
  final BubbleScaleStartCallback onBubbleScaleStart;
  final BubbleScaleUpdateCallback onBubbleScaleUpdate;
  final VoidCallback onBubbleScaleEnd;
  final VoidCallback onChangeShape;
  final VoidCallback onFlipHorizontal;
  final VoidCallback onFlipVertical;
  final VoidCallback onDeleteSelectedBubble;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportSize = Size(
          math.max(120, constraints.maxWidth),
          math.max(120, constraints.maxHeight),
        );
        final displaySize = _fitSize(
          imageSize,
          Size(
            math.max(120, viewportSize.width - 24),
            math.max(120, viewportSize.height - 24),
          ),
        );
        final imageOffset = Offset(
          (viewportSize.width - displaySize.width) / 2,
          (viewportSize.height - displaySize.height) / 2,
        );

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                transformationController: transformationController,
                maxScale: 6,
                minScale: 1,
                constrained: false,
                boundaryMargin: const EdgeInsets.all(100000),
                clipBehavior: Clip.none,
                child: SizedBox(
                  width: viewportSize.width,
                  height: viewportSize.height,
                  child: Stack(
                    children: [
                      Positioned(
                        left: imageOffset.dx,
                        top: imageOffset.dy,
                        width: displaySize.width,
                        height: displaySize.height,
                        child: Container(
                          key: canvasKey,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: const [
                              BoxShadow(
                                blurRadius: 18,
                                offset: Offset(0, 12),
                                color: AppColors.canvasShadow,
                              ),
                            ],
                          ),
                          child: GestureDetector(
                            onTap: onClearSelection,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.memory(
                                    imageBytes,
                                    fit: BoxFit.fill,
                                    gaplessPlayback: true,
                                  ),
                                  for (final bubble in bubbles)
                                    BubbleOverlay(
                                      bubble: bubble,
                                      displaySize: displaySize,
                                      selected: bubble.id == selectedBubbleId,
                                      isEditingText:
                                          isEditingText &&
                                          bubble.id == selectedBubbleId,
                                      textController:
                                          isEditingText &&
                                              bubble.id == selectedBubbleId
                                          ? textController
                                          : null,
                                      textFocusNode:
                                          isEditingText &&
                                              bubble.id == selectedBubbleId
                                          ? textFocusNode
                                          : null,
                                      onTap: () => onBubbleTap(bubble.id),
                                      onScaleStart: (details) =>
                                          onBubbleScaleStart(
                                            bubble,
                                            details,
                                            displaySize,
                                          ),
                                      onScaleUpdate: (details) =>
                                          onBubbleScaleUpdate(
                                            bubble,
                                            details,
                                            displaySize,
                                          ),
                                      onScaleEnd: (_) => onBubbleScaleEnd(),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (selectedBubble != null)
              AnimatedBuilder(
                animation: transformationController,
                builder: (context, child) {
                  final bubbleTopAnchor = Offset(
                    imageOffset.dx +
                        selectedBubble!.center.dx * displaySize.width,
                    imageOffset.dy +
                        (selectedBubble!.center.dy -
                                selectedBubble!.heightFactor / 2) *
                            displaySize.height,
                  );
                  final transformedAnchor = MatrixUtils.transformPoint(
                    transformationController.value,
                    bubbleTopAnchor,
                  );

                  return SelectedBubbleToolbar(
                    anchor: transformedAnchor,
                    viewportSize: viewportSize,
                    onChangeShape: onChangeShape,
                    onFlipHorizontal: onFlipHorizontal,
                    onFlipVertical: onFlipVertical,
                    onDelete: onDeleteSelectedBubble,
                  );
                },
              ),
          ],
        );
      },
    );
  }
}

Size _fitSize(Size source, Size bounds) {
  final widthScale = bounds.width / source.width;
  final heightScale = bounds.height / source.height;
  final scale = math.min(widthScale, heightScale);
  return Size(source.width * scale, source.height * scale);
}
