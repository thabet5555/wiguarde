import 'package:flutter/material.dart';
import '../ble_manager.dart';

class AttacksScreen extends StatelessWidget {
  const AttacksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1A2A),
      appBar: AppBar(
        title: const Text("الهجمات المكتشفة"),
        actions: [
          IconButton(
            onPressed: () async {
              await BLEManager.getHistory();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BLEManager.attacks.isEmpty
          ? const Center(
              child: Text(
                "لا توجد هجمات مسجلة بعد",
                style: TextStyle(color: Colors.white70),
              ),
            )
          : ListView.builder(
              itemCount: BLEManager.attacks.length,
              itemBuilder: (_, i) {
                final attack = BLEManager.attacks[i];
                Color riskColor = Colors.yellow;
                if (attack['risk'] == 3) riskColor = Colors.red;
                else if (attack['risk'] == 2) riskColor = Colors.orange;
                return Card(
                  color: const Color(0xFF132C45),
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: Icon(Icons.warning, color: riskColor),
                    title: Text(
                      attack['type'] ?? "Unknown",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "${attack['ssid']}  •  ${attack['time']}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: Text(
                      attack['risk'] == 3 ? "عالي" : (attack['risk'] == 2 ? "متوسط" : "منخفض"),
                      style: TextStyle(color: riskColor),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
