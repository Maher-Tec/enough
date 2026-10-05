import 'dart:math';
import 'package:flutter/material.dart';

class FilmGrain extends StatefulWidget {
  final double opacity;

  const FilmGrain({super.key, this.opacity = 0.025});

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

    final grainSize = 1.2;
    final density = 0.002;
    final count = (size.width * size.height * density).toInt();

    for (int i = 0; i < count; i++) {
      paint.color = Colors.white.withValues(
        alpha: random.nextDouble() * opacity,
      );

      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;

      canvas.drawRect(Rect.fromLTWH(x, y, grainSize, grainSize), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GrainPainter oldDelegate) => true;
}
