import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../models/speech_bubble.dart';

class BubblePickerSheet extends StatelessWidget {
  const BubblePickerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: AppColors.bubblePickerBackground,
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 18),
        child: SizedBox(
          height: 116,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: BubbleTemplate.values.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final template = BubbleTemplate.values[index];
              return InkWell(
                onTap: () => Navigator.of(context).pop(template),
                borderRadius: BorderRadius.circular(20),
                child: Ink(
                  width: 108,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(14),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withAlpha(18)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Image.asset(
                      template.assetPath,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
