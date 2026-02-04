import 'dart:math' as math;
import 'package:flutter/material.dart';

class GoldenShamrock extends StatelessWidget {
  final double size;
  final bool animate;

  const GoldenShamrock({
    super.key,
    required this.size,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ShamrockPainter(),
      ),
    );
  }
}

class _ShamrockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Metallic Gold Gradient for Border
    const borderGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFCFB53B), // Old Gold
        Color(0xFFFFD700), // Bright Gold
        Color(0xFFFBF5DF), // White Gold
        Color(0xFFDAA520), // Goldenrod
      ],
      stops: [0.0, 0.4, 0.6, 1.0],
    );

    // Deep Emerald Green with Radial Glow
    const innerGradient = RadialGradient(
      center: Alignment.center,
      radius: 0.8,
      colors: [
        Color(0xFF00FF88), // Brighter emerald center
        Color(0xFF00552E), // Deep emerald
      ],
      stops: [0.0, 1.0],
    );

    final borderPaint = Paint()
      ..shader = borderGradient
          .createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.05 // 5% of width as border
      ..maskFilter =
          const MaskFilter.blur(BlurStyle.solid, 1); // Subtle metallic shine

    final fillPaint = Paint()
      ..shader = innerGradient
          .createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // Draw 4 leaves
    for (int i = 0; i < 4; i++) {
      _drawLeaf(
          canvas, center, radius, i * (math.pi / 2), fillPaint, borderPaint);
    }

    // Draw stem
    _drawStem(canvas, center, radius, fillPaint, borderPaint);
  }

  void _drawLeaf(Canvas canvas, Offset center, double radius, double angle,
      Paint fillPaint, Paint borderPaint) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final path = Path();
    // Heart shape logic for leaf
    // Starting from center (0,0) relative to translation
    // Scale factor for leaf size
    final double s = radius * 0.45;

    path.moveTo(0, 0);
    path.cubicTo(
      -s * 1.5, -s * 1.5, // Control point 1
      -s * 0.5, -s * 2.5, // Control point 2
      0, -s * 1.5, // End point (tip of one lobe)
    );
    path.cubicTo(
      s * 0.5, -s * 2.5, // Control point 2 (mirrored)
      s * 1.5, -s * 1.5, // Control point 1 (mirrored)
      0, 0, // Back to center
    );

    // Move leaf slightly out from center
    canvas.translate(0, -radius * 0.1);

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, borderPaint);

    canvas.restore();
  }

  void _drawStem(Canvas canvas, Offset center, double radius, Paint fillPaint,
      Paint borderPaint) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    // Stem usually points down-right between leaves, let's put it at 45 degrees approx
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
