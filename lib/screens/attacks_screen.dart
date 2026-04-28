import 'package:flutter/material.dart';
import '../ble_manager.dart';

class AttacksScreen extends StatefulWidget {
  const AttacksScreen({super.key});

  @override
  State<AttacksScreen> createState() => _AttacksScreenState();
}

class _AttacksScreenState extends State<AttacksScreen> {
  List<Map<String, dynamic>> attacks = [];

  @override
  void initState() {
    super.initState();

    BLEManager.setListener((data) {
      final risk = data["risk"] ?? 50;

      final attack = {
        "type": data["cmd"] ?? "UNKNOWN",
        "ssid": data["ssid"] ?? "ESP32",
        "risk": risk,
        "date": DateTime.now().toString().substring(0, 10),
        "time": TimeOfDay.now().format(context),
      };

      setState(() {
        attacks.insert(0, attack);
      });

      _showAlert(attack);
    });
  }

  void _showAlert(Map<String, dynamic> attack) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("🚨 تنبيه أمني"),
        content: Text(
          "${attack["type"]}\n${attack["ssid"]}\nRisk: ${attack["risk"]}%",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إغلاق"),
          ),
        ],
      ),
    );
  }

  Color getColor(int risk) {
    if (risk >= 80) return Colors.red;
    if (risk >= 50) return Colors.orange;
    return Colors.green;
  }

  String getLevel(int risk) {
    if (risk >= 80) return "High";
    if (risk >= 50) return "Medium";
    return "Low";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("مراقبة الهجمات"),
        centerTitle: true,
      ),

      body: attacks.isEmpty
          ? const Center(
        child: Text(
          "لا توجد هجمات بعد",
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: attacks.length,
        itemBuilder: (context, index) {
          final a = attacks[index];
          final risk = a["risk"] as int;
          final color = getColor(risk);

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                )
              ],
              border: Border(
                right: BorderSide(color: color, width: 5),
              ),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: color.withOpacity(0.15),
                child: Icon(Icons.shield, color: color),
              ),

              title: Text(
                a["type"],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),

              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("📡 ${a["ssid"]}"),
                  Text("📅 ${a["date"]}  ⏰ ${a["time"]}"),
                ],
              ),

              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "$risk%",
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    getLevel(risk),
                    style: TextStyle(
                      fontSize: 10,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}