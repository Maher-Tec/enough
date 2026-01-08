import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_durations.dart';
import '../../../core/services/day_guard_service.dart';
import '../widgets/soft_vignette.dart';
import '../widgets/floating_dust.dart';
import 'confirm_screen.dart';

/// ENOUGH — Entry Screen
/// 
/// HOME FEELING + ACCESSIBILITY:
/// - Warm ambient glow
/// - Semantics for screen readers
/// - Lora font for literary feel
class EntryScreen extends StatefulWidget {
  final DayGuardService dayGuard;
  
  const EntryScreen({
    super.key,
    required this.dayGuard,
  });

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> 
    with TickerProviderStateMixin {
  
  late AnimationController _phaseController;
  late Animation<double> _backgroundWarmth;
  late Animation<double> _textFade;
  late Animation<double> _haloFade;
  late Animation<double> _haloGrow;
  
  late AnimationController _breathController;
  late Animation<double> _breathAnimation;
  
  bool _canUse = true;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    
    // Total duration for the soul infusion sequence:
    // 700ms (silence) + 700ms (brighten) + 400ms (text fade) = 1800ms
    _phaseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    
    // 700-1400ms: background subtly brightens
    _backgroundWarmth = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _phaseController,
        curve: const Interval(0.38, 0.77, curve: AppDurations.organic), // 700/1800 to 1400/1800
      ),
    );
    
    // Halos appear with warmth
    _haloFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _phaseController,
        curve: const Interval(0.40, 0.85, curve: AppDurations.organic),
      ),
    );
    
    _haloGrow = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _phaseController,
        curve: const Interval(0.40, 0.90, curve: AppDurations.organic),
      ),
    );
    
    // 1400ms: text fades in slowly (400ms)
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _phaseController,
        curve: const Interval(0.77, 1.0, curve: Curves.easeIn), // 1400/1800 to end
      ),
    );
    
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 45), // Subconscious breathing (45s)
    )..repeat(reverse: true);
    
    _breathAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _breathController,
        curve: Curves.easeInOut,
      ),
    );
    
    _checkCanUse();
  }

  Future<void> _checkCanUse() async {
    await widget.dayGuard.init();
    
    setState(() {
      _canUse = widget.dayGuard.canUseToday();
      _isReady = true;
    });
    
    _phaseController.forward();
  }

  @override
  void dispose() {
    _phaseController.dispose();
    _breathController.dispose();
    super.dispose();
  }

  void _proceed() {
    if (!_canUse || !_isReady) return;
    
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) {
          return ConfirmScreen(dayGuard: widget.dayGuard);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: AppDurations.primary,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 900), // Slightly slower arrival
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final message = _canUse 
        ? 'You can stop now.'
        : 'You already stopped today.';
    final semanticsLabel = _canUse
        ? 'You can stop now. Tap anywhere to continue.'
        : 'You already stopped today. Come back tomorrow.';
    
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Semantics(
        label: semanticsLabel,
        button: _canUse,
        child: GestureDetector(
          onTap: _canUse ? _proceed : null,
          behavior: HitTestBehavior.opaque,
          child: AnimatedBuilder(
            animation: Listenable.merge([_backgroundWarmth, _breathAnimation]),
            builder: (context, child) {
              final warmth = _backgroundWarmth.value;
              final breath = _breathAnimation.value;
              
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0, -0.1 + (breath * 0.04)), // Extremely slow drift
                    radius: 1.3 + (breath * 0.08),
                    colors: [
                      Color.lerp(
                        AppColors.backgroundDepth,
                        AppColors.backgroundWarm,
                        warmth * 0.6,
                      )!,
                      Color.lerp(
                        AppColors.backgroundPrimary,
                        AppColors.ambientWarm,
                        warmth * 0.3,
                      )!,
                      AppColors.backgroundPrimary,
                    ],
                    stops: [0.0, 0.4 + (warmth * 0.1), 1.0],
                  ),
                ),
                child: child,
              );
            },
            child: Stack(
              children: [
                const Positioned.fill(
                  child: FloatingDust(
                    particleCount: 12,
                    maxOpacity: 0.15,
                  ),
                ),
                
                const Positioned.fill(
                  child: SoftVignette(intensity: 0.7),
                ),
                
                // Halos & Core Glow
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: Listenable.merge([_haloFade, _haloGrow, _breathAnimation]),
                    builder: (context, child) {
                      final scale = _haloGrow.value;
                      final haloVal = _haloFade.value;
                      
                      return Stack(
                        children: [
                          // 6️⃣ WARM CORE (Safety Signal)
                          Align(
                            alignment: const Alignment(0, -0.16), // Human alignment (above center)
                            child: Container(
                              width: 300,
                              height: 300,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    AppColors.candlelight.withValues(alpha: 0.04 * haloVal),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Structural Halos
                          Align(
                            alignment: const Alignment(0, -0.16),
                            child: Transform.scale(
                              scale: scale,
                              child: Container(
                                width: 450,
                                height: 280,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(140),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.accentWarm.withValues(
                                        alpha: haloVal * (0.08 + (_breathAnimation.value * 0.04)),
                                      ),
                                      blurRadius: 60,
                                      spreadRadius: 20,
                                    ),
                                    BoxShadow(
                                      color: AppColors.accentGlow.withValues(
                                        alpha: haloVal * (0.05 + (_breathAnimation.value * 0.02)),
                                      ),
                                      blurRadius: 120 + (_breathAnimation.value * 30),
                                      spreadRadius: 50,
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
                          // 3️⃣ Human Alignment: Slightly above center (34/66 split)
                          const Spacer(flex: 34),
                          
                          AnimatedBuilder(
                            animation: _textFade,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _textFade.value,
                                child: child,
                              );
                            },
                            child: ExcludeSemantics(
                              child: Text(
                                message,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.entry,
                              ),
                            ),
                          ),
                          
                          const Spacer(flex: 66),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
