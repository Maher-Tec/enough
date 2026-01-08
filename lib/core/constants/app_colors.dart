import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ENOUGH — Color Constants
/// 
/// HOME FEELING: Warm. Cozy. Safe. Like late evening light.
abstract class AppColors {
  // Backgrounds - warmer, more amber undertones
  static const Color backgroundPrimary = Color(0xFF151210);  // Warm dark
  static const Color backgroundDepth = Color(0xFF1E1712);    // Warm brown
  static const Color backgroundWarm = Color(0xFF231A14);     // Cozy amber-brown
  
  // Text - cream with slight warmth
  static const Color primaryText = Color(0xFFF0E8D8);        // Warmer cream
  static const Color secondaryText = Color(0xFFA89B8C);      // Warm grey
  
  // Accent - richer amber/gold (more visible, more home-like)
  static const Color accentGlow = Color(0xFFD4A855);         // Richer gold
  static const Color accentWarm = Color(0xFFE8B860);         // Brighter amber for halos
  
  // Cozy ambient colors
  static const Color ambientWarm = Color(0xFF2A1E16);        // Warm shadow
  static const Color candlelight = Color(0xFFFFC864);        // Like candlelight
  
  // Derived colors with opacity for premium effects
  static Color get secondaryTextSubtle => secondaryText.withValues(alpha: 0.55);
  static Color get accentGlowSubtle => accentGlow.withValues(alpha: 0.10);
  static Color get accentGlowMedium => accentGlow.withValues(alpha: 0.18);
  
  // Vignette gradient - warmer edges
  static const List<Color> vignetteGradient = [
    Colors.transparent,
    Color(0x22100A06),  // Warm tint
    Color(0x66080504),  // Warm dark
  ];
  
  // Button glow gradient (premium)
  static List<Color> get buttonGlowGradient => [
    accentGlow.withValues(alpha: 0.0),
    accentGlow.withValues(alpha: 0.08),
    accentGlow.withValues(alpha: 0.15),
    accentGlow.withValues(alpha: 0.08),
    accentGlow.withValues(alpha: 0.0),
  ];

  // Soft warm shadows for humanity
  static List<Shadow> get soulfulShadow => [
    Shadow(
      color: candlelight.withValues(alpha: 0.12),
      blurRadius: 12,
      offset: const Offset(0, 2),
    ),
  ];
}

/// ENOUGH — Text Styles with Lora font
abstract class AppTextStyles {
  // Primary text style (Lora - warm, literary)
  static TextStyle get primary => GoogleFonts.lora(
    color: AppColors.primaryText.withValues(alpha: 0.90), // Spoken, not rendered
    fontWeight: FontWeight.w300,
    height: 1.6,
    shadows: AppColors.soulfulShadow,
  );

  // Entry screen text (anticipation)
  static TextStyle get entry => primary.copyWith(
    fontSize: 28,
    letterSpacing: 1.1, // Breathing room
  );

  // Closure screen text (arrival)
  static TextStyle get closure => primary.copyWith(
    fontSize: 34,
    letterSpacing: 0.2, // Finality
  );

  // Button text
  static TextStyle get button => GoogleFonts.lora(
    color: AppColors.primaryText.withValues(alpha: 0.88),
    fontSize: 17,
    fontWeight: FontWeight.w500,
    letterSpacing: 5.5,
    shadows: AppColors.soulfulShadow,
  );
}
