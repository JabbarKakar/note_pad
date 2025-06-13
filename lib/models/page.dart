import 'package:flutter/material.dart';
import 'package:note_pad/models/stroke.dart';

class DrawingPage {
  final List<Stroke> strokes;
  final Color backgroundColor;

  DrawingPage({
    required this.strokes,
    this.backgroundColor = Colors.white,
  });

  DrawingPage copyWith({
    List<Stroke>? strokes,
    Color? backgroundColor,
  }) {
    return DrawingPage(
      strokes: strokes ?? this.strokes,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'strokes': strokes.map((stroke) => stroke.toJson()).toList(),
      'backgroundColor': backgroundColor.value,
    };
  }

  factory DrawingPage.fromJson(Map<String, dynamic> json) {
    return DrawingPage(
      strokes: (json['strokes'] as List)
          .map((stroke) => Stroke.fromJson(stroke))
          .toList(),
      backgroundColor: Color(json['backgroundColor'] as int),
    );
  }
} 