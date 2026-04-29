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

    BLEManager.setListener((data) {
      if (data["cmd"] == "RAW") {
        final msg = data["msg"].toString();

        if (msg.contains("Attacks")) {
          setState(() {
            reports = msg.split("\n");
          });
        }
      }
    });
  }

  void loadReports() {
    if (!BLEManager.isConnected) return;
    BLEManager.send("history");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports"),
        actions: [
          IconButton(
            onPressed: loadReports,
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: ListView.builder(
        itemCount: reports.length,
        itemBuilder: (_, i) {
          return ListTile(
            title: Text(reports[i]),
          );
        },
      ),
    );
  }
}
