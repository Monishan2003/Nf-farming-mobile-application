import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'screens/manager_dashboard.dart';
import 'screens/farmer_dashbort.dart' show WelcomeFormScreen;

enum StartupScreen { login, manager, registration }

const StartupScreen startup = StartupScreen.login;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Widget _resolveHome() {
    switch (startup) {
      case StartupScreen.manager:
        return const ManagerDashboard();
      case StartupScreen.registration:
        return const WelcomeFormScreen();
      case StartupScreen.login:
        return const LoginPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NF Farming',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: _resolveHome(),
    );
  }
}
