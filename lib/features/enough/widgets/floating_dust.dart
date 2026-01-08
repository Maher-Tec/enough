import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// ENOUGH — Floating Dust Particles
/// 
/// HOME FEELING:
/// - Like dust in warm evening sunlight
/// - Visible enough to feel, not to distract
/// - Warm amber color
/// - Slow, dreamy drift
class FloatingDust extends StatefulWidget {
  final int particleCount;
  final double maxOpacity;
  
  const FloatingDust({
    super.key,
    this.particleCount = 12,     // Visible presence
    this.maxOpacity = 0.15,      // Noticeable
  });

  @override
  State<FloatingDust> createState() => _FloatingDustState();
}

class _FloatingDustState extends State<FloatingDust>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_DustParticle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    // 35 second cycle - dreamy, slow
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 35),
    )..repeat();
    
    _particles = List.generate(
      widget.particleCount,
      (_) => _DustParticle(_random, widget.maxOpacity),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _DustPainter(
              particles: _particles,
              progress: _controller.value,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _DustParticle {
  final double x;
  final double startY;
  final double size;
  final double speed;
  final double baseOpacity;
  final double phase;
  final double blinkPhase;

  _DustParticle(Random random, double maxOpacity)
      : x = random.nextDouble(),
        startY = random.nextDouble(),
        // Bigger particles (4-7px) - more visible, like real dust
        size = 4.0 + random.nextDouble() * 3.0,
        // Very slow (0.10-0.20)
        speed = 0.10 + random.nextDouble() * 0.10,
        // Higher opacity for visibility
        baseOpacity = 0.06 + random.nextDouble() * (maxOpacity - 0.06),
        phase = random.nextDouble() * 2 * pi,
        blinkPhase = random.nextDouble() * 2 * pi;
}

class _DustPainter extends CustomPainter {
  final List<_DustParticle> particles;
  final double progress;

  _DustPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final animProgress = (progress * particle.speed + particle.startY) % 1.0;
      final y = size.height * (1 - animProgress);
      
      // Gentle horizontal drift
      final driftOffset = sin(progress * pi * 0.4 + particle.phase) * 25;
      final x = size.width * particle.x + driftOffset;
      
      // Fade in/out
      double fadeOpacity = particle.baseOpacity;
      if (animProgress < 0.15) {
        fadeOpacity *= animProgress / 0.15;
      } else if (animProgress > 0.85) {
        fadeOpacity *= (1 - animProgress) / 0.15;
      }
      
      // Subtle blink (±15%)
      final blinkValue = sin(progress * 0.5 * 2 * pi + particle.blinkPhase);
      fadeOpacity *= (0.85 + blinkValue * 0.15);
      
      if (fadeOpacity < 0.02) continue;
      
      // Use warm accent color - like dust in sunlight
      final paint = Paint()
        ..color = AppColors.accentWarm.withValues(alpha: fadeOpacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, particle.size * 1.5);
      
      canvas.drawCircle(
        Offset(x, y),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DustPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
