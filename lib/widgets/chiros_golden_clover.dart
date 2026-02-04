import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget premium y disruptivo ChirosGoldenClover con animaciones espectaculares
class ChirosGoldenClover extends StatefulWidget {
  const ChirosGoldenClover({super.key});

  @override
  State<ChirosGoldenClover> createState() => _ChirosGoldenCloverState();
}

class _ChirosGoldenCloverState extends State<ChirosGoldenClover>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _glowController;
  late AnimationController _particleController;
  late Animation<double> _breathingAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _particleAnimation;

  final List<GoldenParticle> _particles = [];
  final List<ConfettiParticle> _confettiParticles = [];
  bool _showConfetti = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeParticles();
  }

  void _setupAnimations() {
    _breathingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _breathingAnimation = Tween<double>(
      begin: 0.85,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOutCubic,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOutSine,
    ));

    _particleAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_particleController);
  }

  void _initializeParticles() {
    for (int i = 0; i < 50; i++) {
      _particles.add(GoldenParticle.random());
    }
  }

  void _triggerConfetti() {
    HapticFeedback.heavyImpact();
    setState(() {
      _showConfetti = true;
      _confettiParticles.clear();
      for (int i = 0; i < 100; i++) {
        _confettiParticles.add(ConfettiParticle.random());
      }
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showConfetti = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Stack(
        children: [
          // Fondo con partículas doradas flotantes
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: GoldenParticlesPainter(
              particles: _particles,
              animation: _particleAnimation.value,
            ),
          ),

          // Contenido principal
          Center(
            child: GestureDetector(
              onLongPress: _triggerConfetti,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Trébol dorado animado
                  AnimatedBuilder(
                    animation:
                        Listenable.merge([_breathingAnimation, _glowAnimation]),
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _breathingAnimation.value,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFBF953F).withValues(
                                    alpha: _glowAnimation.value * 0.8),
                                blurRadius: 40 * _glowAnimation.value,
                                spreadRadius: 10 * _glowAnimation.value,
                              ),
                              BoxShadow(
                                color: const Color(0xFFFCF6BA).withValues(
                                    alpha: _glowAnimation.value * 0.6),
                                blurRadius: 60 * _glowAnimation.value,
                                spreadRadius: 15 * _glowAnimation.value,
                              ),
                            ],
                          ),
                          child: ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [
                                Color(0xFFBF953F),
                                Color(0xFFFCF6BA),
                                Color(0xFFB38728),
                                Color(0xFFBF953F),
                              ],
                              stops: [0.0, 0.3, 0.7, 1.0],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              tileMode: TileMode.mirror,
                            ).createShader(bounds),
                            child: const CustomPaint(
                              painter: GoldenCloverPainter(),
                              size: Size(200, 200),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // Texto elegante con degradado
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        Color(0xFFBF953F),
                        Color(0xFFFCF6BA),
                        Color(0xFFB38728),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ).createShader(bounds),
                    child: Text(
                      'Gemi, el trébol dorado es por mis hijos',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Instrucción sutil
                  Text(
                    'Mantén presionado para magia ✨',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.6),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Efecto de confeti
          if (_showConfetti)
            CustomPaint(
              size: MediaQuery.of(context).size,
              painter: ConfettiPainter(
                particles: _confettiParticles,
                progress: 0.0,
              ),
            ),
        ],
      ),
    );
  }
}

/// CustomPainter para el trébol dorado
class GoldenCloverPainter extends CustomPainter {
  const GoldenCloverPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final leafRadius = size.width * 0.25;

    // Dibujar 4 hojas del trébol
    final positions = [
      Offset(center.dx, center.dy - leafRadius), // Arriba
      Offset(center.dx + leafRadius, center.dy), // Derecha
      Offset(center.dx, center.dy + leafRadius), // Abajo
      Offset(center.dx - leafRadius, center.dy), // Izquierda
    ];

