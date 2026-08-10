import 'package:flutter/material.dart';
import 'dart:math' as math;

/// A custom painter that draws a subtle Spider-web pattern.
/// Used to add a heroic flair to the Daily Bugle headers.
class WebPainter extends CustomPainter {
  final Color color;

  WebPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.1)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Origin point for the web (top right corner)
    final center = Offset(size.width, 0); 
    
    // Draw radial lines (the "spokes" of the web)
    for (double i = 0; i < 90; i += 15) {
      double radians = (i + 90) * math.pi / 180;
      canvas.drawLine(
        center,
        center + Offset(math.cos(radians) * size.width * 1.5, math.sin(radians) * size.width * 1.5),
        paint,
      );
    }

    // Draw arcs (the rings of the web)
    for (double radius = 40; radius < size.width * 1.2; radius += 40) {
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
