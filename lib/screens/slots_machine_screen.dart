import 'package:flutter/material.dart';

class SlotsMachineScreen extends StatefulWidget {
  const SlotsMachineScreen({super.key});

  @override
  State<SlotsMachineScreen> createState() => _SlotsMachineScreenState();
}

class _SlotsMachineScreenState extends State<SlotsMachineScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Slots Machine',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: const Center(
        child: Text(
          'Slots Machine Screen - Coming Soon',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
