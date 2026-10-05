import 'package:flutter/services.dart';

class HapticService {
  static Future<void> init() async {}

  static Future<void> heavyPulse() async {
    await HapticFeedback.heavyImpact();

    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.heavyImpact();
  }

  static Future<void> subtle() async {
    await HapticFeedback.lightImpact();
  }

  static Future<void> selection() async {
    await HapticFeedback.selectionClick();
  }
}
