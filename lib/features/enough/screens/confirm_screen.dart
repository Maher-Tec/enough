import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_durations.dart';
import '../../../core/services/day_guard_service.dart';
import '../widgets/soft_vignette.dart';
import '../widgets/heavy_button.dart';
import '../widgets/floating_dust.dart';
import 'closure_screen.dart';

/// ENOUGH — Confirm Screen
/// 
/// ACCESSIBILITY: Button labeled for screen readers
class ConfirmScreen extends StatefulWidget {
  final DayGuardService dayGuard;
  
  const ConfirmScreen({
    super.key,
    required this.dayGuard,
  });

  @override
  State<ConfirmScreen> createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends State<ConfirmScreen>
    with TickerProviderStateMixin {
  
  late AnimationController _phaseController;
  late Animation<double> _haloFade;
  late Animation<double> _buttonFade;
  
  late AnimationController _breathController;
  late Animation<double> _breathAnimation;

  @override
  void initState() {
    super.initState();
    
    _phaseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200), // Slower arrival
    );
    
    _haloFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _phaseController,
        curve: const Interval(0.20, 0.65, curve: AppDurations.organic),
      ),
    );
    
    _buttonFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _phaseController,
        curve: const Interval(0.35, 1.0, curve: AppDurations.organic),
      ),
    );
    
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat(reverse: true);
    
    _breathAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _breathController,
        curve: Curves.easeInOut,
      ),
    );
    
    _phaseController.forward();
  }

  @override
  void dispose() {
    _phaseController.dispose();
    _breathController.dispose();
    super.dispose();
  }

  Future<void> _onConfirm() async {
    await widget.dayGuard.markUsed();
    
    if (!mounted) return;
    
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) {
          return const ClosureScreen();
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
        transitionDuration: const Duration(milliseconds: 900),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Semantics(
        label: 'Confirm screen. Press the ENOUGH button to confirm you are done for today.',
        child: AnimatedBuilder(
          animation: _breathAnimation,
          builder: (context, child) {
            final breath = _breathAnimation.value;
            
            return Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, 0.05 + (breath * 0.03)),
                  radius: 1.3 + (breath * 0.1),
                  colors: [
                    AppColors.backgroundWarm,
                    AppColors.backgroundPrimary,
                    AppColors.backgroundPrimary,
                  ],
                  stops: const [0.0, 0.5, 1.0],
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
                child: SoftVignette(intensity: 0.8),
              ),
              
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: Listenable.merge([_haloFade, _breathAnimation]),
                  builder: (context, child) {
                    return Align(
                      alignment: const Alignment(0, 0.08),
                      child: Container(
                        width: 350,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentWarm.withValues(
                                alpha: _haloFade.value * (0.10 + (_breathAnimation.value * 0.04)),
                              ),
                              blurRadius: 50,
                              spreadRadius: 15,
                            ),
                            BoxShadow(
                              color: AppColors.accentGlow.withValues(
                                alpha: _haloFade.value * (0.06 + (_breathAnimation.value * 0.03)),
                              ),
                              blurRadius: 100 + (_breathAnimation.value * 25),
                              spreadRadius: 45,
                            ),
                          ],
                        ),
                      ),
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
                        const Spacer(flex: 58), // 3️⃣ Human Alignment: Slightly below center
                        
                        FadeTransition(
                          opacity: _buttonFade,
                          child: Semantics(
                            button: true,
                            label: 'ENOUGH. Press and hold to confirm.',
                            child: HeavyButton(
                              onConfirm: _onConfirm,
                            ),
                          ),
                        ),
                        
                        const Spacer(flex: 42),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
