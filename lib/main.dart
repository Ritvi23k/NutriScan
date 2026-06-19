// =============================================================================
// main.dart
// =============================================================================
// Entry point for the NutriScan calorie tracker app.
// Uses Provider for state management (AuthProvider + CalorieProvider).
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
// TODO: Uncomment the following line AFTER running `flutterfire configure`
import 'firebase_options.dart';

import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/calorie_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Uncomment the following line AFTER running `flutterfire configure`
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Initialize GoogleSignIn with Web Client ID
  await GoogleSignIn.instance.initialize(
    clientId: '838081154778-oo13eni0t4b1umn3jarehked4auo1gbk.apps.googleusercontent.com',
  );

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => CalorieProvider()),
        ],
        child: const NutriScanApp(),
      ),
    ),
  );
}

class NutriScanApp extends StatelessWidget {
  const NutriScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriScan',
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
