import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';
import '../core/services/day_guard_service.dart';
import '../core/services/haptic_service.dart';
import '../core/services/sound_service.dart';
import '../features/enough/screens/entry_screen.dart';
import '../features/enough/widgets/film_grain.dart';

/// ENOUGH — Main App Widget
/// 
/// A quiet app that gives you permission to stop — once per day.
/// 
/// Dark theme, full-screen experience, no navigation bar.
/// Silence is the default.
class EnoughApp extends StatelessWidget {
  final DayGuardService dayGuard;
  
  const EnoughApp({
    super.key,
    required this.dayGuard,
  });

  @override
  Widget build(BuildContext context) {
    // Lock to portrait for focused experience
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    // Immersive full-screen mode
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [],
    );
    
    // Dark system bars
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
    
    return MaterialApp(
      title: 'ENOUGH',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.backgroundPrimary,
        colorScheme: ColorScheme.dark(
          surface: AppColors.backgroundPrimary,
          primary: AppColors.accentGlow,
          onPrimary: AppColors.primaryText,
          onSurface: AppColors.primaryText,
        ),
        // No app bar, no navigation
        appBarTheme: const AppBarTheme(
          elevation: 0,
          toolbarHeight: 0,
        ),
      ),
      home: Stack(
        children: [
          EntryScreen(dayGuard: dayGuard),
          const Positioned.fill(
            child: FilmGrain(opacity: 0.015), // Very subtle global texture
          ),
        ],
      ),
    );
  }
}

/// Initialize and run the app
Future<void> initializeEnough() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  final dayGuard = DayGuardService();
  await dayGuard.init();
  await HapticService.init();
  await SoundService.init();
  
  runApp(EnoughApp(dayGuard: dayGuard));
}
