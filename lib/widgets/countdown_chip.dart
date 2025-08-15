import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class CountdownChip extends StatefulWidget {
  final DateTime expiresAtUtc;      // created_at + 15dk, UTC
  final Duration serverOffset;      // vm.serverOffset

  const CountdownChip({
    super.key,
    required this.expiresAtUtc,
    this.serverOffset = Duration.zero,
  });

  @override
  State<CountdownChip> createState() => _CountdownChipState();
}

class _CountdownChipState extends State<CountdownChip> {
  late Duration _left;
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _left = Duration.zero;
    _ticker = Ticker((_) {
      final nowUtc = DateTime.now().toUtc().add(widget.serverOffset);
      setState(() => _left = widget.expiresAtUtc.difference(nowUtc));
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sec = _left.inSeconds;
    if (sec <= 0) {
      return const Chip(
        label: Text('Süre doldu', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey,
      );
    }
    final mm = (sec ~/ 60).toString().padLeft(2, '0');
    final ss = (sec % 60).toString().padLeft(2, '0');

    return Chip(
      label: Text('$mm:$ss',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      backgroundColor: const Color(0xFFFFA800),
    );
  }
}
