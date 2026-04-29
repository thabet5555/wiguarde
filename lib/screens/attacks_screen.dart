import 'package:flutter/material.dart';
import '../ble_manager.dart';

class AttacksScreen extends StatefulWidget {
  const AttacksScreen({super.key});

  @override
  State<AttacksScreen> createState() => _AttacksScreenState();
}

class _AttacksScreenState extends State<AttacksScreen> {
  List<String> attacks = [];

  @override
  void initState() {
    super.initState();

    BLEManager.setListener((data) {
      final msg = data["msg"]?.toString() ?? "";

      if (msg.isNotEmpty) {
        setState(() {
          attacks.insert(0, msg);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Attacks")),
      body: ListView.builder(
        itemCount: attacks.length,
        itemBuilder: (_, i) {
          return ListTile(
            title: Text(attacks[i]),
          );
        },
      ),
    );
  }
}
