import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

class SelectedBubbleToolbar extends StatelessWidget {
  const SelectedBubbleToolbar({
    super.key,
    required this.anchor,
    required this.viewportSize,
    required this.onChangeShape,
    required this.onFlipHorizontal,
    required this.onFlipVertical,
    required this.onDelete,
  });

  final Offset anchor;
  final Size viewportSize;
  final VoidCallback onChangeShape;
  final VoidCallback onFlipHorizontal;
  final VoidCallback onFlipVertical;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    const toolbarWidth = 176.0;
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
              onTap: onChangeShape,
            ),
            _ActionButton(icon: Icons.swap_horiz, onTap: onFlipHorizontal),
            _ActionButton(icon: Icons.swap_vert, onTap: onFlipVertical),
            _ActionButton(icon: Icons.delete_outline, onTap: onDelete),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 36,
        height: 32,
        child: Icon(icon, size: 18, color: AppColors.bubbleOutline),
      ),
    );
  }
}
