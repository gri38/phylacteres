import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

class EditorToolbar extends StatelessWidget {
  const EditorToolbar({
    super.key,
    required this.hasImage,
    required this.onPickImage,
    required this.onAddBubble,
    required this.onCrop,
    required this.onSave,
  });

  final bool hasImage;
  final VoidCallback onPickImage;
  final VoidCallback onAddBubble;
  final VoidCallback onCrop;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.toolbar,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ToolbarItem(
            icon: Icons.photo_library_outlined,
            label: 'Photo',
            onTap: onPickImage,
          ),
          _ToolbarItem(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Bulle',
            onTap: hasImage ? onAddBubble : null,
          ),
          _ToolbarItem(
            icon: Icons.crop,
            label: 'Crop',
            onTap: hasImage ? onCrop : null,
          ),
          _ToolbarItem(
            icon: Icons.save_alt_outlined,
            label: 'Sauver',
            onTap: hasImage ? onSave : null,
          ),
        ],
      ),
    );
  }
}

class _ToolbarItem extends StatelessWidget {
  const _ToolbarItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: enabled ? Colors.white : Colors.white38,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: enabled ? Colors.white : Colors.white38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
