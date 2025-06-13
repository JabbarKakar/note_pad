import 'package:flutter/material.dart';
import 'stroke.dart';

class NotePage {
  final String id;
  final List<Stroke> strokes;
  final Color backgroundColor;

  NotePage({
    required this.id,
    required this.strokes,
    this.backgroundColor = Colors.white,
  });

  NotePage copyWith({
    String? id,
    List<Stroke>? strokes,
    Color? backgroundColor,
  }) {
    return NotePage(
      id: id ?? this.id,
      strokes: strokes ?? this.strokes,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'strokes': strokes.map((stroke) => stroke.toJson()).toList(),
      'backgroundColor': backgroundColor.value,
    };
  }

  factory NotePage.fromJson(Map<String, dynamic> json) {
    return NotePage(
      id: json['id'],
      strokes: (json['strokes'] as List)
          .map((stroke) => Stroke.fromJson(stroke))
          .toList(),
      backgroundColor: Color(json['backgroundColor']),
    );
  }
} 