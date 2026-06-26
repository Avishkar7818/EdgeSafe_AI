// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert'; // Required for base64Decode

// Core imports
import 'app_theme.dart';
import 'auth_controller.dart';

// Screen imports - Adjust the folder paths if you placed them inside subfolders!
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/dashboard_controller.dart';
import 'screens/logs_screen.dart';
import 'screens/monitoring_screen.dart';
import 'screens/settings_screen.dart';

// --- 1. ADD THIS GETX LIFECYCLE CONTROLLER ---
class AppLifecycleController extends SuperController {
  @override
  void onResumed() {
    // When the APK is brought back from the background, force the splash screen
    if (Get.currentRoute != '/splash') {
      Get.offAllNamed('/splash');
    }
  }

  // Required overrides for SuperController (we leave these empty)
  @override
  void onDetached() {}
  @override
  void onInactive() {}
  @override
  void onPaused() {}

  // The missing required override for newer GetX versions
  @override
  void onHidden() {}
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize AuthController globally
  Get.put(AuthController());

  // --- 2. INITIALIZE THE LIFECYCLE CONTROLLER HERE ---
  Get.put(AppLifecycleController());

  runApp(const EdgeSafeApp());
}

class EdgeSafeApp extends StatelessWidget {
  const EdgeSafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'EdgeSafe AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,

      // --- initialRoute handles the very first cold boot ---
      initialRoute: '/splash',

      getPages: [
        GetPage(name: '/splash', page: () => const SplashScreen()),

        // Fade transition for the login screen so it blends perfectly
        GetPage(
          name: '/login',
          page: () => const LoginScreen(),
          transition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 800),
        ),

        GetPage(name: '/signup', page: () => const SignupScreen()),
        GetPage(
          name: '/dashboard',
          page: () => const DashboardScreen(),
          binding: BindingsBuilder(() {
            // lazyPut is better for performance
            Get.lazyPut(() => DashboardController());
          }),
        ),

        // --- REAL ROUTES LINKED HERE ---
        GetPage(name: '/logs', page: () => const LogsScreen()),
        GetPage(name: '/monitoring', page: () => const MonitoringScreen()),
        GetPage(name: '/settings', page: () => const SettingsScreen()),
      ],
      defaultTransition: Transition.cupertino,
    );
  }
}
