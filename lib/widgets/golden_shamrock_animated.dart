import 'dart:math' as math;
import 'package:flutter/material.dart';

class GoldenShamrockAnimated extends StatefulWidget {
  final double size;
  final Color? borderColor;
  final Color? fillColor;

  const GoldenShamrockAnimated({
    super.key,
    required this.size,
    this.borderColor,
    this.fillColor,
  });

  @override
  State<GoldenShamrockAnimated> createState() => _GoldenShamrockAnimatedState();
}

class _GoldenShamrockAnimatedState extends State<GoldenShamrockAnimated>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: math.pi * 2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.1), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 1.1, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _ShamrockPainterAnimated(
                borderColor: widget.borderColor,
                fillColor: widget.fillColor,
                glowIntensity: _controller.value,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _ShamrockPainterAnimated extends CustomPainter {
  final Color? borderColor;
  final Color? fillColor;
  final double glowIntensity;

  _ShamrockPainterAnimated({
    this.borderColor,
    this.fillColor,
    this.glowIntensity = 0.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Gradientes con intensidad variable para animación
    final borderGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        borderColor ?? const Color(0xFFCFB53B),
        borderColor?.withValues(alpha: 0.8) ?? const Color(0xFFFFD700),
        borderColor?.withValues(alpha: 0.6) ?? const Color(0xFFFBF5DF),
        borderColor ?? const Color(0xFFDAA520),
      ],
      stops: const [0.0, 0.4, 0.6, 1.0],
    );

    final innerGradient = RadialGradient(
      center: Alignment.center,
      radius: 0.8,
      colors: [
        fillColor?.withValues(alpha: 0.9 + glowIntensity * 0.1) ??
            const Color(0xFF00FF88),
        fillColor ?? const Color(0xFF00552E),
      ],
      stops: const [0.0, 1.0],
    );

    final borderPaint = Paint()
      ..shader = borderGradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.05
      ..maskFilter = MaskFilter.blur(
        BlurStyle.solid,
        1.0 + glowIntensity * 2.0,
      );

    final fillPaint = Paint()
      ..shader = innerGradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      )
      ..style = PaintingStyle.fill;

    // Draw 4 leaves with slight offset for animation
    for (int i = 0; i < 4; i++) {
      _drawLeaf(
        canvas,
        center,
        radius,
        i * (math.pi / 2) + glowIntensity * 0.1,
        fillPaint,
        borderPaint,
        glowIntensity,
      );
    }

    // Draw stem
    _drawStem(canvas, center, radius, fillPaint, borderPaint);
  }

  void _drawLeaf(
    Canvas canvas,
    Offset center,
    double radius,
    double angle,
    Paint fillPaint,
    Paint borderPaint,
    double pulse,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final path = Path();
    final double s = radius * (0.45 + pulse * 0.05); // Leaf size pulses

    path.moveTo(0, 0);
    path.cubicTo(
      -s * 1.5,
      -s * 1.5,
      -s * 0.5,
      -s * 2.5,
      0,
      -s * 1.5,
    );
    path.cubicTo(
      s * 0.5,
      -s * 2.5,
      s * 1.5,
      -s * 1.5,
      0,
      0,
    );

    // Leaf position varies with animation
    canvas.translate(0, -radius * (0.1 + pulse * 0.05));

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, borderPaint);

    canvas.restore();
  }

  void _drawStem(
    Canvas canvas,
    Offset center,
    double radius,
    Paint fillPaint,
    Paint borderPaint,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(math.pi / 4);

    final path = Path();
    final double s = radius * 0.1;

    path.moveTo(0, 0);
    path.quadraticBezierTo(s, s * 4, s * 3, s * 5);
    path.quadraticBezierTo(s * 2, s * 4, s, 0);
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, borderPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ShamrockPainterAnimated oldDelegate) {
    return oldDelegate.borderColor != borderColor ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.glowIntensity != glowIntensity;
  }
}
