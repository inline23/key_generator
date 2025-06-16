import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';

class KeyGeneratorPage extends StatefulWidget {
  const KeyGeneratorPage({super.key});

  @override
  State<KeyGeneratorPage> createState() => _KeyGeneratorPageState();
}

class _KeyGeneratorPageState extends State<KeyGeneratorPage> {
  final TextEditingController _deviceIdController = TextEditingController();
  DateTime? _selectedDate;
  String? _generatedKey;

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _generateKey() async {
    final deviceId = _deviceIdController.text.trim();
    if (deviceId.isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Device ID and expiration date are required."),
        ),
      );
      return;
    }

    final key = const Uuid().v4().substring(0, 8); // Short key

    try {
      await FirebaseFirestore.instance.collection('auth_keys').doc(key).set({
        'deviceId': deviceId,
        'expiryDate': _selectedDate!.toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
        'isActive': true,
        'username': key,
        'password': key,
      });

      setState(() => _generatedKey = key);
      Clipboard.setData(ClipboardData(text: key));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Key generated and copied to clipboard")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving key: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6E6E6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          "Key Generator",
          style: TextStyle(
            color: Color(0xFF471C09),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _deviceIdController,
              decoration: const InputDecoration(
                labelText: "Android ID",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDate == null
                          ? 'YYYY-MM-DD'
                          : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(const Color(0xFF471C09)),
              ),
              onPressed: _generateKey,
              child: const Text(
                "GENERATE KEY",
                style: TextStyle(color: Color(0xFFE6E6E6)),
              ),
            ),
            const SizedBox(height: 20),
            if (_generatedKey != null) ...[
              const Text("Generated Key:"),
              SelectableText(
                _generatedKey!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
