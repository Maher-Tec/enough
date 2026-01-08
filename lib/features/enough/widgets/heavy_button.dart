import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_durations.dart';
import '../../../core/services/haptic_service.dart';

/// ENOUGH — Heavy Button
/// 
/// Premium polish:
/// - Inner shadow before press (depth)
/// - 2-3px compression on press (physicality)
/// - Haptic Rising: Pressure builds on hold
/// - Glow tightens inward on press (not brighter)
class HeavyButton extends StatefulWidget {
  final VoidCallback onConfirm;
  final String label;
  
  const HeavyButton({
    super.key,
    required this.onConfirm,
    this.label = 'ENOUGH',
  });

  @override
  State<HeavyButton> createState() => _HeavyButtonState();
}

class _HeavyButtonState extends State<HeavyButton> 
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  bool _isProcessing = false;
  
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  
  Timer? _risingHapticTimer;
  int _holdCount = 0;
  final int _threshold = 8; // ~600ms building (8 * 75ms)

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: AppDurations.glowPulse,
    )..repeat(reverse: true);
    
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    _risingHapticTimer?.cancel();
    super.dispose();
  }

  void _startRisingHaptics() {
    _holdCount = 0;
    _risingHapticTimer = Timer.periodic(const Duration(milliseconds: 75), (timer) {
      if (!_isPressed || _isProcessing) {
        timer.cancel();
        return;
      }
      
      _holdCount++;
      
      // Gradually increase haptic weight
      if (_holdCount < 3) {
        HapticService.selection();
      } else if (_holdCount < 6) {
        HapticService.subtle();
      } else if (_holdCount < _threshold) {
        // Build-up pulses
        HapticService.subtle();
      } else {
        // Threshold met!
        timer.cancel();
        _triggerConfirm();
      }
    });
  }

  Future<void> _triggerConfirm() async {
    if (_isProcessing) return;
    
    setState(() {
      _isPressed = false;
      _isProcessing = true;
    });
    
    // Brief weight delay before the final pulse (Resistance)
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Final deep haptic burst
    await HapticService.heavyPulse();
    
    // Action fires
    widget.onConfirm();
  }

  void _handleTapDown(TapDownDetails details) {
    if (_isProcessing) return;
    
    setState(() => _isPressed = true);
    HapticService.subtle();
    _startRisingHaptics();
  }

  void _handleTapUp(TapUpDetails details) {
    if (_isProcessing) return;
    
    // Stop the rising haptics and trigger the confirmation
    _risingHapticTimer?.cancel();
    _triggerConfirm();
  }

  void _handleTapCancel() {
    if (_isProcessing) return;
    _cancelHold();
  }
  
  void _cancelHold() {
    _risingHapticTimer?.cancel();
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          // Glow tightens inward (not brighter)
          final glowBlur = _isPressed ? 12.0 : 30 + (_glowAnimation.value * 15);
          final glowSpread = _isPressed ? -10.0 : -3.0;
          final outerBlur = _isPressed ? 15.0 : 50 + (_glowAnimation.value * 20);
          
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: AppDurations.spring,
            // 2px compression on press
            transform: _isPressed 
              ? (Matrix4.translationValues(0.0, 2.0, 0.0))
              : Matrix4.identity(),
            transformAlignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 52,
                vertical: 22,
              ),
              decoration: BoxDecoration(
                color: AppColors.backgroundDepth,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.accentGlow.withValues(
                    alpha: _isPressed 
                      ? 0.18 // Subtle highlight
                      : 0.12 + (_glowAnimation.value * 0.08),
                  ),
                  width: 1.5,
                ),
                boxShadow: [
                  // Inner shadow for depth
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: _isPressed ? 0.6 : 0.4,
                    ),
                    blurRadius: _isPressed ? 2 : 10,
                    spreadRadius: -2,
                    offset: Offset(0, _isPressed ? 1 : 4),
                  ),
                  // Warm inner glow - tightens on press
                  BoxShadow(
                    color: AppColors.candlelight.withValues(
                      alpha: 0.03 + (_glowAnimation.value * 0.03),
                    ),
                    blurRadius: glowBlur,
                    spreadRadius: glowSpread,
                  ),
                  // Outer ambient glow - reduces on press
                  BoxShadow(
                    color: AppColors.accentGlow.withValues(
                      alpha: _isPressed ? 0.01 : 0.03 + (_glowAnimation.value * 0.02),
                    ),
                    blurRadius: outerBlur,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Text(
                widget.label,
                style: AppTextStyles.button.copyWith(
                  color: AppColors.primaryText.withValues(
                    alpha: _isPressed ? 0.75 : 0.88,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
