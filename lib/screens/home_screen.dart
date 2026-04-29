import 'dart:async';
import 'package:flutter/material.dart';
import '../ble_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool running = false;

  String currentNetwork = "لم يتم الاختيار";
  List<String> networks = [];
  List<String> logs = [];

  @override
  void initState() {
    super.initState();

    BLEManager.setListener((data) {
      if (data["cmd"] == "RAW") {
        final msg = data["msg"].toString();

        // بداية سكان
        if (msg.contains("Networks found")) {
          setState(() => networks.clear());
          return;
        }

        // استقبال كل شبكة (سطر سطر)
        if (RegExp(r'^\d+:').hasMatch(msg)) {
          final name = msg.split(":")[1].trim().split(" (")[0];

          setState(() {
            networks.add(name);
          });
          return;
        }

        // باقي الرسائل
        setState(() {
          logs.insert(0, msg);
        });
      }
    });
  }

  void startStop() {
    if (!BLEManager.isConnected) return;

    setState(() => running = !running);

    if (running) {
      BLEManager.send("monitor");
    } else {
      BLEManager.send("stop");
    }
  }

  void showNetworks() {
    if (!BLEManager.isConnected) return;

    networks.clear();
    BLEManager.send("scan");

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return networks.isEmpty
            ? const Center(child: Text("جاري البحث..."))
            : ListView.builder(
                itemCount: networks.length,
                itemBuilder: (_, i) {
                  return ListTile(
                    title: Text(networks[i]),
                    onTap: () {
                      currentNetwork = networks[i];
                      BLEManager.send("select ${i + 1}");
                      setState(() {});
                      Navigator.pop(context);
                    },
                  );
                },
              );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: Column(
        children: [
          const SizedBox(height: 10),

          Text(
            BLEManager.isConnected ? "🟢 متصل" : "🔴 غير متصل",
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: startStop,
                  child: Text(running ? "إيقاف" : "تشغيل"),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: showNetworks,
                  child: Text(currentNetwork),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Expanded(
            child: ListView.builder(
              itemCount: logs.length,
              itemBuilder: (_, i) {
                return ListTile(
                  title: Text(logs[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
