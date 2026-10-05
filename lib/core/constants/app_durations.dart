import 'package:flutter/animation.dart';

abstract class AppDurations {
  static const Duration entryFade = Duration(milliseconds: 1400);
  static const Duration exitFade = Duration(milliseconds: 800);

  static const Duration buttonResistance = Duration(milliseconds: 600);
  static const Duration closureHold = Duration(milliseconds: 2000);

  static const Duration textFade = Duration(milliseconds: 1000);
  static const Duration backgroundShift = Duration(milliseconds: 1500);
  static const Duration glowPulse = Duration(milliseconds: 2500);

  static const Duration ritualSilence = Duration(milliseconds: 700);
  static const Duration ritualBrighten = Duration(milliseconds: 700);
  static const Duration ritualTextFade = Duration(milliseconds: 400);

  static const Curve organic = Cubic(0.2, 0.0, 0.0, 1.0);

  static const Curve spring = Curves.fastOutSlowIn;

  static const Curve primary = organic;
  static const Curve subtle = Curves.easeOutQuart;
  static const Curve slow = Curves.easeInOutQuart;

  static const Duration orbBreathe = Duration(milliseconds: 3200);
  static const Duration orbBuildUp = Duration(milliseconds: 2500);
  static const Duration glassAppear = Duration(milliseconds: 800);
  static const Duration whiteFlash = Duration(milliseconds: 500);
  static const Duration breatheCycle = Duration(milliseconds: 4000);
}
