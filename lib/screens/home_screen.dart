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

  List<String> networks = [];
  String selected = "اختر شبكة";

  List<String> attacks = [];

  @override
  void initState() {
    super.initState();

    BLEManager.setListener((msg) {
      // 📡 الشبكات
      if (msg.contains("Networks found")) {
        final lines = msg.split("\n");

        setState(() {
          networks = lines
              .where((l) => l.contains(":"))
              .map((l) => l.split(":")[1].trim())
              .toList();
        });
        return;
      }

      // ⚠️ هجوم
      setState(() {
        attacks.insert(0, msg);
      });
    });
  }

  void scanNetworks() {
    BLEManager.send("scan");
  }

  void startMonitor() {
    BLEManager.send("monitor");
    setState(() => running = true);
  }

  void stopMonitor() {
    BLEManager.send("stop");
    setState(() => running = false);
  }

  void selectNetwork(int i) {
    BLEManager.send("select ${i + 1}");
    setState(() {
      selected = networks[i];
    });
  }

  void showNetworks() {
    scanNetworks();

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
                      selectNetwork(i);
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
      appBar: AppBar(title: const Text("ESP Detector")),
      body: Column(
        children: [
          const SizedBox(height: 10),

          Text(
            BLEManager.isConnected ? "🟢 متصل" : "❌ غير متصل",
            style: const TextStyle(fontSize: 18),
          ),

          const SizedBox(height: 10),

          ElevatedButton(
            onPressed: showNetworks,
            child: Text(selected),
          ),

          const SizedBox(height: 10),

          ElevatedButton(
            onPressed: running ? stopMonitor : startMonitor,
            child: Text(running ? "إيقاف" : "بدء"),
          ),

          const Divider(),

          const Text("الهجمات"),

          Expanded(
            child: ListView.builder(
              itemCount: attacks.length,
              itemBuilder: (_, i) {
                return ListTile(
                  leading: const Icon(Icons.warning),
                  title: Text(attacks[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
