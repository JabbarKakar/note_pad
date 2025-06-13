import 'package:flutter/material.dart';
import '../models/note.dart';
import '../models/stroke.dart';
import '../widgets/drawing_canvas.dart';
import '../widgets/drawing_toolbar.dart';

class DrawingScreen extends StatefulWidget {
  final Note note;
  final Function(Note) onNoteUpdated;
  final Function()? onRequestNewTitle;

  const DrawingScreen({
    super.key,
    required this.note,
    required this.onNoteUpdated,
    this.onRequestNewTitle,
  });

  @override
  State<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  late Note _currentNote;
  late List<Stroke> _strokes;
  late Color _selectedColor;
  late double _strokeWidth;
  late bool _isEraser;
  late bool _isPenSelected;
  late bool _isHighlighterSelected;
  final TextEditingController _titleController = TextEditingController();
  bool _isEditingTitle = false;

  @override
  void initState() {
    super.initState();
    _currentNote = widget.note;
    _strokes = List<Stroke>.from(_currentNote.strokes);
    _selectedColor = Colors.black;
    _strokeWidth = 2.0;
    _isEraser = false;
    _isPenSelected = true;
    _isHighlighterSelected = false;
    _titleController.text = _currentNote.title;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _updateNote() {
    final updatedNote = _currentNote.copyWith(
      title: _titleController.text,
      strokes: List<Stroke>.from(_strokes),
      updatedAt: DateTime.now(),
    );
    widget.onNoteUpdated(updatedNote);
    _currentNote = updatedNote;
  }

  void _startEditingTitle() {
    setState(() {
      _isEditingTitle = true;
    });
  }

  void _finishEditingTitle() {
    setState(() {
      _isEditingTitle = false;
      if (_titleController.text.trim().isEmpty) {
        if (widget.onRequestNewTitle != null) {
          _titleController.text = widget.onRequestNewTitle!();
        } else {
          _titleController.text = 'Untitled Note';
        }
      }
      _updateNote();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isEditingTitle
            ? TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Enter title',
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _finishEditingTitle(),
                autofocus: true,
              )
            : GestureDetector(
                onTap: _startEditingTitle,
                child: Text(
                  _currentNote.title,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateNote,
          ),
        ],
      ),
      body: Stack(
        children: [
          DrawingCanvas(
            strokes: _strokes,
            selectedColor: _selectedColor,
            strokeWidth: _strokeWidth,
            isEraser: _isEraser,
            isPenSelected: _isPenSelected,
            isHighlighterSelected: _isHighlighterSelected,
            onStrokeAdded: (stroke) {
              setState(() {
                _strokes.add(stroke);
                _updateNote();
              });
            },
            onUndo: () {
              if (_strokes.isNotEmpty) {
                setState(() {
                  _strokes.removeLast();
                  _updateNote();
                });
              }
            },
            onRedo: () {
              // TODO: Implement redo functionality
            },
            onClear: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear Canvas'),
                  content: const Text('Are you sure you want to clear the canvas?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _strokes.clear();
                          _updateNote();
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
            },
          ),
          DrawingToolbar(
            selectedColor: _selectedColor,
            strokeWidth: _strokeWidth,
            isEraser: _isEraser,
            isPenSelected: _isPenSelected,
            isHighlighterSelected: _isHighlighterSelected,
            onColorChanged: (color) {
              setState(() {
                _selectedColor = color;
              });
            },
            onStrokeWidthChanged: (width) {
              setState(() {
                _strokeWidth = width;
              });
            },
            onEraserToggled: (isEraser) {
              setState(() {
                _isEraser = isEraser;
                _isPenSelected = !isEraser;
                _isHighlighterSelected = false;
              });
            },
            onPenToggled: (isPen) {
              setState(() {
                _isPenSelected = isPen;
                _isEraser = false;
                _isHighlighterSelected = false;
              });
            },
            onHighlighterToggled: (isHighlighter) {
              setState(() {
                _isHighlighterSelected = isHighlighter;
                _isPenSelected = false;
                _isEraser = false;
              });
            },
            onClearCanvas: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear Canvas'),
                  content: const Text('Are you sure you want to clear the canvas?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _strokes.clear();
                          _updateNote();
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
            },
            onUndo: () {
              if (_strokes.isNotEmpty) {
                setState(() {
                  _strokes.removeLast();
                  _updateNote();
                });
              }
            },
            onRedo: () {
              // TODO: Implement redo functionality
            },
            onSave: _updateNote,
          ),
        ],
      ),
    );
  }
} 