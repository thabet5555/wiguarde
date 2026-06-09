import 'package:flutter/material.dart';
import '../ble_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // تحديث واجهة المستخدم كل ثانيتين
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) setState(() {});
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1A2A),
      appBar: AppBar(
        title: const Text("لوحة الحماية الذكية"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            // بطاقة الحالة
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
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    BLEManager.currentNetwork.isEmpty
                        ? "لا توجد شبكة محددة"
                        : "الشبكة: ${BLEManager.currentNetwork}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    BLEManager.isMonitoring
                        ? "🟡 المراقبة نشطة"
                        : "⚫ المراقبة متوقفة",
                    style: const TextStyle(color: Colors.cyan),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // أزرار التحكم الرئيسية
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: BLEManager.isConnected
                        ? () async {
                            await BLEManager.scanNetworks();
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("جاري مسح الشبكات...")));
                            setState(() {});
                          }
                        : null,
                    icon: const Icon(Icons.wifi_find),
                    label: const Text("مسح الشبكات"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: BLEManager.isConnected && BLEManager.networks.isNotEmpty
                        ? () async {
                            await BLEManager.selectNetwork(0);
                            setState(() {});
                          }
                        : null,
                    icon: const Icon(Icons.select_all),
                    label: const Text("اختيار الأولى"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: BLEManager.isConnected && BLEManager.currentNetwork.isNotEmpty
                        ? () async {
                            await BLEManager.startMonitoring();
                            setState(() {});
                          }
                        : null,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text("بدء المراقبة"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: BLEManager.isConnected && BLEManager.isMonitoring
                        ? () async {
                            await BLEManager.stopMonitoring();
                            setState(() {});
                          }
                        : null,
                    icon: const Icon(Icons.stop),
                    label: const Text("إيقاف المراقبة"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // إحصائيات سريعة
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF132C45),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                "📡 الشبكات: ${BLEManager.networks.length}  |  🚨 الهجمات: ${BLEManager.attacks.length}",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            const SizedBox(height: 15),

            // قائمة الشبكات
            Expanded(
              child: BLEManager.networks.isEmpty
                  ? const Center(
                      child: Text(
                        "اضغط 'مسح الشبكات' لعرض الشبكات المتاحة",
                        style: TextStyle(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      itemCount: BLEManager.networks.length,
                      itemBuilder: (_, i) {
                        return Card(
                          color: const Color(0xFF132C45),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: const Icon(Icons.wifi, color: Colors.green),
                            title: Text(
                              BLEManager.networks[i],
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              "📶 ${BLEManager.networksRSSI[i]} dBm",
                              style: const TextStyle(color: Colors.white70),
                            ),
                            trailing: ElevatedButton(
                              onPressed: () async {
                                await BLEManager.selectNetwork(i);
                                setState(() {});
                              },
                              child: const Text("اختيار"),
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
