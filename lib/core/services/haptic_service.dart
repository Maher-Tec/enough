import 'package:flutter/services.dart';

/// ENOUGH — Haptic Feedback Service
/// 
/// Heavy moments feel resistant, not reactive.
/// Uses Flutter's built-in HapticFeedback - no external dependencies.
class HapticService {
  /// Initialize (no-op, kept for API consistency)
  static Future<void> init() async {
    // No initialization needed for built-in haptics
  }
  
  /// Heavy  pulse - used for the ENOUGH button
  /// Single deep vibration that feels weighty
  static Future<void> heavyPulse() async {
    await HapticFeedback.heavyImpact();
    // Double tap for extra weight on supported devices
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.heavyImpact();
  }
  
  /// Subtle feedback - minimal acknowledgment
  static Future<void> subtle() async {
    await HapticFeedback.lightImpact();
  }
  
  /// Selection feedback - very light
  static Future<void> selection() async {
    await HapticFeedback.selectionClick();
  }
}
