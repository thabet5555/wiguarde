import 'package:flutter/material.dart';
import '../ble_manager.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reports = BLEManager.reports;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1A2A),
      appBar: AppBar(title: const Text("التقارير")),
      body: ListView.builder(
        itemCount: reports.length,
        itemBuilder: (_, i) {
          final r = reports[i];

          return ListTile(
            title: Text(
              r["title"],
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              "${r["type"]}\n${r["date"]} ${r["time"]}",
              style: const TextStyle(color: Colors.white70),
            ),
          );
        },
      ),
    );
  }
}
