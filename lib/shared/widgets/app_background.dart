import 'dart:ui';

import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/branding/app_background.png'),
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF001225).withValues(alpha: 0.86),
                    const Color(0xFF031B32).withValues(alpha: 0.82),
                    const Color(0xFF020B17).withValues(alpha: 0.92),
                  ]
                : [
                    const Color(0xFFFFFBF2).withValues(alpha: 0.82),
                    const Color(0xFFF8FBFF).withValues(alpha: 0.86),
                    const Color(0xFFFFF8EA).withValues(alpha: 0.9),
                  ],
          ),
        ),
        child: child,
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  const GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(22),
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF101C33).withValues(alpha: 0.92)
                : colorScheme.surface.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.06),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.24 : 0.08),
                blurRadius: 28,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
