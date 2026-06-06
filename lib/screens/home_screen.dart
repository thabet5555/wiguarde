import 'package:flutter/material.dart';
import '../ble_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  String currentNetwork = "لم يتم اكتشاف شبكة";

  @override
  Widget build(BuildContext context) {
    final attacks = BLEManager.attacks;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1A2A),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1A2A),
        centerTitle: true,
        title: const Text(
          "لوحة الحماية الذكية",
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFF132C45),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Text(
                    BLEManager.isConnected
                        ? "🟢 الجهاز متصل"
                        : "🔴 الجهاز غير متصل",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    currentNetwork,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await BLEManager.send(
                        '{"cmd":"START_SCAN"}',
                      );
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text(
                      "بدء الفحص",
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await BLEManager.send(
                        '{"cmd":"STOP_SCAN"}',
                      );
                    },
                    icon: const Icon(Icons.stop),
                    label: const Text(
                      "إيقاف الفحص",
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFF132C45),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                "عدد الهجمات المكتشفة: ${attacks.length}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),

            const SizedBox(height: 15),

            Expanded(
              child: attacks.isEmpty
                  ? const Center(
                      child: Text(
                        "لا توجد هجمات مكتشفة",
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: attacks.length,
                      itemBuilder: (_, i) {
                        final attack = attacks[i];

                        return Card(
                          color: const Color(0xFF132C45),
                          child: ListTile(
                            leading: const Icon(
                              Icons.warning,
                              color: Colors.orange,
                            ),
                            title: Text(
                              attack["type"]?.toString() ??
                                  "UNKNOWN",
                              style: const TextStyle(
                                color: Colors.white,
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
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
