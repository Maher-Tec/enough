import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_durations.dart';
import '../../../core/services/sound_service.dart';
import '../widgets/soft_vignette.dart';
import '../widgets/floating_dust.dart';

/// ENOUGH — Closure Screen
/// 
/// DEEP STILLNESS:
/// - After 5 minutes, the app fades to 100% black.
/// - A nudge to put the device away and rest.
class ClosureScreen extends StatefulWidget {
  const ClosureScreen({super.key});

  @override
  State<ClosureScreen> createState() => _ClosureScreenState();
}

class _ClosureScreenState extends State<ClosureScreen>
    with TickerProviderStateMixin {
  
  late AnimationController _phaseController;
  late Animation<double> _warmth;
  late Animation<double> _haloFade;
  late Animation<double> _haloGrow;
  late Animation<double> _textFade;
  
  late AnimationController _breathController;
  late Animation<double> _breathAnimation;
  
  // Deep Stillness
  Timer? _stillnessTimer;
  bool _isDeepStillness = false;

  @override
  void initState() {
    super.initState();
    
    // Total duration for arrival:
    // 1200ms initial silence + 800ms fade = 2000ms
    _phaseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    
    _warmth = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _phaseController,
        curve: const Interval(0.0, 0.50, curve: AppDurations.organic),
      ),
    );
    
    _haloFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _phaseController,
        curve: const Interval(0.50, 0.90, curve: AppDurations.organic),
      ),
    );
    
    _haloGrow = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _phaseController,
        curve: const Interval(0.50, 1.0, curve: AppDurations.organic),
      ),
    );
    
    // Text fades in after 1200ms
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _phaseController,
        curve: const Interval(0.60, 1.0, curve: Curves.easeIn), // 1200/2000
      ),
    );
    
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 45), // Subconscious breathing
    )..repeat(reverse: true);
    
    _breathAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _breathController,
        curve: Curves.easeInOut,
      ),
    );
    
    _phaseController.forward();
    _playChime();
    
    // START DEEP STILLNESS TIMER (5 minutes)
    _startDeepStillnessTimer();
  }
  
  void _startDeepStillnessTimer() {
    _stillnessTimer = Timer(const Duration(minutes: 5), () {
      if (mounted) {
        setState(() => _isDeepStillness = true);
      }
    });
  }

  Future<void> _playChime() async {
    // Chime plays only when text is nearly visible
    await Future.delayed(const Duration(milliseconds: 1400));
    await SoundService.playClosureChime();
  }

  @override
  void dispose() {
    _phaseController.dispose();
    _breathController.dispose();
    _stillnessTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // MAIN CONTENT
          AnimatedOpacity(
            opacity: _isDeepStillness ? 0.0 : 1.0,
            duration: const Duration(seconds: 10),
            curve: Curves.easeInOut,
            child: AnimatedBuilder(
              animation: Listenable.merge([_warmth, _breathAnimation]),
              builder: (context, child) {
                final warmth = _warmth.value;
                final breath = _breathAnimation.value;
                
                return Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(0, -0.08 + (breath * 0.03)),
                      radius: 1.4,
                      colors: [
                        Color.lerp(
                          AppColors.backgroundDepth,
                          AppColors.backgroundWarm,
                          warmth * 0.7,
                        )!,
                        Color.lerp(
                          AppColors.backgroundPrimary,
                          AppColors.ambientWarm,
                          warmth * 0.4,
                        )!,
                        AppColors.backgroundPrimary,
                      ],
                      stops: [0.0, 0.35 + (warmth * 0.1), 1.0],
                    ),
                  ),
                  child: child,
                );
              },
              child: Stack(
                children: [
                  const Positioned.fill(
                    child: FloatingDust(
                      particleCount: 10,
                      maxOpacity: 0.12,
                    ),
                  ),
                  
                  const Positioned.fill(
                    child: SoftVignette(intensity: 0.6),
                  ),
                  
                  // Halos & Core Glow
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: Listenable.merge([_haloFade, _haloGrow, _breathAnimation]),
                      builder: (context, child) {
                        final haloVal = _haloFade.value;
                        return Stack(
                          children: [
                            // 6️⃣ WARM CORE (Safety Signal)
                            Align(
                              alignment: const Alignment(0, -0.12),
                              child: Container(
                                width: 350,
                                height: 350,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      AppColors.candlelight.withValues(alpha: 0.05 * haloVal),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Halos
                            Align(
                              alignment: const Alignment(0, -0.12),
                              child: Transform.scale(
                                scale: _haloGrow.value,
                                child: Container(
                                  width: 500,
                                  height: 320,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(160),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.accentWarm.withValues(
                                          alpha: haloVal * (0.12 + (_breathAnimation.value * 0.05)),
                                        ),
                                        blurRadius: 50,
                                        spreadRadius: 15,
                                      ),
                                      BoxShadow(
                                        color: AppColors.accentGlow.withValues(
                                          alpha: haloVal * (0.08 + (_breathAnimation.value * 0.03)),
                                        ),
                                        blurRadius: 100 + (_breathAnimation.value * 20),
                                        spreadRadius: 40,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  
                  Positioned.fill(
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48),
                        child: Column(
                          children: [
                            const Spacer(flex: 42),
                            
                            FadeTransition(
                              opacity: _textFade,
                              child: Text(
                                'It was enough.',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.closure,
                              ),
                            ),
                            
                            const Spacer(flex: 58),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          Positioned.fill(
            child: Semantics(
              label: 'It was enough. You are done for today. Rest well.',
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }
}
