import 'package:flutter/material.dart';
import '../ble_manager.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String status = "";
  String network = "";
  String channel = "";

  @override
  void initState() {
    super.initState();

    BLEManager.setListener((data) {
      if (data["cmd"] == "RAW") {
        final msg = data["msg"].toString();

        if (msg.contains("Status")) {
          final lines = msg.split("\n");

          setState(() {
            status = lines.length > 1 ? lines[1] : "";
            network = lines.length > 2 ? lines[2] : "";
            channel = lines.length > 3 ? lines[3] : "";
          });
        }
      }
    });
  }

  void loadStatus() {
    if (!BLEManager.isConnected) return;
    BLEManager.send("status");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Statistics"),
        actions: [
          IconButton(
            onPressed: loadStatus,
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(title: const Text("Status"), subtitle: Text(status)),
            ListTile(title: const Text("Network"), subtitle: Text(network)),
            ListTile(title: const Text("Channel"), subtitle: Text(channel)),
          ],
        ),
      ),
    );
  }
}
