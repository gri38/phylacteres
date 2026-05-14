import 'package:flutter/material.dart';

import '../features/editor/pages/photo_editor_page.dart';
import '../theme/app_theme.dart';
import 'launch_splash_gate.dart';

class PhylactereApp extends StatelessWidget {
  const PhylactereApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phylactere',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const LaunchSplashGate(child: PhotoEditorPage()),
    );
  }
}
