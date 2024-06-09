import 'dart:async';
import 'package:flutter/material.dart';

class Countdown extends StatefulWidget {
  final DateTime dateStart;
  final TextStyle style;

  const Countdown(
      {super.key, required this.dateStart, this.style = const TextStyle()});

  @override
  State<Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<Countdown> {
  Timer? _timer;
  Duration _remaining = const Duration();

  void startTimer() {
    setState(() {
      _remaining = widget.dateStart.difference(DateTime.now());
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      setState(() {
        if (now.isBefore(widget.dateStart)) {
          _remaining = widget.dateStart.difference(now);
        } else {
          _remaining = const Duration();
          timer.cancel();
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '${_remaining.inHours.toString().padLeft(2, '0')}:${(_remaining.inMinutes % 60).toString().padLeft(2, '0')}:${(_remaining.inSeconds % 60).toString().padLeft(2, '0')}',
      style: widget.style,
    );
  }
}
