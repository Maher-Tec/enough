import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// ENOUGH — Soft Vignette Overlay
/// 
/// Creates atmospheric depth with a radial gradient
/// that darkens the edges of the screen.
class SoftVignette extends StatelessWidget {
  final double intensity;
  
  const SoftVignette({
    super.key,
    this.intensity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              Colors.transparent,
              AppColors.backgroundDepth.withValues(alpha: 0.3 * intensity),
              AppColors.backgroundDepth.withValues(alpha: 0.7 * intensity),
              Colors.black.withValues(alpha: 0.5 * intensity),
            ],
            stops: const [0.0, 0.5, 0.8, 1.0],
          ),
        ),
      ),
    );
  }
}
