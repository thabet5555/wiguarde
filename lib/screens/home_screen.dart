import 'package:flutter/material.dart';
import '../ble_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String currentNetwork = 'لم يتم الاختيار';

  final networks = [
    "Redmi",
    "AL-SAREE-NET-774640555",
    "AL-SAREE-NET(139)774640555",
    "AL-SAREE-NET(252)774640555",
  ];

  void createAttack() {
    if (!BLEManager.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ غير متصل بالبلوتوث")),
      );
      return;
    }

    if (BLEManager.attacks.isNotEmpty) return;

    final now = DateTime.now();

    BLEManager.addAttack({
      "ssid": currentNetwork == 'لم يتم الاختيار'
          ? networks[0]
          : currentNetwork,
      "type": "DEAUTH ATTACK",
      "risk": 90,
      "time": TimeOfDay.now().format(context),
      "date": "${now.year}-${now.month}-${now.day}",
    });

    setState(() {});
  }

  void showNetworks() {
    showModalBottomSheet(
      context: context,
      builder: (_) => ListView(
        children: networks.map((n) {
          return ListTile(
            leading: const Icon(Icons.wifi),
            title: Text(n),
            onTap: () {
              setState(() => currentNetwork = n);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final attacks = BLEManager.attacks;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1A2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1A2A),
        title: const Text("لوحة الحماية الذكية"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          Text(
            BLEManager.isConnected ? "🟢 متصل" : "⚠️ غير متصل",
            style: const TextStyle(color: Colors.white),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: createAttack,
                  child: const Text("بدء الفحص"),
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

          Text(
            "الهجمات: ${attacks.length}",
            style: const TextStyle(color: Colors.white),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: ListView.builder(
              itemCount: attacks.length,
              itemBuilder: (_, i) {
                final a = attacks[i];

                return Card(
                  color: const Color(0xFF132C45),
                  child: ListTile(
                    leading: const Icon(
                      Icons.warning,
                      color: Colors.orange,
                    ),
                    title: Text(
                      a["type"],
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      "${a["ssid"]}\n${a["date"]} ${a["time"]}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: Text(
                      "${a["risk"]}%",
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
