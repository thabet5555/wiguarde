import 'package:flutter/material.dart';
import '../ble_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notifications = true;
  bool protection = true;
  bool autoScan = false;

  Widget _divider() {
    return const SizedBox(height: 12);
  }

  void _sendCommand(String cmd, bool value) {
    BLEManager.send(cmd, {"value": value});
  }

  Widget buildCard({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 8,
          ),
        ],
      ),
      child: SwitchListTile(
        activeColor: color,
        inactiveThumbColor: Colors.grey,
        title: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.white70),
        ),
        value: value,
        onChanged: (v) {
          onChanged(v);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E2E),
        title: const Text(
          'إعدادات النظام',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          buildCard(
            title: "الإشعارات",
            subtitle: "تنبيهات فورية عند اكتشاف تهديد",
            value: notifications,
            icon: Icons.notifications,
            color: Colors.blue,
            onChanged: (v) {
              setState(() => notifications = v);
              _sendCommand("NOTIFICATIONS", v);
            },
          ),

          buildCard(
            title: "وضع الحماية",
            subtitle: "تشغيل نظام الحماية الذكي",
            value: protection,
            icon: Icons.shield,
            color: Colors.green,
            onChanged: (v) {
              setState(() => protection = v);
              _sendCommand("PROTECTION", v);
            },
          ),

          buildCard(
            title: "الفحص التلقائي",
            subtitle: "تشغيل الفحص بدون تدخل",
            value: autoScan,
            icon: Icons.radar,
            color: Colors.orange,
            onChanged: (v) {
              setState(() => autoScan = v);
              _sendCommand("AUTO_SCAN", v);
            },
          ),

          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2E),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const ListTile(
              leading: Icon(Icons.info, color: Colors.blue),
              title: Text(
                'عن التطبيق',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                'نظام كشف هجمات الواي فاي باستخدام ESP32-S3',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ),
        ],
      ),
    );
  }
}