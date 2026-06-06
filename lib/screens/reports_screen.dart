import 'package:flutter/material.dart';
import '../ble_manager.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  Widget build(BuildContext context) {
    final reports = BLEManager.reports;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1A2A),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1A2A),
        centerTitle: true,
        title: const Text("التقارير الأمنية"),
      ),

      body: reports.isEmpty
          ? const Center(
              child: Text(
                "لا توجد تقارير حالياً",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),
            )
          : ListView.builder(
              itemCount: reports.length,
              itemBuilder: (_, i) {
                final report = reports[i];

                return Card(
                  color: const Color(0xFF132C45),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.description,
                      color: Colors.lightBlue,
                    ),
                    title: Text(
                      report["title"]?.toString() ??
                          "تقرير",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "${report["type"] ?? ""}\n${report["date"] ?? ""} ${report["time"] ?? ""}",
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
