import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppColors {
  static const Color paper = Color(0xFFEEF0F7);
  static const Color paperLight = Color(0xFFFAFAFD);
  static const Color ink = Color(0xFF151826);
  static const Color inkSoft = Color(0xFF696D7C);
  static const Color accent = Color(0xFF625DB8);
  static const Color accentSoft = Color(0xFFDADBF8);
  static const Color glassBlue = Color(0xFF8ADDE5);
  static const Color glassLilac = Color(0xFFBDAAFB);

  static const Color orbCore = Color(0xFF8B7BFF);
  static const Color orbGlow = Color(0xFF6B5CE7);
  static const Color orbHot = Color(0xFFFF6B6B);
  static const Color warmInk = Color(0xFF1A1428);

  static const Color vermilion = accent;
  static const Color backgroundPrimary = paper;
  static const Color backgroundDepth = ink;
  static const Color backgroundWarm = Color(0xFFE6E8F2);
  static const Color primaryText = ink;
  static const Color secondaryText = inkSoft;
  static const Color accentGlow = accent;
  static const Color accentWarm = accent;
  static const Color ambientWarm = accentSoft;
  static const Color candlelight = Color(0xFFC6C8E7);
  static Color get secondaryTextSubtle => inkSoft.withValues(alpha: .55);
  static Color get accentGlowSubtle => accent.withValues(alpha: .1);
  static Color get accentGlowMedium => accent.withValues(alpha: .18);
  static const List<Color> vignetteGradient = [
    Colors.transparent,
    Color(0x22191A2A),
    Color(0x66131320),
  ];
  static List<Color> get buttonGlowGradient => [
    accent.withValues(alpha: 0),
    accent.withValues(alpha: .08),
    accent.withValues(alpha: .15),
    accent.withValues(alpha: .08),
    accent.withValues(alpha: 0),
  ];
  static List<Shadow> get soulfulShadow => const [];
}

abstract class AppTextStyles {
  static TextStyle get eyebrow => GoogleFonts.spaceMono(
    color: AppColors.inkSoft,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
  );
  static TextStyle get wordmark => GoogleFonts.bebasNeue(
    color: AppColors.ink,
    fontSize: 62,
    height: .95,
    letterSpacing: 1.1,
  );
  static TextStyle get hero => GoogleFonts.dmSerifDisplay(
    color: AppColors.paperLight,
    fontSize: 39,
    height: 1.05,
  );
  static TextStyle get headline => GoogleFonts.dmSerifDisplay(
    color: AppColors.ink,
    fontSize: 42,
    height: 1.08,
  );
  static TextStyle get body =>
      GoogleFonts.dmSans(color: AppColors.inkSoft, fontSize: 16, height: 1.5);
  static TextStyle get pageQuote => GoogleFonts.dmSerifDisplay(
    color: AppColors.ink,
    fontSize: 20,
    height: 1.22,
  );
  static TextStyle get stamp => GoogleFonts.spaceMono(
    color: AppColors.accent,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
  );
  static TextStyle get primary =>
      GoogleFonts.dmSerifDisplay(color: AppColors.primaryText, height: 1.2);
  static TextStyle get entry => headline;
  static TextStyle get closure => GoogleFonts.dmSerifDisplay(
    color: AppColors.ink,
    fontSize: 40,
    height: 1.08,
  );
  static TextStyle get button => GoogleFonts.dmSans(
    color: AppColors.paperLight,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: .2,
  );
}
