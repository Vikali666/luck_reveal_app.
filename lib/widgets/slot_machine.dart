import 'package:flutter/material.dart';

class SlotMachine extends StatefulWidget {
  final List<String> results;
  final bool isSpinning;

  const SlotMachine({
    super.key,
    required this.results,
    this.isSpinning = false,
  });

  @override
  State<SlotMachine> createState() => _SlotMachineState();
}

class _SlotMachineState extends State<SlotMachine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isSpinning && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isSpinning && _controller.isAnimating) {
      _controller.stop();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green, width: 2),
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (index) {
              return Transform.rotate(
                angle: widget.isSpinning ? _controller.value * 6.28 : 0,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFF222222),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      widget.isSpinning ? '🎰' : widget.results[index],
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
