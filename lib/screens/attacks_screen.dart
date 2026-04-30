import 'package:flutter/material.dart';
import '../ble_manager.dart';

class AttacksScreen extends StatelessWidget {
  const AttacksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final attacks = BLEManager.attacks;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1A2A),
      appBar: AppBar(title: const Text("الهجمات")),
      body: ListView.builder(
        itemCount: attacks.length,
        itemBuilder: (_, i) {
          final a = attacks[i];

          return ListTile(
            title: Text(
              a["type"],
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              "${a["ssid"]} - ${a["date"]} ${a["time"]}",
              style: const TextStyle(color: Colors.white70),
            ),
          );
        },
      ),
    );
  }
}
