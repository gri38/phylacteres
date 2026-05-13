import 'package:flutter/material.dart';

class ColorChip extends StatelessWidget {
  const ColorChip({
    super.key,
    required this.color,
    required this.selected,
    required this.onTap,
    this.transparentLabel,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final String? transparentLabel;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? Theme.of(context).colorScheme.primary
        : const Color(0x33000000);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.a == 0 ? Colors.white : color,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: borderColor, width: selected ? 3 : 1.5),
        ),
        child: color.a == 0
            ? Center(
                child: Text(
                  transparentLabel ?? 'T',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              )
            : null,
      ),
    );
  }
}
