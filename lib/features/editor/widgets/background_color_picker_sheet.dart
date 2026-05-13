import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

class BackgroundColorPickerSheet extends StatefulWidget {
  const BackgroundColorPickerSheet({super.key, required this.initialColor});

  final Color initialColor;

  @override
  State<BackgroundColorPickerSheet> createState() =>
      _BackgroundColorPickerSheetState();
}

class _BackgroundColorPickerSheetState
    extends State<BackgroundColorPickerSheet> {
  late double _hue;
  late double _saturation;
  late double _alpha;

  Color get _currentColor =>
      HSVColor.fromAHSV(_alpha, _hue, _saturation, 1).toColor();

  @override
  void initState() {
    super.initState();
    final initial = widget.initialColor;
    final baseColor = initial.a == 0 ? Colors.white : initial.withAlpha(255);
    final hsv = HSVColor.fromColor(baseColor);
    _hue = hsv.hue;
    _saturation = hsv.saturation == 0 ? 0.32 : hsv.saturation;
    _alpha = initial.a == 0 ? 0 : initial.a;
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = _currentColor;

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Scrollbar(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0x22000000),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Fond du texte',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _ColorPreview(color: selectedColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _alpha == 0
                                ? 'Transparent'
                                : 'Opacite ${(selectedColor.a * 100).round()}%',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: AppColors.textBackgroundPalette.map((color) {
                        final displayColor = color.a == 0
                            ? Colors.transparent
                            : Color.fromARGB(
                                _toChannel(selectedColor.a),
                                _toChannel(color.r),
                                _toChannel(color.g),
                                _toChannel(color.b),
                              );
                        final isSelected =
                            (color.a == 0 && _alpha == 0) ||
                            (color.a != 0 &&
                                _alpha != 0 &&
                                _sameRgb(displayColor, selectedColor));
                        return _PaletteButton(
                          color: color.a == 0 ? color : displayColor,
                          selected: isSelected,
                          onTap: () {
                            setState(() {
                              if (color.a == 0) {
                                _alpha = 0;
                              } else {
                                final hsv = HSVColor.fromColor(color);
                                _hue = hsv.hue;
                                _saturation = hsv.saturation;
                                if (_alpha == 0) {
                                  _alpha = 0.7;
                                }
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: _HueWheel(
                        hue: _hue,
                        color: selectedColor,
                        onChanged: (value) {
                          setState(() {
                            _hue = value;
                            if (_alpha == 0) {
                              _alpha = 0.7;
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Saturation',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    Slider(
                      min: 0,
                      max: 1,
                      value: _saturation,
                      onChanged: (value) {
                        setState(() {
                          _saturation = value;
                          if (_alpha == 0 && value > 0) {
                            _alpha = 0.7;
                          }
                        });
                      },
                    ),
                    Text(
                      'Transparence',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    Slider(
                      min: 0,
                      max: 1,
                      value: _alpha,
                      onChanged: (value) {
                        setState(() {
                          _alpha = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Annuler'),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: () =>
                              Navigator.of(context).pop(selectedColor),
                          child: const Text('Appliquer'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ColorPreview extends StatelessWidget {
  const _ColorPreview({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x18000000)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _CheckerPainter()),
          ColoredBox(color: color),
        ],
      ),
    );
  }
}

class _PaletteButton extends StatelessWidget {
  const _PaletteButton({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 34,
        height: 34,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : const Color(0x18000000),
            width: selected ? 2 : 1,
          ),
        ),
        child: ClipOval(
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(painter: _CheckerPainter()),
              ColoredBox(color: color),
            ],
          ),
        ),
      ),
    );
  }
}

class _HueWheel extends StatelessWidget {
  const _HueWheel({
    required this.hue,
    required this.color,
    required this.onChanged,
  });

  final double hue;
  final Color color;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanDown: (details) => _handleOffset(details.localPosition),
      onPanUpdate: (details) => _handleOffset(details.localPosition),
      onTapDown: (details) => _handleOffset(details.localPosition),
      child: CustomPaint(
        painter: _HueWheelPainter(hue: hue, color: color),
        size: const Size.square(180),
      ),
    );
  }

  void _handleOffset(Offset localPosition) {
    const size = 180.0;
    final center = const Offset(size / 2, size / 2);
    final vector = localPosition - center;
    final angle = math.atan2(vector.dy, vector.dx);
    final degrees = (angle * 180 / math.pi + 360) % 360;
    onChanged(degrees);
  }
}

class _HueWheelPainter extends CustomPainter {
  const _HueWheelPainter({required this.hue, required this.color});

  final double hue;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2;
    const strokeWidth = 18.0;

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = SweepGradient(
        colors: const [
          Color(0xFFFF0000),
          Color(0xFFFFFF00),
          Color(0xFF00FF00),
          Color(0xFF00FFFF),
          Color(0xFF0000FF),
          Color(0xFFFF00FF),
          Color(0xFFFF0000),
        ],
      ).createShader(rect);
    canvas.drawCircle(center, radius - strokeWidth / 2, ringPaint);

    final innerRadius = radius - strokeWidth - 8;
    final previewRect = Rect.fromCircle(center: center, radius: innerRadius);
    final previewRRect = RRect.fromRectAndRadius(
      previewRect,
      Radius.circular(innerRadius),
    );
    final previewPaint = Paint()..color = Colors.white;
    canvas.drawRRect(previewRRect, previewPaint);
    canvas.save();
    canvas.clipRRect(previewRRect);
    canvas.translate(previewRect.left, previewRect.top);
    _CheckerPainter().paint(canvas, previewRect.size);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, previewRect.width, previewRect.height),
      Paint()..color = color,
    );
    canvas.restore();
    canvas.drawRRect(
      previewRRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0x18000000),
    );

    final indicatorAngle = hue * math.pi / 180;
    final indicatorRadius = radius - strokeWidth / 2;
    final indicatorCenter = Offset(
      center.dx + math.cos(indicatorAngle) * indicatorRadius,
      center.dy + math.sin(indicatorAngle) * indicatorRadius,
    );
    canvas.drawCircle(indicatorCenter, 8, Paint()..color = Colors.white);
    canvas.drawCircle(
      indicatorCenter,
      8,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.black.withAlpha(180),
    );
  }

  @override
  bool shouldRepaint(covariant _HueWheelPainter oldDelegate) {
    return oldDelegate.hue != hue || oldDelegate.color != color;
  }
}

class _CheckerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const square = 8.0;
    final lightPaint = Paint()..color = const Color(0xFFF8FAFC);
    final darkPaint = Paint()..color = const Color(0xFFE5E7EB);
    for (var row = 0.0; row < size.height; row += square) {
      for (var col = 0.0; col < size.width; col += square) {
        final isDark = ((row / square).floor() + (col / square).floor()).isOdd;
        canvas.drawRect(
          Rect.fromLTWH(col, row, square, square),
          isDark ? darkPaint : lightPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

bool _sameRgb(Color left, Color right) {
  return left.r == right.r && left.g == right.g && left.b == right.b;
}

int _toChannel(double value) => (value * 255).round() & 0xff;
