import 'package:flutter/material.dart';
import '../ble_manager.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final attacks = BLEManager.attacks;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1A2A),
      appBar: AppBar(title: const Text("الإحصائيات")),
      body: Center(
        child: Text(
          attacks.isEmpty
              ? "لا يوجد هجمات"
              : "تم اكتشاف هجوم واحد\n${attacks.first["type"]}",
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
