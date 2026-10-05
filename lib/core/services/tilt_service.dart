import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';

/// Service to track device tilt with smooth low-pass filtering.
/// Gracefully falls back to zero tilt on unsupported platforms or emulators.
class TiltService {
  static double tiltX = 0.0;
  static double tiltY = 0.0;
  static StreamSubscription<AccelerometerEvent>? _sub;

  static void start() {
    try {
      _sub = accelerometerEventStream().listen((event) {
        // Low-pass filter (smooth out jerkiness)
        final targetX = (event.x / 9.81).clamp(-1.0, 1.0);
        final targetY = (event.y / 9.81).clamp(-1.0, 1.0);
        tiltX = tiltX * 0.85 + targetX * 0.15;
        tiltY = tiltY * 0.85 + targetY * 0.15;
      }, onError: (_) {
        // Silent fallback for simulator / devices without accelerometer
      });
    } catch (_) {
      // Fallback
    }
  }

  static void stop() {
    _sub?.cancel();
    _sub = null;
  }
}
