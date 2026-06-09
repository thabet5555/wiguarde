import 'package:flutter/material.dart';
import '../ble_manager.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final attacks = BLEManager.attacks;
    Map<String, int> typeCount = {};
    for (var a in attacks) {
      String type = a['type'] ?? 'Unknown';
      typeCount[type] = (typeCount[type] ?? 0) + 1;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B1A2A),
      appBar: AppBar(
        title: const Text("الإحصائيات"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              color: const Color(0xFF132C45),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      "إجمالي الهجمات",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${attacks.length}",
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.cyan,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "التفصيل حسب النوع",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: typeCount.isEmpty
                  ? const Center(
                      child: Text(
                        "لا توجد بيانات",
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : ListView.builder(
                      itemCount: typeCount.keys.length,
                      itemBuilder: (_, i) {
                        String type = typeCount.keys.elementAt(i);
                        int count = typeCount[type]!;
                        return Card(
                          color: const Color(0xFF132C45),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Text(type, style: const TextStyle(color: Colors.white)),
                            trailing: Text(
                              "$count",
                              style: const TextStyle(color: Colors.cyan, fontSize: 18),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
