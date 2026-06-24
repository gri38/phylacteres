import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/app_colors.dart';

class SelectedBubbleToolbar extends StatelessWidget {
  const SelectedBubbleToolbar({
    super.key,
    required this.anchor,
    required this.viewportSize,
    required this.onChangeShape,
    required this.onFlipHorizontal,
    required this.onFlipVertical,
    required this.onResetRotation,
    required this.onDelete,
  });

  final Offset anchor;
  final Size viewportSize;
  final VoidCallback onChangeShape;
  final VoidCallback onFlipHorizontal;
  final VoidCallback onFlipVertical;
  final VoidCallback onResetRotation;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const toolbarWidth = 220.0;
    final toolbarLeft = (anchor.dx - toolbarWidth / 2).clamp(
      8.0,
      viewportSize.width - toolbarWidth - 8,
    );
    final toolbarTop = (anchor.dy - 48).clamp(8.0, viewportSize.height - 40);

    return Positioned(
      left: toolbarLeft,
      top: toolbarTop,
      width: toolbarWidth,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.floatingTool,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.floatingToolBorder),
          boxShadow: const [
            BoxShadow(
              blurRadius: 12,
              offset: Offset(0, 5),
              color: Color(0x22000000),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _ActionButton(
              icon: Icons.change_circle_outlined,
              tooltip: l10n.changeSpeechBubble,
              onTap: onChangeShape,
            ),
            _ActionButton(
              icon: Icons.swap_horiz,
              tooltip: l10n.flipHorizontally,
              onTap: onFlipHorizontal,
            ),
            _ActionButton(
              icon: Icons.swap_vert,
              tooltip: l10n.flipVertically,
              onTap: onFlipVertical,
            ),
            _ActionButton(
              tooltip: l10n.resetRotation,
              onTap: onResetRotation,
              child: const Text(
                '0°',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.bubbleOutline,
                ),
              ),
            ),
            _ActionButton(
              icon: Icons.delete_outline,
              tooltip: l10n.delete,
              onTap: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    this.icon,
    this.child,
    this.tooltip,
    required this.onTap,
  }) : assert(icon != null || child != null);

  final IconData? icon;
  final Widget? child;
  final String? tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final button = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 36,
        height: 32,
        child: Center(
          child: child ?? Icon(icon, size: 18, color: AppColors.bubbleOutline),
        ),
      ),
    );

    if (tooltip == null) {
      return button;
    }

    return Tooltip(message: tooltip, child: button);
  }
}
