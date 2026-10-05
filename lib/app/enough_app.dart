import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';
import '../core/services/sound_service.dart';
import '../features/enough/screens/entry_screen.dart';

/// ENOUGH — Main App Widget
///
/// A quiet app that gives you permission to stop whenever you need.
///
/// Deep, quiet theme with an interactive release ritual and no automatic sound.
class EnoughApp extends StatelessWidget {
  const EnoughApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Lock to portrait for focused experience
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Immersive full-screen mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: []);

    // High-contrast icons on ENOUGH's deep background.
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.ink,
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
        appBarTheme: const AppBarTheme(elevation: 0, toolbarHeight: 0),
      ),
      home: const EntryScreen(),
    );
  }
}

/// Initialize and run the app
Future<void> initializeEnough() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SoundService.init();
  runApp(const EnoughApp());
}
