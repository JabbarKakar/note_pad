import 'package:flutter/material.dart';
import 'package:note_pad/utile/dialog_helper.dart';
import 'package:note_pad/widgets/page_thumbnail.dart';
import '../models/note.dart';
import '../models/stroke.dart';
import '../models/page.dart';
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
  late int _currentPageIndex;
  late List<Stroke> _currentStrokes;
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
    _currentPageIndex = 0;
    
    // Initialize pages if not exists (for backward compatibility)
    if (_currentNote.pages.isEmpty) {
      _currentNote = _currentNote.copyWith(
        pages: [
          NotePage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            strokes: List<Stroke>.from(_currentNote.strokes),
            backgroundColor: Colors.white,
          ),
        ],
      );
    }
    
    _currentStrokes = List<Stroke>.from(_currentNote.pages[_currentPageIndex].strokes);
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
    final updatedPages = List<NotePage>.from(_currentNote.pages);
    updatedPages[_currentPageIndex] = updatedPages[_currentPageIndex].copyWith(
      strokes: List<Stroke>.from(_currentStrokes),
    );

    // Update both pages and strokes for backward compatibility
    final updatedNote = _currentNote.copyWith(
      title: _titleController.text,
      pages: updatedPages,
      strokes: _currentStrokes, // Keep strokes in sync with current page
      updatedAt: DateTime.now(),
    );
    widget.onNoteUpdated(updatedNote);
    _currentNote = updatedNote;
  }

  void _addNewPage() {
    setState(() {
      final newPage = NotePage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        strokes: [],
        backgroundColor: Colors.white,
      );
      final updatedPages = List<NotePage>.from(_currentNote.pages)..add(newPage);
      _currentNote = _currentNote.copyWith(
        pages: updatedPages,
        updatedAt: DateTime.now(),
      );
      _currentPageIndex = updatedPages.length - 1;
      _currentStrokes = [];
      _updateNote();
    });
  }

  void _switchPage(int index) {
    if (index >= 0 && index < _currentNote.pages.length) {
      setState(() {
        _currentPageIndex = index;
        _currentStrokes = List<Stroke>.from(_currentNote.pages[index].strokes);
      });
    }
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
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                DrawingCanvas(
                  strokes: _currentStrokes,
                  selectedColor: _selectedColor,
                  strokeWidth: _strokeWidth,
                  isEraser: _isEraser,
                  isPenSelected: _isPenSelected,
                  isHighlighterSelected: _isHighlighterSelected,
                  onStrokeAdded: (stroke) {
                    setState(() {
                      _currentStrokes.add(stroke);
                      _updateNote();
                    });
                  },
                  onUndo: () {
                    if (_currentStrokes.isNotEmpty) {
                      setState(() {
                        _currentStrokes.removeLast();
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
                                _currentStrokes.clear();
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
                    DialogHelper.showClearCanvasDialog(
                      context: context,
                      onClearPressed: () {
                        setState(() {
                          _currentStrokes.clear();
                          _updateNote();
                        });
                      },
                    );

                  },
                  onUndo: () {
                    if (_currentStrokes.isNotEmpty) {
                      setState(() {
                        _currentStrokes.removeLast();
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
          ),
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey
              ),
              borderRadius: BorderRadius.circular(6)
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addNewPage,
                  tooltip: 'Add New Page',
                ),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _currentNote.pages.length,
                    itemBuilder: (context, index) {
                      return PageThumbnail(
                        onTap: () { _switchPage(index); },
                        index: index,
                        currentPageIndex: _currentPageIndex,
                      );
                      },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 