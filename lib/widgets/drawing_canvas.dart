import 'package:flutter/material.dart';
import '../models/stroke.dart';

class DrawingCanvas extends StatefulWidget {
  final List<Stroke> strokes;
  final Color selectedColor;
  final double strokeWidth;
  final bool isEraser;
  final bool isPenSelected;
  final bool isHighlighterSelected;
  final Function(Stroke) onStrokeAdded;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onClear;

  const DrawingCanvas({
    super.key,
    required this.strokes,
    required this.selectedColor,
    required this.strokeWidth,
    required this.isEraser,
    required this.isPenSelected,
    required this.isHighlighterSelected,
    required this.onStrokeAdded,
    required this.onUndo,
    required this.onRedo,
    required this.onClear,
  });

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  final List<Stroke> _currentPageStrokes = [];
  Stroke? _currentStroke;
  final GlobalKey _canvasKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) => _startDrawing(details.localPosition),
      onPanUpdate: (details) => _updateDrawing(details.localPosition),
      onPanEnd: (_) => _endDrawing(),
      child: CustomPaint(
        key: _canvasKey,
        painter: _DrawingPainter(
          strokes: [...widget.strokes, ..._currentPageStrokes],
          currentStroke: _currentStroke,
        ),
        size: Size.infinite,
      ),
    );
  }

  void _startDrawing(Offset position) {
    if (!widget.isPenSelected && !widget.isHighlighterSelected && !widget.isEraser) return;

    setState(() {
      _currentStroke = Stroke(
        points: [position],
        color: widget.isHighlighterSelected 
            ? const Color(0x4DFFFF00) // Yellow with 30% opacity
            : widget.selectedColor,
        strokeWidth: widget.isHighlighterSelected ? 6.0 : widget.strokeWidth,
        isEraser: widget.isEraser,
      );
    });
  }

  void _updateDrawing(Offset position) {
    if (_currentStroke == null) return;

    setState(() {
      _currentStroke!.points.add(position);
    });
  }

  void _endDrawing() {
    if (_currentStroke == null) return;

    if (_currentStroke!.points.length > 1) {
      if (_currentStroke!.isEraser) {
        _eraseStrokes();
      } else {
        widget.onStrokeAdded(_currentStroke!);
      }
    }

    setState(() {
      _currentStroke = null;
    });
  }

  void _eraseStrokes() {
    if (_currentStroke == null) return;

    final eraserWidth = widget.strokeWidth * 2;
    final eraserRect = Rect.fromCenter(
      center: _currentStroke!.points.last,
      width: eraserWidth,
      height: eraserWidth,
    );

    setState(() {
      _currentPageStrokes.removeWhere((stroke) {
        if (stroke.isEraser) return false;

        for (final point in stroke.points) {
          if (eraserRect.contains(point)) {
            return true;
          }
        }
        return false;
      });
    });
  }
}

class _DrawingPainter extends CustomPainter {
  final List<Stroke> strokes;
  final Stroke? currentStroke;

  _DrawingPainter({
    required this.strokes,
    this.currentStroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final stroke in strokes) {
      if (stroke.points.length < 2) continue;

      paint
        ..color = stroke.color
        ..strokeWidth = stroke.strokeWidth;

      final path = Path();
      path.moveTo(stroke.points[0].dx, stroke.points[0].dy);

      for (int i = 1; i < stroke.points.length; i++) {
        path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
      }

      canvas.drawPath(path, paint);
    }

    if (currentStroke != null && currentStroke!.points.length > 1) {
      paint
        ..color = currentStroke!.color
        ..strokeWidth = currentStroke!.strokeWidth;

      final path = Path();
      path.moveTo(currentStroke!.points[0].dx, currentStroke!.points[0].dy);

      for (int i = 1; i < currentStroke!.points.length; i++) {
        path.lineTo(currentStroke!.points[i].dx, currentStroke!.points[i].dy);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_DrawingPainter oldDelegate) {
    return oldDelegate.strokes != strokes ||
        oldDelegate.currentStroke != currentStroke;
  }
} 