import 'package:flutter/material.dart';
import '../ble_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  void send(String cmd) {
    BLEManager.send(cmd);
  }

  Widget btn(String title, String cmd) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ElevatedButton(
        onPressed: () => send(cmd),
        child: Text(title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("الإعدادات")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          btn("📡 فحص الشبكات", "scan"),
          btn("🎯 اختيار الشبكة 1", "select 1"),
          btn("🎯 اختيار الشبكة 2", "select 2"),

          const Divider(),

          btn("▶️ بدء المراقبة", "monitor"),
          btn("⛔ إيقاف", "stop"),

          const Divider(),

          btn("⚙️ عرض الإعدادات", "settings"),
          btn("📊 الحالة", "status"),
          btn("📜 السجل", "history"),

          const Divider(),

          btn("⬅️ رجوع", "back"),

          const Divider(),

          btn("🔥 Deauth = 10", "threshold deauth 10"),
          btn("🔥 Beacon = 30", "threshold beacon 30"),
        ],
      ),
    );
  }
}
