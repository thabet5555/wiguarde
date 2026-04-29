import 'package:flutter/material.dart';
import '../ble_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> networks = [];

  @override
  void initState() {
    super.initState();

    BLEManager.setListener((line) {
      if (!mounted) return;

      if (line.contains("Networks found")) {
        networks.clear();
        setState(() {});
        return;
      }

      if (RegExp(r'^\d+:').hasMatch(line)) {
        final name = line.split(":")[1].split("(")[0].trim();

        setState(() {
          networks.add(name);
        });
      }
    });
  }

  void scan() {
    networks.clear();
    setState(() {});

    BLEManager.send("scan");

    Future.delayed(const Duration(seconds: 2), () {
      showModalBottomSheet(
        context: context,
        builder: (_) {
          return networks.isEmpty
              ? const Center(child: Text("لا توجد شبكات"))
              : ListView.builder(
                  itemCount: networks.length,
                  itemBuilder: (_, i) {
                    return ListTile(
                      title: Text(networks[i]),
                      onTap: () {
                        BLEManager.send("select ${i + 1}");
                        Navigator.pop(context);
                      },
                    );
                  },
                );
        },
      );
    });
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

          ElevatedButton(
            onPressed: scan,
            child: const Text("Scan Networks"),
          ),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: start,
                  child: const Text("Start"),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: stop,
                  child: const Text("Stop"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
