import 'package:flutter/material.dart';
import '../ble_manager.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String text = "";

  @override
  void initState() {
    super.initState();

    BLEManager.setListener((data) {
      if (data["cmd"] == "RAW") {
        final msg = data["msg"].toString();

        if (msg.contains("Status")) {
          setState(() {
            text = msg;
          });
        }
      }
    });
  }

  void load() {
    BLEManager.send("status");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Statistics"),
        actions: [
          IconButton(
            onPressed: load,
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(text),
      ),
    );
  }
}
