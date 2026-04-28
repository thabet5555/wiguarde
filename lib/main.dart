import 'package:flutter/material.dart';

import 'ble_manager.dart';
import 'screens/home_screen.dart';
import 'screens/bluetooth_screen.dart';
import 'screens/attacks_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/bottom_nav.dart';

void main() {
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int index = 0;

  // 🎨 نظام ألوان موحد (أساس المشروع)
  final Color primary = const Color(0xFF1E88E5);
  final Color background = const Color(0xFF0F172A);

  void onConnect(device, char) {
    BLEManager.setConnection(device, char);

    setState(() {
      index = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeScreen(),
      BluetoothScreen(onConnected: onConnect),
      const ReportsScreen(),
      const AttacksScreen(),
      const StatisticsScreen(),
      const SettingsScreen(),
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // 🎯 هنا أساس شكل التطبيق كله
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,

        colorScheme: ColorScheme.dark(
          primary: primary,
          secondary: const Color(0xFF2ECC71),
          error: const Color(0xFFE74C3C),
          surface: background,
        ),

        scaffoldBackgroundColor: background,

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F172A),
          centerTitle: true,
          elevation: 0,
        ),

        cardTheme: CardTheme(
          color: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      home: Scaffold(
        body: SafeArea(
          child: screens[index],
        ),

        bottomNavigationBar: BottomNav(
          selectedIndex: index,
          isArabic: true,
          onItemTapped: (i) => setState(() => index = i),
        ),
      ),
    );
  }
}