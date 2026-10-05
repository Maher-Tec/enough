import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';
import '../core/services/sound_service.dart';
import '../features/enough/screens/entry_screen.dart';

class EnoughApp extends StatelessWidget {
  const EnoughApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: []);

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

        appBarTheme: const AppBarTheme(elevation: 0, toolbarHeight: 0),
      ),
      home: const EntryScreen(),
    );
  }
}

Future<void> initializeEnough() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SoundService.init();
  runApp(const EnoughApp());
}
