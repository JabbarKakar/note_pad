import 'package:flutter/material.dart';
import 'stroke.dart';

class Note {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Stroke> strokes;
  final Color backgroundColor;

  Note({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.strokes,
    this.backgroundColor = Colors.white,
  });

  Note copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Stroke>? strokes,
    Color? backgroundColor,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      strokes: strokes ?? this.strokes,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'strokes': strokes.map((stroke) => stroke.toJson()).toList(),
      'backgroundColor': backgroundColor.value,
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      strokes: (json['strokes'] as List)
          .map((stroke) => Stroke.fromJson(stroke))
          .toList(),
      backgroundColor: Color(json['backgroundColor']),
    );
  }
} 