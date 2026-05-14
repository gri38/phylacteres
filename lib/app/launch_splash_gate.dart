import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class LaunchSplashGate extends StatefulWidget {
  const LaunchSplashGate({super.key, required this.child});

  final Widget child;

  @override
  State<LaunchSplashGate> createState() => _LaunchSplashGateState();
}

class _LaunchSplashGateState extends State<LaunchSplashGate> {
  Timer? _dismissTimer;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _dismissTimer = Timer(const Duration(seconds: 3), _dismissSplash);
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  void _dismissSplash() {
    if (!_showSplash || !mounted) {
      return;
    }
    _dismissTimer?.cancel();
    setState(() {
      _showSplash = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_showSplash) {
      return widget.child;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _dismissSplash,
      child: const ColoredBox(
        color: AppColors.splashBackground,
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Image(
              image: AssetImage('assets/tintin/haddock.png'),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
