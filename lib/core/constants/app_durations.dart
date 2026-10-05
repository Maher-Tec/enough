import 'package:flutter/animation.dart';

/// ENOUGH — Duration Constants
/// 
/// V3 Update: Introducing Organic Curves.
/// Transitions now have mass and momentum.
abstract class AppDurations {
  // Screen transitions
  static const Duration entryFade = Duration(milliseconds: 1400); // Slightly slower
  static const Duration exitFade = Duration(milliseconds: 800);
  
  // Interactions
  static const Duration buttonResistance = Duration(milliseconds: 600); // Matches haptic rising
  static const Duration closureHold = Duration(milliseconds: 2000);
  
  // Premium micro-animations
  static const Duration textFade = Duration(milliseconds: 1000);
  static const Duration backgroundShift = Duration(milliseconds: 1500);
  static const Duration glowPulse = Duration(milliseconds: 2500);
  
  // Soul Infusion Ritual Phases (Entry Screen)
  static const Duration ritualSilence = Duration(milliseconds: 700);
  static const Duration ritualBrighten = Duration(milliseconds: 700);
  static const Duration ritualTextFade = Duration(milliseconds: 400);
  
  // Organic Curves
  // A curve that feels like it has weight - smooth start, slow settling.
  static const Curve organic = Cubic(0.2, 0.0, 0.0, 1.0); 
  
  // Spring-like behavior without the bounce (critically damped)
  static const Curve spring = Curves.fastOutSlowIn;
  
  // Standard allowed curves
  static const Curve primary = organic;
  static const Curve subtle = Curves.easeOutQuart;
  static const Curve slow = Curves.easeInOutQuart;

  // Ritual phases
  static const Duration orbBreathe = Duration(milliseconds: 3200);
  static const Duration orbBuildUp = Duration(milliseconds: 2500);
  static const Duration glassAppear = Duration(milliseconds: 800);
  static const Duration whiteFlash = Duration(milliseconds: 500);
  static const Duration breatheCycle = Duration(milliseconds: 4000);
}
