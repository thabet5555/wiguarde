import 'package:flutter/material.dart';
import '../ble_manager.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1A2A),
      appBar: AppBar(
        title: const Text("التقارير"),
        actions: [
          IconButton(
            onPressed: () async {
              await BLEManager.getHistory();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BLEManager.reports.isEmpty
          ? const Center(
              child: Text(
                "لا توجد تقارير",
                style: TextStyle(color: Colors.white70),
              ),
            )
          : ListView.builder(
              itemCount: BLEManager.reports.length,
              itemBuilder: (_, i) {
                final report = BLEManager.reports[i];
                return Card(
                  color: const Color(0xFF132C45),
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: Icon(
                      report['title'] == "Attack" ? Icons.warning : Icons.info,
                      color: Colors.cyan,
                    ),
                    title: Text(
                      report['type'] ?? "",
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      "${report['ssid']}  •  ${report['time']}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
