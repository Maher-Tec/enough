import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';

class TiltService {
  static double tiltX = 0.0;
  static double tiltY = 0.0;
  static StreamSubscription<AccelerometerEvent>? _sub;

  static void start() {
    try {
      _sub = accelerometerEventStream().listen((event) {
        final targetX = (event.x / 9.81).clamp(-1.0, 1.0);
        final targetY = (event.y / 9.81).clamp(-1.0, 1.0);
        tiltX = tiltX * 0.85 + targetX * 0.15;
        tiltY = tiltY * 0.85 + targetY * 0.15;
      }, onError: (_) {});
    } catch (_) {}
  }

  static void stop() {
    _sub?.cancel();
    _sub = null;
  }
}
