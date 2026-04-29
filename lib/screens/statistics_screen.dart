import 'package:flutter/material.dart';
import '../ble_manager.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  Map<String, int> stats = {
    "Deauth": 0,
    "Beacon": 0,
    "Probe": 0,
    "MAC": 0,
    "ARP": 0,
    "RTS": 0,
    "Frag": 0,
    "Scan": 0,
    "Evil": 0,
  };

  @override
  void initState() {
    super.initState();

    BLEManager.setListener((data) {
      final msg = data["msg"]?.toString() ?? "";

      setState(() {
        if (msg.contains("DEAUTH")) stats["Deauth"] = stats["Deauth"]! + 1;
        else if (msg.contains("BEACON")) stats["Beacon"] = stats["Beacon"]! + 1;
        else if (msg.contains("PROBE")) stats["Probe"] = stats["Probe"]! + 1;
        else if (msg.contains("MAC")) stats["MAC"] = stats["MAC"]! + 1;
        else if (msg.contains("ARP")) stats["ARP"] = stats["ARP"]! + 1;
        else if (msg.contains("RTS")) stats["RTS"] = stats["RTS"]! + 1;
        else if (msg.contains("FRAG")) stats["Frag"] = stats["Frag"]! + 1;
        else if (msg.contains("SCAN")) stats["Scan"] = stats["Scan"]! + 1;
        else if (msg.contains("EVIL")) stats["Evil"] = stats["Evil"]! + 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Statistics")),
      body: ListView(
        children: stats.entries.map((e) {
          return ListTile(
            title: Text(e.key),
            trailing: Text(e.value.toString()),
          );
        }).toList(),
      ),
    );
  }
}
