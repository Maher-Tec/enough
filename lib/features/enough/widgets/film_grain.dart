import 'dart:math';
import 'package:flutter/material.dart';

/// ENOUGH — Film Grain
/// 
/// A micro-thin layer of animated noise.
/// - Solves digital "banding" in gradients.
/// - Makes backgrounds feel like physical paper or atmosphere.
/// - Extremely low opacity (2-3%).
class FilmGrain extends StatefulWidget {
  final double opacity;
  
  const FilmGrain({
    super.key,
    this.opacity = 0.025, // Micro-thin
  });

  @override
  State<FilmGrain> createState() => _FilmGrainState();
}

class _FilmGrainState extends State<FilmGrain>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    // Fast enough to feel like noise, slow enough not to be a distraction
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..repeat();
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
            painter: _GrainPainter(
              random: _random,
              opacity: widget.opacity,
              seed: _controller.value,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _GrainPainter extends CustomPainter {
  final Random random;
  final double opacity;
  final double seed;

  _GrainPainter({
    required this.random,
    required this.opacity,
    required this.seed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // We draw random dots across the screen.
    // Instead of drawing thousands of pixels (expensive), 
    // we draw sparse, slightly larger "grains".
    final grainSize = 1.2;
    final density = 0.002; // Adjust for "texture" vs "noise"
    final count = (size.width * size.height * density).toInt();
    
    for (int i = 0; i < count; i++) {
      paint.color = Colors.white.withValues(
        alpha: random.nextDouble() * opacity,
      );
      
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      
      canvas.drawRect(
        Rect.fromLTWH(x, y, grainSize, grainSize),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GrainPainter oldDelegate) => true;
}
