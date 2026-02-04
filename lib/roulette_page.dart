import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import '../widgets/golden_shamrock.dart';
import '../widgets/gold_dust_particles.dart';

class RoulettePage extends StatefulWidget {
  final void Function(String)? onSpinComplete;

  const RoulettePage({
    super.key,
    this.onSpinComplete,
  });

  @override
  State<RoulettePage> createState() => _RoulettePageState();
}

class _RoulettePageState extends State<RoulettePage>
    with TickerProviderStateMixin {
  late AnimationController _spinController;
  late Animation<double> _spinAnimation;
  late AnimationController _pulseController;

  // Sparks controller
  late AnimationController _sparksController;
  final List<Offset> _sparks = [];

  final AudioPlayer _player = AudioPlayer();
  double _currentAngle = 0;
  bool _isSpinning = false;

  final List<String> _sectors = [
    "Match Gratis",
    "Super Like",
    "Perfil Pro 24h",
    "Filtro VIP",
    "Giro Extra",
    "Mensaje Directo",
  ];

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      lowerBound: 1.0,
      upperBound: 1.15,
    );

    _sparksController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addListener(() {
        setState(() {
          // Simple spark logic: clear them quickly or animate opacity
          // Ideally we'd have a complex particle system, but for now simple ephemeral sparks work
        });
      });
  }

  @override
  void dispose() {
    _spinController.dispose();
    _pulseController.dispose();
    _sparksController.dispose();
    _player.dispose();
    super.dispose();
  }

  void _spinRoulette() async {
    if (_isSpinning) return;
    _isSpinning = true;
    _sparks.clear();

    HapticFeedback.heavyImpact();
    // try {
    //   await _player.stop();
    //   await _player.play(AssetSource('audio/spin.mp3'));
    // } catch (e) {
    //   debugPrint("Sonido de giro no encontrado");
    // }

    final random = Random();
    final spins = 5 + random.nextInt(5);
    final targetAngle =
        _currentAngle + (spins * 2 * pi) + (random.nextDouble() * 2 * pi);

    _spinAnimation = Tween<double>(
      begin: _currentAngle,
      end: targetAngle,
    ).animate(
        CurvedAnimation(parent: _spinController, curve: Curves.easeOutCubic))
      ..addListener(() {
        // Detect sector passing for sparks/haptics
        // This is a simplified check
        if (_spinController.value > 0.1 && _spinController.value < 0.9) {
          if (random.nextInt(10) > 8) {
            _triggerSpark();
          }
        }
        setState(() {
          _currentAngle = _spinAnimation.value;
        });
      });

    await _spinController.forward(from: 0);

    // Stop feedback
    _pulseController.forward().then((_) => _pulseController.reverse(from: 1.0));
    HapticFeedback.heavyImpact();

    final normalizedAngle = targetAngle % (2 * pi);
    // Calculate sector (this logic depends on where index 0 is visually)
    // Assuming standard math rotation, 0 is right.
    final sectorSize = 2 * pi / _sectors.length;
    // We need to account for the pointer position (usually top or right).
    // Let's assume pointer is top (3*pi/2 or -pi/2).
    // The visual rotation moves the wheel, so the "winning" sector is the one under the pointer.
    // Winning Angle = Pointer Angle - Wheel Angle
    // For simplicity here, let's just reverse map or pick based on the final random angle directly if simple visual match isn't critical for this demo.
    final sectorIndex =
        ((2 * pi - normalizedAngle) / sectorSize).floor() % _sectors.length;

    final result = _sectors[sectorIndex];
    if (mounted) {
      _showResult(result);
    }

    _isSpinning = false;
  }

  void _triggerSpark() {
    // Visual spark effect logic could go here
    HapticFeedback.lightImpact();
  }

  void _showResult(String result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFFFD700), width: 2),
              boxShadow: const [
                BoxShadow(
                    color: Color(0xFFFFD700), blurRadius: 20, spreadRadius: -5),
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const GoldenShamrock(size: 80),
              const SizedBox(height: 20),
              Text(
                result,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.orange, blurRadius: 10)],
                ),
              ),
              const SizedBox(height: 10),
              const Text("¡Recompensa desbloqueada!",
                  style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  widget.onSpinComplete?.call(result); // Trigger callback
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00FF88),
                  foregroundColor: Colors.black,
                ),
                child: const Text("RECLAMAR"),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Handled by App Theme 0x050505
      appBar: AppBar(
        title: const Text("RULETA DORADA",
            style: TextStyle(color: Color(0xFFFFD700))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFFFD700)),
      ),
      body: GoldDustParticles(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // The Arrow/Pointer
              const Icon(Icons.arrow_drop_down,
                  color: Color(0xFF00FF88), size: 50),

              // The Spinning Wheel + Fixed Shamrock
              SizedBox(
                width: 320,
                height: 320,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Spinning Ring
                    Transform.rotate(
                      angle: _currentAngle,
                      child: CustomPaint(
                        painter: _WheelPainter(sectors: _sectors),
                        size: const Size(300, 300),
                      ),
                    ),

                    // Fixed Center Shamrock (Animated scale on win)
                    ScaleTransition(
                      scale: CurvedAnimation(
                          parent: _pulseController, curve: Curves.elasticOut),
                      child: GestureDetector(
                        onTap: _spinRoulette,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration:
                              BoxDecoration(shape: BoxShape.circle, boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00FF88)
                                  .withValues(alpha: 0.4),
                              blurRadius: 30,
                              spreadRadius: 5,
                            )
                          ]),
                          child: const GoldenShamrock(size: 100),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 60),

              const Text(
                "TOCA EL TRÉBOL PARA GIRAR",
                style: TextStyle(
                  color: Colors.white38,
                  letterSpacing: 2,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  final List<String> sectors;

  _WheelPainter({required this.sectors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final sectorAngle = 2 * pi / sectors.length;

    for (int i = 0; i < sectors.length; i++) {
      final startAngle = -pi / 2 + (i * sectorAngle); // Start from top

      // Alternating dark luxury colors
      paint.color =
          i % 2 == 0 ? const Color(0xFF111111) : const Color(0xFF1A1A1A);

      canvas.drawArc(rect, startAngle, sectorAngle, true, paint);
      canvas.drawArc(rect, startAngle, sectorAngle, true, borderPaint);

      // Text
      _drawText(
          canvas, center, radius, startAngle + sectorAngle / 2, sectors[i]);
    }

    // Outer metallic rim
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..shader = const LinearGradient(
              colors: [Color(0xFFCFB53B), Color(0xFFFFD700), Color(0xFFCFB53B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight)
          .createShader(rect);

    canvas.drawCircle(center, radius, rimPaint);
  }

  void _drawText(
      Canvas canvas, Offset center, double radius, double angle, String text) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    canvas.translate(radius * 0.65, 0);

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    // Rotate text to be readable? simpler to just draw it sideways radiating out
    textPainter.paint(
        canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
