import 'package:flutter/material.dart';
import '../ble_manager.dart';

class AttacksScreen extends StatefulWidget {
  const AttacksScreen({super.key});

  @override
  State<AttacksScreen> createState() => _AttacksScreenState();
}

class _AttacksScreenState extends State<AttacksScreen> {
  @override
  Widget build(BuildContext context) {
    final attacks = BLEManager.attacks;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1A2A),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1A2A),
        centerTitle: true,
        title: const Text("الهجمات المكتشفة"),
      ),

      body: attacks.isEmpty
          ? const Center(
              child: Text(
                "لا توجد هجمات مكتشفة",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),
            )
          : ListView.builder(
              itemCount: attacks.length,
              itemBuilder: (_, i) {
                final attack = attacks[i];

                return Card(
                  color: const Color(0xFF132C45),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                      size: 32,
                    ),
                    title: Text(
                      attack["type"]?.toString() ?? "UNKNOWN",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "${attack["ssid"] ?? ""}\n${attack["date"] ?? ""} ${attack["time"] ?? ""}",
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                    trailing: Text(
                      "${attack["risk"] ?? 0}%",
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
