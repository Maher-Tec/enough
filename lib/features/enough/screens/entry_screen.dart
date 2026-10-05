import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_durations.dart';
import '../../../core/services/day_guard_service.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/services/sound_service.dart';
import '../../../core/services/tilt_service.dart';
import '../widgets/film_grain.dart';
import '../widgets/floating_dust.dart';
import '../widgets/heavy_button.dart';
import '../widgets/soft_vignette.dart';
import 'closure_screen.dart';

class EntryScreen extends StatefulWidget {
  const EntryScreen({super.key});

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen>
    with TickerProviderStateMixin {
  late final AnimationController _breatheController = AnimationController(
    vsync: this,
    duration: AppDurations.orbBreathe,
  )..repeat(reverse: true);

  late final AnimationController _pressureController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  );

  late final AnimationController _shatterController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  );

  late final AnimationController _flashController = AnimationController(
    vsync: this,
    duration: AppDurations.whiteFlash,
  );

  final TextEditingController _thoughtController = TextEditingController();
  String _imprintedThought = '';

  bool _canUseToday = true;
  final DayGuardService _dayGuard = DayGuardService();

  Offset _touchPoint = const Offset(0.5, 0.5);
  double _indentDepth = 0.0;
  double _swipeEnergy = 0.0;
  bool _isExploding = false;
  bool _soundEnabled = true;

  Timer? _hapticLoop;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    TiltService.start();
    _checkDayGuard();

    _ticker = Timer.periodic(const Duration(milliseconds: 20), (_) {
      if (mounted && !_isExploding) {
        setState(() {});
      }
    });
  }

  Future<void> _checkDayGuard() async {
    await _dayGuard.init();
    if (mounted) {
      setState(() {
        _canUseToday = _dayGuard.canUseToday();
      });
    }
  }

  @override
  void dispose() {
    TiltService.stop();
    _ticker?.cancel();
    _hapticLoop?.cancel();
    _breatheController.dispose();
    _pressureController.dispose();
    _shatterController.dispose();
    _flashController.dispose();
    _thoughtController.dispose();
    super.dispose();
  }

  void _onPressStart(Offset localPosition, Size canvasSize) {
    if (_isExploding) return;
    _touchPoint = Offset(
      (localPosition.dx / canvasSize.width).clamp(0.1, 0.9),
      (localPosition.dy / canvasSize.height).clamp(0.1, 0.9),
    );
    _indentDepth = 1.0;

    HapticService.subtle();
    _pressureController.forward();

    _hapticLoop?.cancel();
    _hapticLoop = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (_isExploding) {
        timer.cancel();
        return;
      }
      final p = _pressureController.value;
      if (p > 0.88) {
        HapticService.heavyPulse();
      } else if (p > 0.5) {
        HapticFeedback.mediumImpact();
      } else {
        HapticFeedback.selectionClick();
      }

      if (_pressureController.isCompleted) {
        timer.cancel();
        _detonate();
      }
    });
  }

  void _onPressEnd() {
    if (_isExploding) return;
    _hapticLoop?.cancel();
    _indentDepth = 0.0;
    if (!_pressureController.isCompleted && _swipeEnergy < 80) {
      _pressureController.animateTo(
        math.max(0.0, _pressureController.value - 0.3),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isExploding) return;
    _swipeEnergy += details.delta.distance;
    final added = details.delta.distance / 110.0;
    _pressureController.value = (_pressureController.value + added).clamp(
      0.0,
      1.0,
    );

    if (_pressureController.value >= 0.95 || _swipeEnergy > 170) {
      _detonate();
    }
  }

  void _openThoughtDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.ink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(color: AppColors.glassBlue.withValues(alpha: 0.3)),
          ),
          title: Text(
            'Imprint what weighs on you',
            style: AppTextStyles.hero.copyWith(
              fontSize: 22,
              color: AppColors.paper,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Type a word, worry, or memory to trap inside the crystal before breaking it.',
                style: AppTextStyles.body.copyWith(
                  fontSize: 13,
                  color: AppColors.inkSoft,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _thoughtController,
                autofocus: true,
                maxLength: 28,
                style: AppTextStyles.hero.copyWith(
                  color: AppColors.glassBlue,
                  fontSize: 18,
                ),
                decoration: InputDecoration(
                  counterStyle: AppTextStyles.eyebrow.copyWith(
                    color: AppColors.paper.withValues(alpha: 0.4),
                  ),
                  hintText: 'e.g., Burnout, Anxiety, Heavy heart',
                  hintStyle: AppTextStyles.body.copyWith(
                    color: AppColors.inkSoft.withValues(alpha: 0.5),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.glassBlue.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.glassBlue),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() => _imprintedThought = '');
                _thoughtController.clear();
                Navigator.pop(ctx);
              },
              child: Text(
                'Clear',
                style: AppTextStyles.eyebrow.copyWith(color: AppColors.inkSoft),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                setState(
                  () => _imprintedThought = _thoughtController.text.trim(),
                );
                Navigator.pop(ctx);
              },
              child: Text(
                'Imprint',
                style: AppTextStyles.button.copyWith(fontSize: 14),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _detonate() async {
    if (_isExploding || !mounted) return;
    _hapticLoop?.cancel();

    setState(() => _isExploding = true);

    await HapticService.heavyPulse();
    if (_soundEnabled) {
      unawaited(SoundService.playGlassRelease());
    }

    await _shatterController.forward();
    if (!mounted) return;

    await _flashController.forward();
    if (!mounted) return;

    await _dayGuard.markUsed();
    if (!mounted) return;

    await Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) =>
            ClosureScreen(dissolvedThought: _imprintedThought),
        transitionsBuilder: (_, animation, _, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 650),
      ),
    );

    if (mounted) {
      _flashController.reset();
      _shatterController.reset();
      _pressureController.reset();
      setState(() {
        _isExploding = false;
        _swipeEnergy = 0.0;
        _imprintedThought = '';
        _thoughtController.clear();
      });
      _checkDayGuard();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.height < 740;

    return Scaffold(
      backgroundColor: AppColors.ink,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          const Positioned.fill(child: ColoredBox(color: AppColors.ink)),

          Positioned(
            top: -100 + (TiltService.tiltY * 30),
            right: -90 - (TiltService.tiltX * 30),
            child: IgnorePointer(
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accent.withValues(alpha: .24),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          const Positioned.fill(
            child: FloatingDust(
              particleCount: 16,
              maxOpacity: 0.14,
              color: AppColors.accentSoft,
            ),
          ),

          const Positioned.fill(child: FilmGrain(opacity: 0.035)),

          const Positioned.fill(child: SoftVignette(intensity: 1.15)),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, compact ? 12 : 20),
              child: Column(
                children: [
                  _buildHeader(),
                  SizedBox(height: compact ? 10 : 18),
                  _buildTitleBlock(compact),
                  const Spacer(),
                  _buildSphere(compact),
                  const Spacer(),
                  _buildImprintButton(),
                  const SizedBox(height: 10),
                  _buildButton(),
                  const SizedBox(height: 10),
                  Text(
                    _canUseToday
                        ? 'No rush. Just when you’re ready.'
                        : 'Ritual complete for today. Be kind to yourself.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.eyebrow.copyWith(
                      color: AppColors.paper.withValues(alpha: .42),
                      fontSize: 8.5,
                      letterSpacing: .6,
                    ),
                  ),
                ],
              ),
            ),
          ),

          AnimatedBuilder(
            animation: _flashController,
            builder: (context, _) {
              if (_flashController.value == 0) return const SizedBox.shrink();
              return Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: Colors.white.withValues(
                      alpha: (1.0 - _flashController.value).clamp(0.0, 1.0),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: .18),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.glassBlue.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.blur_on_rounded,
            color: AppColors.glassBlue,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'ENOUGH',
          style: AppTextStyles.eyebrow.copyWith(
            color: AppColors.paper.withValues(alpha: .85),
            letterSpacing: 2.2,
          ),
        ),
        const Spacer(),
        Text(
          _imprintedThought.isNotEmpty ? 'IMPRINTED' : 'THE LIVING CRYSTAL',
          style: AppTextStyles.eyebrow.copyWith(
            color: _imprintedThought.isNotEmpty
                ? AppColors.glassBlue
                : AppColors.paper.withValues(alpha: .44),
            fontSize: 8.5,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          tooltip: _soundEnabled ? 'Mute sound' : 'Turn sound on',
          onPressed: () => setState(() => _soundEnabled = !_soundEnabled),
          icon: Icon(
            _soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
            color: AppColors.paper.withValues(alpha: .75),
            size: 19,
          ),
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints.tightFor(width: 34, height: 34),
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildTitleBlock(bool compact) {
    return AnimatedBuilder(
      animation: _pressureController,
      builder: (context, _) {
        final p = _pressureController.value;
        final title = p > 0.75
            ? 'Let go.'
            : p > 0.35
            ? 'It is enough.'
            : 'What are you carrying?';

        final subtitle = p > 0.1
            ? 'Hold tight or strike through to shatter it.'
            : _imprintedThought.isNotEmpty
            ? 'Your burden is locked inside. Shatter it now.'
            : 'Tilt your device. Press to dent. Swipe to strike.';

        return Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.hero.copyWith(
                color: AppColors.paper,
                fontSize: compact ? 32 : 38,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: AppColors.paper.withValues(alpha: .64),
                fontSize: 14,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSphere(bool compact) {
    final sphereDiameter = compact ? 220.0 : 255.0;

    return Center(
      child: SizedBox(
        width: sphereDiameter,
        height: sphereDiameter,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final canvasSize = Size(
              constraints.maxWidth,
              constraints.maxHeight,
            );
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (d) => _onPressStart(d.localPosition, canvasSize),
              onTapUp: (_) => _onPressEnd(),
              onTapCancel: _onPressEnd,
              onPanStart: (d) => _onPressStart(d.localPosition, canvasSize),
              onPanUpdate: _onPanUpdate,
              onPanEnd: (_) => _onPressEnd(),
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _breatheController,
                  _pressureController,
                  _shatterController,
                ]),
                builder: (context, _) => CustomPaint(
                  size: canvasSize,
                  painter: _LivingCrystalPainter(
                    breathe: _breatheController.value,
                    pressure: _pressureController.value,
                    shatter: _isExploding ? _shatterController.value : 0.0,
                    touchPoint: _touchPoint,
                    indent: _indentDepth,
                    tiltX: TiltService.tiltX,
                    tiltY: TiltService.tiltY,
                    imprintedThought: _imprintedThought,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildImprintButton() {
    return GestureDetector(
      onTap: _openThoughtDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _imprintedThought.isNotEmpty
              ? AppColors.glassBlue.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _imprintedThought.isNotEmpty
                ? AppColors.glassBlue.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _imprintedThought.isNotEmpty
                  ? Icons.lock_outline_rounded
                  : Icons.edit_note_rounded,
              color: _imprintedThought.isNotEmpty
                  ? AppColors.glassBlue
                  : AppColors.paperLight,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              _imprintedThought.isNotEmpty
                  ? 'Trapped: "$_imprintedThought"'
                  : 'Imprint a burden into crystal...',
              style: AppTextStyles.eyebrow.copyWith(
                color: _imprintedThought.isNotEmpty
                    ? AppColors.glassBlue
                    : AppColors.paperLight,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton() {
    return AnimatedBuilder(
      animation: _pressureController,
      builder: (context, _) {
        final p = _pressureController.value;
        return HeavyButton(
          label: p > 0.05 ? 'Release fully' : 'Shatter gently',
          onConfirm: _detonate,
        );
      },
    );
  }
}

class _LivingCrystalPainter extends CustomPainter {
  final double breathe;
  final double pressure;
  final double shatter;
  final Offset touchPoint;
  final double indent;
  final double tiltX;
  final double tiltY;
  final String imprintedThought;

  _LivingCrystalPainter({
    required this.breathe,
    required this.pressure,
    required this.shatter,
    required this.touchPoint,
    required this.indent,
    required this.tiltX,
    required this.tiltY,
    required this.imprintedThought,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width * 0.42;

    if (shatter > 0) {
      _paintExplodingShards(canvas, center, baseRadius, shatter);
      return;
    }

    final jitter = pressure > 0.5
        ? (math.sin(DateTime.now().millisecondsSinceEpoch * 0.06) *
              pressure *
              2.8)
        : 0.0;
    final r =
        baseRadius * (1.0 + (breathe * 0.05) + (pressure * 0.06)) + jitter;

    final glowShift = Offset(-tiltX * 18, -tiltY * 18);
    final haloRadius = r * (1.35 + (breathe * 0.15) + (pressure * 0.25));
    final haloColor = Color.lerp(
      AppColors.orbGlow.withValues(alpha: 0.16 + breathe * 0.08),
      AppColors.orbHot.withValues(alpha: 0.42),
      pressure,
    )!;

    canvas.drawCircle(
      center + glowShift,
      haloRadius,
      Paint()
        ..color = haloColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 38),
    );

    final touchCenter = Offset(
      center.dx + (touchPoint.dx - 0.5) * r * 1.5,
      center.dy + (touchPoint.dy - 0.5) * r * 1.5,
    );

    final Path bodyPath = Path();
    const steps = 40;
    for (int i = 0; i <= steps; i++) {
      final angle = (i * 2 * math.pi / steps);
      var currentR = r;

      if (indent > 0) {
        final pointOnCirc =
            center + Offset(math.cos(angle) * r, math.sin(angle) * r);
        final distToTouch = (pointOnCirc - touchCenter).distance;
        if (distToTouch < r * 0.7) {
          final dentFactor = (1.0 - (distToTouch / (r * 0.7))) * 12.0 * indent;
          currentR -= dentFactor;
        }
      }

      final pt =
          center +
          Offset(math.cos(angle) * currentR, math.sin(angle) * currentR);
      if (i == 0) {
        bodyPath.moveTo(pt.dx, pt.dy);
      } else {
        bodyPath.lineTo(pt.dx, pt.dy);
      }
    }
    bodyPath.close();

    final sphereRect = Rect.fromCircle(center: center, radius: r);
    final coreGradient = RadialGradient(
      center: Alignment(-0.35 + (tiltX * 0.4), -0.38 + (tiltY * 0.4)),
      radius: 0.95,
      colors: [
        Colors.white.withValues(alpha: 0.94),
        Color.lerp(AppColors.glassBlue, AppColors.orbCore, 0.45)!,
        Color.lerp(AppColors.accent, AppColors.orbHot, pressure)!,
        AppColors.ink,
      ],
      stops: const [0.0, 0.32, 0.72, 1.0],
    );

    canvas.drawPath(
      bodyPath,
      Paint()..shader = coreGradient.createShader(sphereRect),
    );

    canvas.save();
    canvas.clipPath(bodyPath);

    if (imprintedThought.isNotEmpty) {
      final textSpan = TextSpan(
        text: imprintedThought,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.75 - (pressure * 0.4)),
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 2.0,
          shadows: [
            Shadow(color: Colors.black.withValues(alpha: 0.8), blurRadius: 10),
            Shadow(
              color: AppColors.glassBlue.withValues(alpha: 0.5),
              blurRadius: 15,
            ),
          ],
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: r * 1.5);

      final textOffset = Offset(
        center.dx - (textPainter.width / 2) + (tiltX * 12),
        center.dy - (textPainter.height / 2) + (tiltY * 12),
      );
      textPainter.paint(canvas, textOffset);
    }

    final specularOffset = Offset(
      center.dx + (-tiltX * r * 0.45) - 20,
      center.dy + (-tiltY * r * 0.45) - 20,
    );
    canvas.drawCircle(
      specularOffset,
      r * 0.38,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.22 + (breathe * 0.08))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );

    if (pressure > 0.05) {
      _paintDynamicCracks(canvas, touchCenter, r, pressure);
    }

    canvas.restore();

    canvas.drawPath(
      bodyPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.7
        ..color = Colors.white.withValues(alpha: 0.65 + (pressure * 0.35)),
    );
  }

  void _paintDynamicCracks(
    Canvas canvas,
    Offset impact,
    double radius,
    double progress,
  ) {
    final crackPaint = Paint()
      ..color = const Color(0xFFEAFBFF)
      ..strokeWidth = 1.9
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.65)
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const crackCount = 10;
    for (int i = 0; i < crackCount; i++) {
      final angle = (i * 2 * math.pi / crackCount) + (i.isEven ? 0.15 : -0.12);
      final length = radius * 1.15 * progress;
      final end =
          impact + Offset(math.cos(angle) * length, math.sin(angle) * length);

      final bend1 =
          Offset.lerp(impact, end, 0.35)! +
          Offset(
            math.sin(i * 4.0) * 8 * progress,
            math.cos(i * 3.0) * 8 * progress,
          );
      final bend2 =
          Offset.lerp(impact, end, 0.7)! -
          Offset(
            math.sin(i * 5.0) * 6 * progress,
            math.cos(i * 2.0) * 6 * progress,
          );

      final crack = Path()
        ..moveTo(impact.dx, impact.dy)
        ..lineTo(bend1.dx, bend1.dy)
        ..lineTo(bend2.dx, bend2.dy)
        ..lineTo(end.dx, end.dy);

      canvas.drawPath(crack, shadowPaint);
      canvas.drawPath(crack.shift(const Offset(-0.6, -0.6)), crackPaint);

      if (i % 2 == 0 && progress > 0.4) {
        final bStart = bend1;
        final bEnd =
            bStart +
            Offset(
              math.cos(angle + 0.8) * 24 * progress,
              math.sin(angle + 0.8) * 24 * progress,
            );
        canvas.drawLine(bStart, bEnd, shadowPaint..strokeWidth = 1.2);
        canvas.drawLine(bStart, bEnd, crackPaint..strokeWidth = 0.9);
      }
    }
  }

  void _paintExplodingShards(
    Canvas canvas,
    Offset center,
    double radius,
    double progress,
  ) {
    const shardCount = 28;
    final fade = (1.0 - progress).clamp(0.0, 1.0);
    final travel = radius * 2.0 * Curves.easeOutCubic.transform(progress);

    for (int i = 0; i < shardCount; i++) {
      final angle = (i * 2 * math.pi / shardCount) + (i.isEven ? 0.08 : -0.06);
      final dist = (radius * 0.22) + (travel * (0.75 + (i % 4) * 0.16));

      final shardCenter =
          center + Offset(math.cos(angle) * dist, math.sin(angle) * dist);

      final w = 12.0 + (i % 3) * 6.0;
      final h = 18.0 + (i % 4) * 8.0;

      final shard = Path()
        ..moveTo(-w * 0.4, -h * 0.5)
        ..lineTo(w * 0.5, -h * 0.3)
        ..lineTo(w * 0.3, h * 0.45)
        ..lineTo(-w * 0.45, h * 0.25)
        ..close();

      canvas.save();
      canvas.translate(shardCenter.dx, shardCenter.dy);
      canvas.rotate(angle + progress * (i.isEven ? 0.95 : -0.85));

      canvas.drawPath(
        shard,
        Paint()
          ..color = (i.isEven ? AppColors.glassBlue : AppColors.glassLilac)
              .withValues(alpha: 0.55 * fade),
      );

      canvas.drawPath(
        shard,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.3
          ..color = Colors.white.withValues(alpha: 0.92 * fade),
      );
      canvas.restore();
    }

    final shockwaveR = radius * (0.8 + progress * 2.3);
    canvas.drawCircle(
      center,
      shockwaveR,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0 * fade
        ..color = Colors.white.withValues(alpha: 0.65 * fade),
    );
  }

  @override
  bool shouldRepaint(covariant _LivingCrystalPainter oldDelegate) => true;
}
