import 'dart:ui' as ui;
import 'package:flutter/material.dart';

Future<ui.Image> createDefaultAvatar() async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  // Fondo gradiente
  final paint = Paint()
    ..shader = ui.Gradient.linear(
      const Offset(0, 0),
      const Offset(200, 200),
      [const Color(0xFF6A11CB), const Color(0xFF2575FC)],
    );

  canvas.drawCircle(const Offset(100, 100), 100, paint);

  // Texto
  final paragraphBuilder = ui.ParagraphBuilder(
    ui.ParagraphStyle(textAlign: TextAlign.center),
  )
    ..pushStyle(ui.TextStyle(
      color: Colors.white,
      fontSize: 60,
      fontWeight: FontWeight.bold,
    ))
    ..addText('LR');

  final paragraph = paragraphBuilder.build()
    ..layout(const ui.ParagraphConstraints(width: 200));

  canvas.drawParagraph(paragraph, const Offset(50, 70));

  final picture = recorder.endRecording();
  return await picture.toImage(200, 200);
}

ImageProvider getDefaultAvatarProvider() {
  return const AssetImage('assets/images/default_avatar.png');
}
