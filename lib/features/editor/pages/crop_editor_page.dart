import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class CropEditorPage extends StatefulWidget {
  const CropEditorPage({
    super.key,
    required this.imageBytes,
    required this.imageSize,
  });

  final Uint8List imageBytes;
  final Size imageSize;

  @override
  State<CropEditorPage> createState() => _CropEditorPageState();
}

class _CropEditorPageState extends State<CropEditorPage> {
  Rect? _cropRect;
  _CropDragMode _dragMode = _CropDragMode.none;
  Offset _lastPosition = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.crop),
        actions: [
          TextButton(
            onPressed: () {
              final rect = _cropRect;
              if (rect != null) {
                Navigator.of(context).pop(rect);
              }
            },
            child: Text(l10n.apply),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final displaySize = _fitCropSize(
            widget.imageSize,
            Size(constraints.maxWidth - 32, constraints.maxHeight - 32),
          );
          _cropRect ??= Rect.fromLTWH(0.12, 0.12, 0.76, 0.76);

          return Center(
            child: SizedBox(
              width: displaySize.width,
              height: displaySize.height,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.memory(widget.imageBytes, fit: BoxFit.fill),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanStart: (details) {
                      final normalized = Offset(
                        details.localPosition.dx / displaySize.width,
                        details.localPosition.dy / displaySize.height,
                      );
                      if (_cropRect!.contains(normalized)) {
                        _dragMode = _CropDragMode.move;
                        _lastPosition = normalized;
                      }
                    },
                    onPanUpdate: (details) {
                      final normalized = Offset(
                        details.localPosition.dx / displaySize.width,
                        details.localPosition.dy / displaySize.height,
                      );
                      if (_dragMode == _CropDragMode.move) {
                        final delta = normalized - _lastPosition;
                        _lastPosition = normalized;
                        setState(() {
                          _cropRect = _moveRect(_cropRect!, delta);
                        });
                      }
                    },
                    onPanEnd: (_) => _dragMode = _CropDragMode.none,
                    child: CustomPaint(
                      painter: _CropOverlayPainter(_cropRect!),
                    ),
                  ),
                  ..._buildHandles(displaySize),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildHandles(Size displaySize) {
    final rect = _cropRect!;
    return [
      _buildHandle(
        position: Offset(rect.left, rect.top),
        mode: _CropDragMode.topLeft,
        displaySize: displaySize,
      ),
      _buildHandle(
        position: Offset(rect.right, rect.top),
        mode: _CropDragMode.topRight,
        displaySize: displaySize,
      ),
      _buildHandle(
        position: Offset(rect.left, rect.bottom),
        mode: _CropDragMode.bottomLeft,
        displaySize: displaySize,
      ),
      _buildHandle(
        position: Offset(rect.right, rect.bottom),
        mode: _CropDragMode.bottomRight,
        displaySize: displaySize,
      ),
    ];
  }

  Widget _buildHandle({
    required Offset position,
    required _CropDragMode mode,
    required Size displaySize,
  }) {
    return Positioned(
      left: position.dx * displaySize.width - 18,
      top: position.dy * displaySize.height - 18,
      width: 36,
      height: 36,
      child: GestureDetector(
        onPanStart: (_) => _dragMode = mode,
        onPanUpdate: (details) {
          final delta = Offset(
            details.delta.dx / displaySize.width,
            details.delta.dy / displaySize.height,
          );
          setState(() {
            _cropRect = _resizeRect(_cropRect!, delta, mode);
          });
        },
        onPanEnd: (_) => _dragMode = _CropDragMode.none,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFF111827), width: 2),
          ),
        ),
      ),
    );
  }

  Rect _moveRect(Rect rect, Offset delta) {
    final shifted = rect.shift(delta);
    final dx = shifted.left < 0
        ? -shifted.left
        : shifted.right > 1
        ? 1 - shifted.right
        : 0.0;
    final dy = shifted.top < 0
        ? -shifted.top
        : shifted.bottom > 1
        ? 1 - shifted.bottom
        : 0.0;
    return shifted.shift(Offset(dx, dy));
  }

  Rect _resizeRect(Rect rect, Offset delta, _CropDragMode mode) {
    const minSize = 0.18;

    double left = rect.left;
    double top = rect.top;
    double right = rect.right;
    double bottom = rect.bottom;

    switch (mode) {
      case _CropDragMode.topLeft:
        left += delta.dx;
        top += delta.dy;
        break;
      case _CropDragMode.topRight:
        right += delta.dx;
        top += delta.dy;
        break;
      case _CropDragMode.bottomLeft:
        left += delta.dx;
        bottom += delta.dy;
        break;
      case _CropDragMode.bottomRight:
        right += delta.dx;
        bottom += delta.dy;
        break;
      case _CropDragMode.move:
      case _CropDragMode.none:
        break;
    }

    left = (left.clamp(0.0, right - minSize) as num).toDouble();
    top = (top.clamp(0.0, bottom - minSize) as num).toDouble();
    right = (right.clamp(left + minSize, 1.0) as num).toDouble();
    bottom = (bottom.clamp(top + minSize, 1.0) as num).toDouble();

    return Rect.fromLTRB(left, top, right, bottom);
  }
}

class _CropOverlayPainter extends CustomPainter {
  const _CropOverlayPainter(this.cropRect);

  final Rect cropRect;

  @override
  void paint(Canvas canvas, Size size) {
    final overlay = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(
        Rect.fromLTWH(
          cropRect.left * size.width,
          cropRect.top * size.height,
          cropRect.width * size.width,
          cropRect.height * size.height,
        ),
      )
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(overlay, Paint()..color = const Color(0xAA000000));

    canvas.drawRect(
      Rect.fromLTWH(
        cropRect.left * size.width,
        cropRect.top * size.height,
        cropRect.width * size.width,
        cropRect.height * size.height,
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _CropOverlayPainter oldDelegate) {
    return oldDelegate.cropRect != cropRect;
  }
}

enum _CropDragMode { none, move, topLeft, topRight, bottomLeft, bottomRight }

Size _fitCropSize(Size source, Size bounds) {
  final widthScale = bounds.width / source.width;
  final heightScale = bounds.height / source.height;
  final scale = widthScale < heightScale ? widthScale : heightScale;
  return Size(source.width * scale, source.height * scale);
}
