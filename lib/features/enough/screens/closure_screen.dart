import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_durations.dart';
import '../../../core/services/sound_service.dart';
import '../widgets/film_grain.dart';
import '../widgets/floating_dust.dart';
import '../widgets/heavy_button.dart';
import '../widgets/soft_vignette.dart';

/// The Aftermath — Interactive Stardust & Gentle Grounding
///
/// Features:
/// 1. Stardust Embers playground: Touch the screen to stir and scatter the floating stardust embers!
/// 2. If a burden was imprinted, it gently displays as dissolved into pure light.
/// 3. Guided calm breathing ring.
/// 4. Delayed mindful exit button.
class ClosureScreen extends StatefulWidget {
  final String dissolvedThought;

  const ClosureScreen({
    super.key,
    this.dissolvedThought = '',
  });

  @override
  State<ClosureScreen> createState() => _ClosureScreenState();
}

class _ClosureScreenState extends State<ClosureScreen>
    with TickerProviderStateMixin {
  late final AnimationController _arrival = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 950),
  )..forward();

  late final AnimationController _settle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..forward();

  late final AnimationController _breatheController = AnimationController(
    vsync: this,
    duration: AppDurations.breatheCycle,
  )..repeat(reverse: true);

  // Interactive Stardust Touch Point
  Offset? _stardustTouch;
  final List<_StardustEmber> _embers = [];
  final math.Random _random = math.Random();
  Timer? _emberTimer;

  bool _showButton = false;

  @override
  void initState() {
    super.initState();

    unawaited(SoundService.playClosureChime());

    // Generate initial interactive stardust embers
    for (int i = 0; i < 35; i++) {
      _embers.add(_StardustEmber(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        vx: (_random.nextDouble() - 0.5) * 0.002,
        vy: -0.001 - (_random.nextDouble() * 0.003),
        size: 2.0 + _random.nextDouble() * 4.0,
        opacity: 0.3 + _random.nextDouble() * 0.6,
      ));
    }

    // Ember simulation tick
    _emberTimer = Timer.periodic(const Duration(milliseconds: 30), (_) {
      if (!mounted) return;
      setState(() {
        for (final ember in _embers) {
          ember.y += ember.vy;
          ember.x += ember.vx;

          // Stir embers towards touch
          if (_stardustTouch != null) {
            final media = MediaQuery.sizeOf(context);
            final touchX = _stardustTouch!.dx / media.width;
            final touchY = _stardustTouch!.dy / media.height;
            final dx = touchX - ember.x;
            final dy = touchY - ember.y;
            final dist = math.sqrt(dx * dx + dy * dy);
            if (dist < 0.28 && dist > 0.01) {
              ember.vx += (dx / dist) * 0.0015;
              ember.vy += (dy / dist) * 0.0015;
            }
          }

          // Wrap edges
          if (ember.y < 0) ember.y = 1.0;
          if (ember.x < 0) ember.x = 1.0;
          if (ember.x > 1) ember.x = 0.0;
        }
      });
    });

    // Delayed exit button
    Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _showButton = true);
    });
  }

  @override
  void dispose() {
    _emberTimer?.cancel();
    _arrival.dispose();
    _settle.dispose();
    _breatheController.dispose();
    super.dispose();
  }

  void _back(BuildContext context) => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmInk,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (d) => setState(() => _stardustTouch = d.localPosition),
        onPanEnd: (_) => setState(() => _stardustTouch = null),
        onTapDown: (d) => setState(() => _stardustTouch = d.localPosition),
        onTapUp: (_) => setState(() => _stardustTouch = null),
        child: Stack(
          children: [
            // Ambient Warm Radial Gradient
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.0, -0.15),
                    radius: 1.3,
                    colors: [
                      AppColors.accent.withValues(alpha: .22),
                      AppColors.warmInk,
                    ],
                    stops: const [.0, .85],
                  ),
                ),
              ),
            ),

            // Layer 1: Ambient Dust
            const Positioned.fill(
              child: FloatingDust(
                particleCount: 18,
                maxOpacity: 0.18,
                color: AppColors.candlelight,
              ),
            ),

            // Layer 2: Interactive Stardust Embers (Reactive to touch!)
            Positioned.fill(
              child: CustomPaint(
                painter: _StardustPainter(embers: _embers, touch: _stardustTouch),
              ),
            ),

            // Film Grain
            const Positioned.fill(
              child: FilmGrain(opacity: 0.025),
            ),

            // Soft Vignette
            const Positioned.fill(
              child: SoftVignette(intensity: 0.7),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
                child: AnimatedBuilder(
                  animation: _arrival,
                  builder: (context, child) => Opacity(
                    opacity: Curves.easeOut.transform(_arrival.value),
                    child: Transform.translate(
                      offset: Offset(0, 16 * (1 - _arrival.value)),
                      child: child,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Header
                      Row(
                        children: [
                          Icon(
                            Icons.blur_on_rounded,
                            color: AppColors.glassBlue.withValues(alpha: .9),
                            size: 22,
                          ),
                          const SizedBox(width: 9),
                          Text(
                            'ENOUGH',
                            style: AppTextStyles.eyebrow.copyWith(
                              color: AppColors.paper.withValues(alpha: .78),
                              letterSpacing: 2,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'REST NOW',
                            style: AppTextStyles.eyebrow.copyWith(
                              color: AppColors.paper.withValues(alpha: .4),
                              fontSize: 8.5,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Central Aura & Breathing Guide
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Soft Pulsing Breathing Aura
                          AnimatedBuilder(
                            animation: _breatheController,
                            builder: (context, _) {
                              final bVal = _breatheController.value;
                              return Container(
                                width: 210 + (bVal * 35),
                                height: 210 + (bVal * 35),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.glassBlue.withValues(
                                      alpha: 0.12 + (bVal * 0.15),
                                    ),
                                    width: 1.2,
                                  ),
                                ),
                              );
                            },
                          ),

                          // Settle Mark Painter
                          AnimatedBuilder(
                            animation: _settle,
                            builder: (context, _) => CustomPaint(
                              size: const Size(220, 220),
                              painter: _ReleaseMarkPainter(progress: _settle.value),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Headline
                      Text(
                        'You let it out.',
                        style: AppTextStyles.hero.copyWith(
                          fontSize: 38,
                          color: AppColors.paper,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),

                      // Dissolved Thought Notice OR Breath Cue
                      if (widget.dissolvedThought.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.glassBlue.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.glassBlue.withValues(alpha: 0.2)),
                          ),
                          child: Text(
                            '"${widget.dissolvedThought}" is gone into the light.',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.glassBlue,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      else
                        AnimatedBuilder(
                          animation: _breatheController,
                          builder: (context, _) {
                            final isExhale = _breatheController.status == AnimationStatus.reverse;
                            return Text(
                              isExhale ? 'Breathe out slowly.' : 'Breathe in peace.',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.paper.withValues(alpha: .68),
                                fontSize: 15,
                                letterSpacing: .5,
                              ),
                            );
                          },
                        ),

                      const SizedBox(height: 8),
                      Text(
                        'Touch the screen to stir the stardust embers.',
                        style: AppTextStyles.eyebrow.copyWith(
                          color: AppColors.paper.withValues(alpha: 0.35),
                          fontSize: 9,
                        ),
                      ),

                      const Spacer(),

                      // Delayed Exit Action
                      AnimatedOpacity(
                        opacity: _showButton ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 800),
                        child: IgnorePointer(
                          ignoring: !_showButton,
                          child: HeavyButton(
                            label: 'Ground myself',
                            onConfirm: () => _back(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StardustEmber {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  double opacity;

  _StardustEmber({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.opacity,
  });
}

class _StardustPainter extends CustomPainter {
  final List<_StardustEmber> embers;
  final Offset? touch;

  _StardustPainter({required this.embers, required this.touch});

  @override
  void paint(Canvas canvas, Size size) {
    for (final ember in embers) {
      final paint = Paint()
        ..color = AppColors.candlelight.withValues(alpha: ember.opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, ember.size * 0.8);

      canvas.drawCircle(
        Offset(ember.x * size.width, ember.y * size.height),
        ember.size,
        paint,
      );
    }

    // Touch Ripple
    if (touch != null) {
      canvas.drawCircle(
        touch!,
        32,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0
          ..color = AppColors.glassBlue.withValues(alpha: 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StardustPainter oldDelegate) => true;
}

class _ReleaseMarkPainter extends CustomPainter {
  final double progress;
  const _ReleaseMarkPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final travel = 115 * Curves.easeOutCubic.transform(progress);
    final fade = math.pow(1 - progress, 1.4).toDouble();

    // Dissolving Shards into particles
    for (var i = 0; i < 12; i++) {
      final angle =
          math.pi * 2 * i / 12 - math.pi / 2 + (i.isEven ? .08 : -.06);
      final distance = travel * (.7 + (i % 3) * .14);
      final point = Offset(
        center.dx + math.cos(angle) * distance,
        center.dy + math.sin(angle) * distance,
      );
      final width = 7.0 + (i % 3) * 2.0;
      final height = 12.0 + (i % 4) * 3.0;

      final shard = Path()
        ..moveTo(-width * .36, -height * .48)
        ..lineTo(width * .42, -height * .36)
        ..lineTo(width * .5, height * .08)
        ..lineTo(width * .12, height * .5)
        ..lineTo(-width * .48, height * .28)
        ..close();

      canvas.save();
      canvas.translate(point.dx, point.dy);
      canvas.rotate(angle + progress * (i.isEven ? .42 : -.38));
      canvas.drawPath(
        shard,
        Paint()
          ..color = (i.isEven ? AppColors.glassBlue : AppColors.glassLilac)
              .withValues(alpha: .5 * fade),
      );
      canvas.drawPath(
        shard,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = .8
          ..color = Colors.white.withValues(alpha: .7 * fade),
      );
      canvas.restore();
    }

    // Gentle central circle
    final coreRadius = 32 + 20 * Curves.easeOutBack.transform(progress);
    canvas.drawCircle(
      center,
      coreRadius,
      Paint()..color = AppColors.accent.withValues(alpha: .22),
    );
    canvas.drawCircle(
      center,
      coreRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = AppColors.glassBlue.withValues(alpha: .8),
    );

    // Cathartic Checkmark
    final check = Path()
      ..moveTo(center.dx - 13, center.dy)
      ..lineTo(center.dx - 3, center.dy + 10)
      ..lineTo(center.dx + 16, center.dy - 12);

    canvas.drawPath(
      check,
      Paint()
        ..color = AppColors.paper
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _ReleaseMarkPainter oldDelegate) =>
      progress != oldDelegate.progress;
}
