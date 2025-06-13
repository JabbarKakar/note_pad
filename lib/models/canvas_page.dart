import 'package:flutter/material.dart';
import 'package:note_pad/models/stroke.dart';

class CanvasPage {
  final List<Stroke> strokes;
  final Color backgroundColor;

  CanvasPage({
    List<Stroke>? strokes,
    this.backgroundColor = Colors.white,
  }) : strokes = strokes ?? [];

  CanvasPage copyWith({
    List<Stroke>? strokes,
    Color? backgroundColor,
  }) {
    return CanvasPage(
      strokes: strokes ?? this.strokes,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }

  CanvasPage addStroke(Stroke stroke) {
    final newStrokes = List<Stroke>.from(strokes)..add(stroke);
    return copyWith(strokes: newStrokes);
  }

  CanvasPage clear() {
    return copyWith(strokes: []);
  }
} 