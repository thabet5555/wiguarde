import 'package:flutter/material.dart';
import '../ble_manager.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<String> reports = [];

  @override
  void initState() {
    super.initState();

    // طلب history من ESP
    BLEManager.send("history");

    BLEManager.setListener((msg) {

      // 📜 استقبال history
      if (msg.contains("Attacks") || msg.contains("No attacks")) {
        final lines = msg.split("\n");

        setState(() {
          reports = lines
              .where((l) => l.trim().isNotEmpty)
              .toList();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reports")),
      body: reports.isEmpty
          ? const Center(child: Text("لا يوجد بيانات"))
          : ListView.builder(
              itemCount: reports.length,
              itemBuilder: (_, i) {
                return ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(reports[i]),
                );
              },
            ),
    );
  }
}
