import 'package:flutter/material.dart';
import '../features/editor/pages/photo_editor_page.dart';
import '../l10n/app_localizations.dart';
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
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: (locale, supportedLocales) {
        for (final supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return const Locale('en');
      },
      home: const LaunchSplashGate(child: PhotoEditorPage()),
    );
  }
}
