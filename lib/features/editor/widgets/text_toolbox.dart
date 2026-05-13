import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../models/speech_bubble.dart';

class BubbleTextToolbox extends StatelessWidget {
  const BubbleTextToolbox({
    super.key,
    required this.bubble,
    required this.onFontChanged,
    required this.onTextColorChanged,
    required this.onFontScaleChanged,
    required this.onTextAlignChanged,
  });

  final SpeechBubbleData bubble;
  final ValueChanged<BubbleFontOption> onFontChanged;
  final ValueChanged<Color> onTextColorChanged;
  final ValueChanged<double> onFontScaleChanged;
  final ValueChanged<TextAlign> onTextAlignChanged;

  @override
  Widget build(BuildContext context) {
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
            tooltip: 'Police',
            onSelected: onFontChanged,
            itemBuilder: (context) {
              return BubbleFontOption.values.map((font) {
                return PopupMenuItem(value: font, child: Text(font.label));
              }).toList();
            },
            child: _MiniToolChip(
              child: Text(
                'Aa',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontFamily: bubble.font.familyName,
                  color: AppColors.bubbleOutline,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _ColorMenuButton(
            icon: Icons.format_color_text,
            colors: AppColors.textPalette,
            onSelected: onTextColorChanged,
          ),
          const SizedBox(width: 8),
          _AlignButton(
            icon: Icons.format_align_left,
            selected: bubble.textAlign == TextAlign.left,
            onTap: () => onTextAlignChanged(TextAlign.left),
          ),
          _AlignButton(
            icon: Icons.format_align_center,
            selected: bubble.textAlign == TextAlign.center,
            onTap: () => onTextAlignChanged(TextAlign.center),
          ),
          _AlignButton(
            icon: Icons.format_align_right,
            selected: bubble.textAlign == TextAlign.right,
            onTap: () => onTextAlignChanged(TextAlign.right),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                overlayShape: SliderComponentShape.noOverlay,
              ),
              child: Slider(
                min: 0.09,
                max: 0.42,
                value: bubble.fontScaleFactor,
                onChanged: onFontScaleChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorMenuButton extends StatelessWidget {
  const _ColorMenuButton({
    required this.icon,
    required this.colors,
    required this.onSelected,
  });

  final IconData icon;
  final List<Color> colors;
  final ValueChanged<Color> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Color>(
      tooltip: 'Couleur',
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
                Text(color.a == 0 ? 'Transparent' : 'Couleur'),
              ],
            ),
          );
        }).toList();
      },
      child: _MiniToolChip(child: Icon(icon, size: 18)),
    );
  }
}

class _AlignButton extends StatelessWidget {
  const _AlignButton({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
    );
  }
}

class _MiniToolChip extends StatelessWidget {
  const _MiniToolChip({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x12000000)),
      ),
      child: Center(child: child),
    );
  }
}
