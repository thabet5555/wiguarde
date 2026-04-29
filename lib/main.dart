import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

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

  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  Future<void> requestPermissions() async {
    await Permission.locationWhenInUse.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
  }

  // ✅ الحل هنا
  void onConnect(BluetoothDevice device,
      BluetoothCharacteristic char) async {
    await BLEManager.setConnection(device, char);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ تم الاتصال")),
      );

      setState(() => index = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeScreen(),
      BluetoothScreen(onConnected: onConnect), // ✅ مهم
      const ReportsScreen(),
      const AttacksScreen(),
      const StatisticsScreen(),
      const SettingsScreen(),
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(child: screens[index]),
        bottomNavigationBar: BottomNav(
          selectedIndex: index,
          isArabic: true,
          onItemTapped: (i) => setState(() => index = i),
        ),
      ),
    );
  }
}
