import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class EditorEmptyState extends StatelessWidget {
  const EditorEmptyState({super.key, required this.onPickImage});

  final VoidCallback onPickImage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.photo_camera_back_outlined, size: 72),
            const SizedBox(height: 16),
            Text(
              l10n.loadPhotoToStart,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              l10n.editorEmptyInstructions,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onPickImage,
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(l10n.choosePhoto),
            ),
          ],
        ),
      ),
    );
  }
}
