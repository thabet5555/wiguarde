import 'package:flutter/material.dart';
import '../ble_manager.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String report = "";

  @override
  void initState() {
    super.initState();

    BLEManager.setListener((data) {
      final msg = data["msg"]?.toString() ?? "";

      if (msg.contains("Attacks") || msg.contains("No attacks")) {
        setState(() {
          report = msg;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reports")),
      body: Center(
        child: Text(report.isEmpty ? "لا يوجد تقرير" : report),
      ),
    );
  }
}
