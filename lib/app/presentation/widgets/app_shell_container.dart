import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_shadows.dart';

class AppShellContainer extends StatelessWidget {
  final Widget child;

  const AppShellContainer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF0F7F2),
            AppColors.background,
            AppColors.surface,
          ],
          stops: [0, 0.34, 1],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned(
            left: -120,
            top: -110,
            child: _ShellGlow(
              size: 320,
              color: AppColors.primarySupport,
            ),
          ),
          const Positioned(
            right: -90,
            top: 80,
            child: _ShellGlow(
              size: 240,
              color: AppColors.beigeSoft,
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _ShellGlow extends StatelessWidget {
  final double size;
  final Color color;

  const _ShellGlow({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: 0.2),
              color.withValues(alpha: 0.0),
            ],
          ),
          boxShadow: AppShadows.floating,
        ),
      ),
    );
  }
}
