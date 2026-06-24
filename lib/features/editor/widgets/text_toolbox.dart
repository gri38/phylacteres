import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/app_colors.dart';
import '../models/speech_bubble.dart';
import 'background_color_picker_sheet.dart';

class TextToolbox extends StatelessWidget {
  const TextToolbox({
    super.key,
    required this.font,
    required this.textColor,
    required this.fontScaleFactor,
    required this.textAlign,
    required this.isBold,
    required this.isItalic,
    required this.onFontChanged,
    required this.onTextColorChanged,
    required this.onFontScaleChanged,
    required this.onTextAlignChanged,
    required this.onBoldChanged,
    required this.onItalicChanged,
    this.backgroundColor,
    this.onBackgroundColorChanged,
  });

  final BubbleFontOption font;
  final Color textColor;
  final double fontScaleFactor;
  final TextAlign textAlign;
  final bool isBold;
  final bool isItalic;
  final ValueChanged<BubbleFontOption> onFontChanged;
  final ValueChanged<Color> onTextColorChanged;
  final ValueChanged<double> onFontScaleChanged;
  final ValueChanged<TextAlign> onTextAlignChanged;
  final ValueChanged<bool> onBoldChanged;
  final ValueChanged<bool> onItalicChanged;
  final Color? backgroundColor;
  final ValueChanged<Color>? onBackgroundColorChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.floatingTool,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.floatingToolBorder),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            offset: Offset(0, 4),
            color: Color(0x22000000),
          ),
        ],
      ),
      child: Row(
        children: [
          PopupMenuButton<BubbleFontOption>(
            tooltip: l10n.font,
            onSelected: onFontChanged,
            itemBuilder: (context) {
              return BubbleFontOption.values.map((candidate) {
                final previewText = candidate == BubbleFontOption.tintin
                    ? 'Tintin'
                    : 'Aa';
                return PopupMenuItem(
                  value: candidate,
                  child: Center(
                    child: Text(
                      previewText,
                      style: candidate.resolveTextStyle(
                        fontSize: candidate == BubbleFontOption.tintin
                            ? 17
                            : 22,
                        color: AppColors.bubbleOutline,
                        bold: candidate == BubbleFontOption.outlined,
                        italic: false,
                      ),
                    ),
                  ),
                );
              }).toList();
            },
            child: _MiniToolChip(
              child: Text(
                'Aa',
                style: font.resolveTextStyle(
                  fontSize: 18,
                  color: AppColors.bubbleOutline,
                  bold: isBold,
                  italic: isItalic,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _ColorMenuButton(
            tooltip: l10n.textColor,
            colors: AppColors.textPalette,
            onSelected: onTextColorChanged,
          ),
          const SizedBox(width: 8),
          _ToggleButton(
            tooltip: l10n.bold,
            icon: Icons.format_bold,
            selected: isBold,
            onTap: () => onBoldChanged(!isBold),
          ),
          _ToggleButton(
            tooltip: l10n.italic,
            icon: Icons.format_italic,
            selected: isItalic,
            onTap: () => onItalicChanged(!isItalic),
          ),
          _ToggleButton(
            tooltip: l10n.alignment,
            icon: _alignIcon(textAlign),
            selected: true,
            onTap: () => onTextAlignChanged(_nextTextAlign(textAlign)),
          ),
          if (onBackgroundColorChanged != null && backgroundColor != null) ...[
            const SizedBox(width: 8),
            _BackgroundButton(
              color: backgroundColor!,
              onSelected: onBackgroundColorChanged!,
            ),
          ],
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 44,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 7,
                  ),
                  overlayShape: SliderComponentShape.noOverlay,
                ),
                child: Slider(
                  min: 0.09,
                  max: 0.42,
                  value: fontScaleFactor,
                  onChanged: onFontScaleChanged,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static IconData _alignIcon(TextAlign textAlign) => switch (textAlign) {
    TextAlign.left || TextAlign.start => Icons.format_align_left,
    TextAlign.right || TextAlign.end => Icons.format_align_right,
    _ => Icons.format_align_center,
  };

  static TextAlign _nextTextAlign(TextAlign textAlign) => switch (textAlign) {
    TextAlign.center => TextAlign.left,
    TextAlign.left || TextAlign.start => TextAlign.right,
    _ => TextAlign.center,
  };
}

class _BackgroundButton extends StatelessWidget {
  const _BackgroundButton({required this.color, required this.onSelected});

  final Color color;
  final ValueChanged<Color> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Tooltip(
      message: l10n.textBackground,
      child: InkWell(
        onTap: () async {
          final pickedColor = await showModalBottomSheet<Color>(
            context: context,
            isScrollControlled: true,
            showDragHandle: false,
            backgroundColor: Colors.white,
            builder: (context) => FractionallySizedBox(
              heightFactor: 0.92,
              child: BackgroundColorPickerSheet(initialColor: color),
            ),
          );
          if (pickedColor != null) {
            onSelected(pickedColor);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: _MiniToolChip(
          selected: color.a != 0,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const _QuadColorCircle(size: 18),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0x33000000)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorMenuButton extends StatelessWidget {
  const _ColorMenuButton({
    required this.tooltip,
    required this.colors,
    required this.onSelected,
  });

  final String tooltip;
  final List<Color> colors;
  final ValueChanged<Color> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopupMenuButton<Color>(
      tooltip: tooltip,
      onSelected: onSelected,
      itemBuilder: (context) {
        return colors.map((color) {
          return PopupMenuItem<Color>(
            value: color,
            child: Row(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: color.a == 0 ? Colors.white : color,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0x33000000)),
                  ),
                  child: color.a == 0
                      ? const Center(child: Icon(Icons.block, size: 10))
                      : null,
                ),
                const SizedBox(width: 10),
                Text(color.a == 0 ? l10n.transparent : l10n.color),
              ],
            ),
          );
        }).toList();
      },
      child: _MiniToolChip(
        child: const Icon(Icons.format_color_text, size: 18),
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.tooltip,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: selected
                ? Theme.of(context).colorScheme.primary.withAlpha(36)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18),
        ),
      ),
    );
  }
}

class _MiniToolChip extends StatelessWidget {
  const _MiniToolChip({required this.child, this.selected = false});

  final Widget child;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: selected
            ? Theme.of(context).colorScheme.primary.withAlpha(28)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x12000000)),
      ),
      child: Center(child: child),
    );
  }
}

class _QuadColorCircle extends StatelessWidget {
  const _QuadColorCircle({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: const _QuadColorCirclePainter(),
    );
  }
}

class _QuadColorCirclePainter extends CustomPainter {
  const _QuadColorCirclePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.width / 2;
    final paint = Paint()..style = PaintingStyle.fill;
    const colors = [
      Color(0xFFF59E0B),
      Color(0xFFEF4444),
      Color(0xFF3B82F6),
      Color(0xFF22C55E),
    ];

    for (var index = 0; index < 4; index++) {
      paint.color = colors[index];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -1.5708 + (index * 1.5708),
        1.5708,
        true,
        paint,
      );
    }

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0x33000000),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
