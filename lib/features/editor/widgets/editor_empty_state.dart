import 'package:flutter/material.dart';

class EditorEmptyState extends StatelessWidget {
  const EditorEmptyState({super.key, required this.onPickImage});

  final VoidCallback onPickImage;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.photo_camera_back_outlined, size: 72),
            const SizedBox(height: 16),
            Text(
              'Chargez une photo pour commencer.',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Ajoutez ensuite vos bulles, déplacez-les au doigt, pincez pour les redimensionner et tournez-les à deux doigts.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onPickImage,
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Choisir une photo'),
            ),
          ],
        ),
      ),
    );
  }
}
