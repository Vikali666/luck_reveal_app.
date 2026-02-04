import 'dart:math';
import 'package:flutter/material.dart';

class GoldDustParticles extends StatefulWidget {
  final Widget? child;

  const GoldDustParticles({super.key, this.child});

  @override
  State<GoldDustParticles> createState() => _GoldDustParticlesState();
}

class _GoldDustParticlesState extends State<GoldDustParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Generate initial particles
    for (int i = 0; i < 30; i++) {
      _particles.add(_generateParticle());
    }
  }

  _Particle _generateParticle() {
    return _Particle(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      speed: 0.1 + _random.nextDouble() * 0.2,
      size: 1.0 + _random.nextDouble() * 2.0,
      opacity: 0.3 + _random.nextDouble() * 0.5,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (widget.child != null) Positioned.fill(child: widget.child!),
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ParticlePainter(
                    particles: _particles,
                    progress: _controller.value,
                    random: _random,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _Particle {
  double x;
  double y;
  double speed;
  double size;
  double opacity;

  _Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.opacity,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final Random random;

  _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.random,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var particle in particles) {
      // Update position (move upwards slowly)
      particle.y -= particle.speed * 0.005;
      if (particle.y < -0.1) {
        particle.y = 1.1;
        particle.x = random.nextDouble();
      }

      // Metallic Gold Color
      paint.color = const Color(0xFFFFD700).withValues(alpha: particle.opacity);

      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
