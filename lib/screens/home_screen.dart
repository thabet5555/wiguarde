import 'package:flutter/material.dart';
import '../ble_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> networks = [];
  String selected = "اختيار الشبكة";

  @override
  void initState() {
    super.initState();

    BLEManager.setListener((text) {
      // 🔥 بداية السكان
      if (text.contains("Networks found")) {
        setState(() => networks.clear());
        return;
      }

      // 🔥 كل شبكة
      if (RegExp(r'^\d+:').hasMatch(text)) {
        final name = text.split(":")[1].split("(")[0].trim();

        setState(() {
          networks.add(name);
        });
      }
    });
  }

  void scan() {
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
                      BLEManager.send("select ${i + 1}");

                      setState(() {
                        selected = networks[i];
                      });

                      Navigator.pop(context);
                    },
                  );
                },
              );
      },
    );
  }

  void start() => BLEManager.send("monitor");
  void stop() => BLEManager.send("stop");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ESP Controller")),
      body: Column(
        children: [
          const SizedBox(height: 20),

          Text(BLEManager.isConnected ? "🟢 متصل" : "🔴 غير متصل"),

          const SizedBox(height: 10),

          ElevatedButton(
            onPressed: scan,
            child: Text(selected),
          ),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: start,
                  child: const Text("تشغيل"),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: stop,
                  child: const Text("إيقاف"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
