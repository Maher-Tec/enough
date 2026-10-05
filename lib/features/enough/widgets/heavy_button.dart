import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Clear, one-tap action with a soft pressed state and a large touch target.
class HeavyButton extends StatefulWidget {
  final VoidCallback onConfirm;
  final String label;

  const HeavyButton({
    super.key,
    required this.onConfirm,
    this.label = 'Continue',
  });

  @override
  State<HeavyButton> createState() => _HeavyButtonState();
}

class _HeavyButtonState extends State<HeavyButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: widget.label,
    child: AnimatedScale(
      scale: _pressed ? .985 : 1,
      duration: const Duration(milliseconds: 130),
      curve: Curves.easeOut,
      child: SizedBox(
        width: double.infinity,
        height: 62,
        child: Material(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: widget.onConfirm,
            onHighlightChanged: (value) => setState(() => _pressed = value),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.label, style: AppTextStyles.button),
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.paperLight,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
