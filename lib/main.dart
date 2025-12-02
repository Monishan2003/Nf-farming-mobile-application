import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'screens/manager_dashboard.dart';
import 'screens/field_visitor_dashboard.dart';
import 'screens/member_registation.dart' show WelcomeFormScreen;
import 'app_colors.dart';

enum StartupScreen { login, manager, registration }

const StartupScreen startup = StartupScreen.login;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // _resolveHome removed: using named routes + `initialRoute` mapping instead.

  @override
  Widget build(BuildContext context) {
    // Map startup enum to named routes for clarity
    final initialRoute = {
      StartupScreen.login: '/login',
      StartupScreen.manager: '/manager',
      StartupScreen.registration: '/registration',
    }[startup]!;

    return MaterialApp(
      title: 'NF Farming',
      debugShowCheckedModeBanner: false,
      // Use an explicit color scheme and disable Material 3 defaults so
      // platform-dependent automatic styling (rounded buttons, different
      // color seeds) does not override our design.
      theme: ThemeData(
        useMaterial3: false,
        colorScheme: ColorScheme.light(
          primary: AppColors.primaryGreen,
          secondary: AppColors.buttonGreen,
          onPrimary: Colors.white,
        ),
        primaryColor: AppColors.primaryGreen,
        scaffoldBackgroundColor: AppColors.lightBg,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Buttons: enforce rectangular look and our green color
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonGreen,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 2,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
        ),
        // Card visuals (omitted to avoid SDK-type mismatch; cards in UI
        // explicitly configure their BoxDecoration where needed).
        // Input decorations consistent across platforms
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryGreen,
          elevation: 0,
          foregroundColor: Colors.white,
        ),
      ),
      initialRoute: initialRoute,
      routes: {
        '/login': (_) => const LoginPage(),
        '/manager': (_) => const ManagerDashboard(),
        '/registration': (_) => const WelcomeFormScreen(),
        '/field_dashboard': (_) => const FieldVisitorDashboard(),
      },
    );
  }
}
