import 'package:flutter/material.dart';
import '../ble_manager.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<Map<String, dynamic>> reports = [];

  @override
  void initState() {
    super.initState();

    BLEManager.setListener((data) {
      final report = {
        "date": DateTime.now().toString().substring(0, 16),
        "network": data["ssid"] ?? "Unknown",
        "status": data["cmd"] ?? "UNKNOWN",
        "details": data["msg"] ?? "No details",
      };

      setState(() {
        reports.insert(0, report);
      });
    });
  }

  Color getStatusColor(String status) {
    status = status.toLowerCase();

    if (status.contains("safe") || status.contains("ok")) {
      return Colors.green;
    } else if (status.contains("attack") || status.contains("warn")) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  void _showDetails(Map<String, dynamic> r) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("📊 تقرير الشبكة"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("📅 ${r['date'] ?? ''}"),
              const SizedBox(height: 6),
              Text("📡 الشبكة: ${r['network'] ?? ''}"),
              const SizedBox(height: 6),
              Text("⚡ الحالة: ${r['status'] ?? ''}"),
              const SizedBox(height: 10),
              const Text("🧠 التفاصيل:"),
              Text(r['details'] ?? ""),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إغلاق"),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تقارير الحماية"),
        centerTitle: true,
      ),

      body: reports.isEmpty
          ? const Center(
        child: Text(
          "لا توجد تقارير بعد\nابدأ الفحص من البلوتوث",
          textAlign: TextAlign.center,
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final r = reports[index];

          final color = getStatusColor(
            (r["status"] ?? "").toString(),
          );

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
              onTap: () => _showDetails(r),

              leading: CircleAvatar(
                backgroundColor: color.withOpacity(0.15),
                child: Icon(Icons.shield, color: color),
              ),

              title: Text(
                r["network"] ?? "",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),

              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("📅 ${r["date"] ?? ""}"),
                  Text("⚡ ${r["status"] ?? ""}"),
                ],
              ),

              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            ),
          );
        },
      ),
    );
  }
}