import 'package:flutter/material.dart';
import 'package:note_pad/models/stroke.dart';

class DrawingPainter extends CustomPainter {
  final List<Stroke> strokes;
  final Color backgroundColor;

  DrawingPainter({
    required this.strokes,
    this.backgroundColor = Colors.white,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = backgroundColor,
    );

    // Draw all strokes
    for (final stroke in strokes) {
      final paint = Paint()
        ..color = stroke.isEraser ? backgroundColor : stroke.color
        ..strokeWidth = stroke.strokeWidth
        ..isAntiAlias = true
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..blendMode = stroke.isEraser ? BlendMode.clear : BlendMode.srcOver;

      for (int i = 0; i < stroke.points.length - 1; i++) {
        if (stroke.points[i] != Offset.infinite && 
            stroke.points[i + 1] != Offset.infinite) {
          canvas.drawLine(
            stroke.points[i],
            stroke.points[i + 1],
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) =>
      oldDelegate.strokes != strokes ||
      oldDelegate.backgroundColor != backgroundColor;

  @override
  bool shouldRebuildSemantics(DrawingPainter oldDelegate) => false;

  @override
  bool? hitTest(Offset position) {
    return super.hitTest(position);
  }
}