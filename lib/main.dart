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

void main() => runApp(const App());

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
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.locationWhenInUse,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();
  }

  Future<void> onConnected(
    BluetoothDevice device,
    BluetoothCharacteristic txChar,
    BluetoothCharacteristic rxChar,
  ) async {
    try {
      await BLEManager.setConnection(device, txChar, rxChar);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ تم الاتصال بجهاز ESP")),
      );
      setState(() => index = 0);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ فشل الاتصال: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WiFi Attack Detector',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B1A2A),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF0B1A2A)),
      ),
      home: Scaffold(
        body: SafeArea(
          child: [
            const HomeScreen(),
            BluetoothScreen(onConnected: onConnected),
            const ReportsScreen(),
            const AttacksScreen(),
            const StatisticsScreen(),
            const SettingsScreen(),
          ][index],
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
