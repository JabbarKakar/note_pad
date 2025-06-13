import 'package:flutter/material.dart';

class Stroke {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;
  final bool isEraser;
  final bool isHighlighter;

  Stroke({
    required this.points,
    required this.color,
    required this.strokeWidth,
    this.isEraser = false,
    this.isHighlighter = false,
  });

  Stroke copyWith({
    List<Offset>? points,
    Color? color,
    double? strokeWidth,
    bool? isEraser,
    bool? isHighlighter,
  }) {
    return Stroke(
      points: points ?? this.points,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      isEraser: isEraser ?? this.isEraser,
      isHighlighter: isHighlighter ?? this.isHighlighter,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'points': points.map((point) => {'dx': point.dx, 'dy': point.dy}).toList(),
      'color': color.value,
      'strokeWidth': strokeWidth,
      'isEraser': isEraser,
      'isHighlighter': isHighlighter,
    };
  }

  factory Stroke.fromJson(Map<String, dynamic> json) {
    return Stroke(
      points: (json['points'] as List)
          .map((point) => Offset(point['dx'] as double, point['dy'] as double))
          .toList(),
      color: Color(json['color'] as int),
      strokeWidth: json['strokeWidth'] as double,
      isEraser: json['isEraser'] as bool,
      isHighlighter: json['isHighlighter'] as bool,
    );
  }
} 