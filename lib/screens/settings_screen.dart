import 'package:flutter/material.dart';
import '../ble_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Map<String, TextEditingController> _controllers = {};
  final List<String> _thresholdNames = [
    'deauth', 'beacon', 'probe', 'mac', 'arp', 'frag', 'rts', 'arpscan'
  ];

  @override
  void initState() {
    super.initState();
    for (var name in _thresholdNames) {
      _controllers[name] = TextEditingController();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1A2A),
      appBar: AppBar(
        title: const Text("الإعدادات"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Card(
              color: const Color(0xFF132C45),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    const Text(
                      "عتبات الكشف",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    ..._thresholdNames.map((name) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              name.toUpperCase(),
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: TextField(
                              controller: _controllers[name],
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                filled: true,
                                fillColor: Color(0xFF0B1A2A),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              int? val = int.tryParse(_controllers[name]!.text);
                              if (val != null) {
                                BLEManager.setThreshold(name, val);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("تم تحديث $name إلى $val")),
                                );
                              }
                            },
                            child: const Text("تحديث"),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => BLEManager.getSettings(),
              icon: const Icon(Icons.refresh),
              label: const Text("جلب الإعدادات من ESP"),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () => BLEManager.backToMenu(),
              icon: const Icon(Icons.arrow_back),
              label: const Text("العودة للقائمة الرئيسية (ESP)"),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () => BLEManager.getStatus(),
              icon: const Icon(Icons.info),
              label: const Text("حالة الجهاز"),
            ),
          ],
        ),
      ),
    );
  }
}
