import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

class BusyOverlay extends StatelessWidget {
  const BusyOverlay({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: AppColors.overlay,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 14),
                Text(label),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