    for (final position in positions) {
      _drawLeaf(canvas, position, leafRadius, paint);
    }

    // Dibujar centro del trébol
    canvas.drawCircle(center, leafRadius * 0.4, paint);

    // Añadir detalles brillantes
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    for (final position in positions) {
      canvas.drawCircle(
        Offset(position.dx - leafRadius * 0.3, position.dy - leafRadius * 0.3),
        leafRadius * 0.15,
        highlightPaint,
      );
    }
  }

  void _drawLeaf(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();

    // Crear forma de corazón para cada hoja
    path.moveTo(center.dx, center.dy + radius * 0.3);

    // Lado izquierdo
    path.cubicTo(
      center.dx - radius * 0.5,
      center.dy - radius * 0.3,
      center.dx - radius * 0.5,
      center.dy - radius * 0.7,
      center.dx,
      center.dy - radius * 0.3,
    );

    // Lado derecho
    path.cubicTo(
      center.dx + radius * 0.5,
      center.dy - radius * 0.7,
      center.dx + radius * 0.5,
      center.dy - radius * 0.3,
      center.dx,
      center.dy + radius * 0.3,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Painter para partículas doradas flotantes
class GoldenParticlesPainter extends CustomPainter {
  final List<GoldenParticle> particles;
  final double animation;

  GoldenParticlesPainter({
    required this.particles,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final progress = (animation + particle.offset) % 1.0;
      final y = (size.height + 100) * progress - 50;
      final x = particle.baseX + sin(progress * pi * 2 + particle.phase) * 30;

      final paint = Paint()
        ..color = Color.fromRGBO(
          255,
          215,
          0,
          particle.opacity * (1.0 - progress.abs()),
        )
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, particle.size * 0.5);

      canvas.drawCircle(Offset(x, y), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant GoldenParticlesPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

/// Painter para efecto de confeti
class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;

  ConfettiPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill;

      final center = Offset(
        particle.x + particle.vx * progress * 100,
        particle.y + particle.vy * progress * 100 + progress * progress * 200,
      );

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(particle.rotation + progress * pi * 4);

      if (particle.isSquare) {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: particle.size,
            height: particle.size,
          ),
          paint,
        );
      } else {
        canvas.drawCircle(Offset.zero, particle.size / 2, paint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Modelo para partículas doradas
class GoldenParticle {
  final double baseX;
  final double offset;
  final double phase;
  final double size;
  final double opacity;

  GoldenParticle({
    required this.baseX,
    required this.offset,
    required this.phase,
    required this.size,
    required this.opacity,
  });

  factory GoldenParticle.random() {
    return GoldenParticle(
      baseX: 50 + Random().nextDouble() * 300,
      offset: Random().nextDouble(),
      phase: Random().nextDouble() * pi * 2,
      size: 1 + Random().nextDouble() * 3,
      opacity: 0.3 + Random().nextDouble() * 0.7,
    );
  }
}

/// Modelo para partículas de confeti
class ConfettiParticle {
  final double x;
  final double y;
  final double vx;
  final double vy;
  final double size;
  final Color color;
  final double rotation;
  final bool isSquare;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.rotation,
    required this.isSquare,
  });

  factory ConfettiParticle.random() {
    final colors = [
      const Color(0xFFBF953F),
      const Color(0xFFFCF6BA),
      const Color(0xFFB38728),
      const Color(0xFFFFD700),
      const Color(0xFFFFA500),
    ];

    return ConfettiParticle(
      x: 150 + (Random().nextDouble() - 0.5) * 100,
      y: 300,
      vx: (Random().nextDouble() - 0.5) * 5,
      vy: -Random().nextDouble() * 5 - 2,
      size: 4 + Random().nextDouble() * 8,
      color: colors[Random().nextInt(colors.length)],
      rotation: Random().nextDouble() * pi * 2,
      isSquare: Random().nextBool(),
    );
  }
}
