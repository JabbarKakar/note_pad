import 'package:flutter/material.dart';
import 'package:note_pad/models/canvas_page.dart';
import 'package:note_pad/models/stroke.dart';
import 'package:note_pad/widgets/drawing_painter.dart';
import 'package:note_pad/widgets/drawing_toolbar.dart';

class DrawingPage extends StatefulWidget {
  const DrawingPage({super.key});

  @override
  DrawingPageState createState() => DrawingPageState();
}

class DrawingPageState extends State<DrawingPage> {
  final ScrollController _scrollController = ScrollController();
  List<CanvasPage> pages = [CanvasPage()];
  Color selectedColor = Colors.black;
  double strokeWidth = 4.0;
  bool isEraser = false;
  bool isPenSelected = false;
  bool isHighlighterSelected = false;
  List<Offset> currentPoints = [];
  Map<int, List<Offset>> currentPointsMap = {};
  bool _hasAddedPage = false;
  double _lastScrollPosition = 0;
  bool _isDrawing = false;

  // Undo/Redo stacks for each page
  final List<List<List<Stroke>>> _undoStacks = [[]];
  final List<List<List<Stroke>>> _redoStacks = [[]];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_isDrawing) return;
    
    final currentPosition = _scrollController.position.pixels;
    
    if (currentPosition < _lastScrollPosition) {
      _hasAddedPage = false;
    }
    
    if (!_hasAddedPage && 
        currentPosition >= _scrollController.position.maxScrollExtent) {
      _addPageAtEnd();
      _hasAddedPage = true;
    }
    
    _lastScrollPosition = currentPosition;
  }

  void _addPageAtEnd() {
    setState(() {
      pages.add(CanvasPage());
      _undoStacks.add([]);
      _redoStacks.add([]);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    });
  }

  void _saveCurrentState(int pageIndex) {
    _undoStacks[pageIndex].add(List.from(pages[pageIndex].strokes));
    _redoStacks[pageIndex].clear();
  }

  void _undo(int pageIndex) {
    if (_undoStacks[pageIndex].isEmpty) return;

    setState(() {
      _redoStacks[pageIndex].add(List.from(pages[pageIndex].strokes));
      pages[pageIndex] = CanvasPage(strokes: _undoStacks[pageIndex].removeLast());
    });
  }

  void _redo(int pageIndex) {
    if (_redoStacks[pageIndex].isEmpty) return;

    setState(() {
      _undoStacks[pageIndex].add(List.from(pages[pageIndex].strokes));
      pages[pageIndex] = CanvasPage(strokes: _redoStacks[pageIndex].removeLast());
    });
  }

  void _startDrawing(Offset position, int pageIndex) {
    if (!isPenSelected && !isEraser && !isHighlighterSelected) return;
    
    setState(() {
      _isDrawing = true;
      currentPointsMap[pageIndex] = [position];
    });
  }

  void _updateDrawing(Offset position, int pageIndex) {
    if (!isPenSelected && !isEraser && !isHighlighterSelected) return;
    
    setState(() {
      currentPointsMap[pageIndex]?.add(position);
    });
  }

  void _endDrawing(int pageIndex) {
    if (!isPenSelected && !isEraser && !isHighlighterSelected) return;
    
    final points = currentPointsMap[pageIndex];
    if (points != null && points.length > 1) {
      setState(() {
        _saveCurrentState(pageIndex);
        final stroke = Stroke(
          points: List.from(points),
          color: isHighlighterSelected 
              ? selectedColor.withOpacity(0.3) 
              : isEraser 
                  ? Colors.white 
                  : selectedColor,
          strokeWidth: isHighlighterSelected 
              ? strokeWidth * 2 
              : strokeWidth,
          isEraser: isEraser,
        );
        pages[pageIndex] = pages[pageIndex].addStroke(stroke);
        currentPointsMap.remove(pageIndex);
      });
    }
    _isDrawing = false;
  }

  void _clearCanvas(int pageIndex) {
    setState(() {
      _saveCurrentState(pageIndex);
      pages[pageIndex] = pages[pageIndex].clear();
    });
  }

  void _saveDrawing() {
    // TODO: Implement save functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Save functionality coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drawing Notes'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  physics: _isDrawing 
                      ? const NeverScrollableScrollPhysics() 
                      : const AlwaysScrollableScrollPhysics(),
                  itemCount: pages.length,
                  itemBuilder: (context, index) {
                    return Container(
                      height: MediaQuery.of(context).size.height - 100,
                      margin: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: GestureDetector(
                        onPanStart: (details) => _startDrawing(details.localPosition, index),
                        onPanUpdate: (details) => _updateDrawing(details.localPosition, index),
                        onPanEnd: (_) => _endDrawing(index),
                        child: CustomPaint(
                          painter: DrawingPainter(
                            strokes: [
                              ...pages[index].strokes,
                              if (currentPointsMap[index]?.isNotEmpty ?? false)
                                Stroke(
                                  points: currentPointsMap[index]!,
                                  color: isHighlighterSelected 
                                      ? selectedColor.withOpacity(0.3) 
                                      : isEraser 
                                          ? Colors.white 
                                          : selectedColor,
                                  strokeWidth: isHighlighterSelected 
                                      ? strokeWidth * 2 
                                      : strokeWidth,
                                  isEraser: isEraser,
                                ),
                            ],
                          ),
                          child: Container(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          DrawingToolbar(
            selectedColor: selectedColor,
            strokeWidth: strokeWidth,
            isEraser: isEraser,
            isPenSelected: isPenSelected,
            isHighlighterSelected: isHighlighterSelected,
            onColorChanged: (color) => setState(() => selectedColor = color),
            onStrokeWidthChanged: (width) => setState(() => strokeWidth = width),
            onEraserToggled: (isEraser) => setState(() {
              this.isEraser = isEraser;
              isPenSelected = !isEraser;
              isHighlighterSelected = false;
            }),
            onPenToggled: (isSelected) => setState(() {
              isPenSelected = isSelected;
              isEraser = !isSelected;
              isHighlighterSelected = false;
            }),
            onHighlighterToggled: (isSelected) => setState(() {
              isHighlighterSelected = isSelected;
              isPenSelected = !isSelected;
              isEraser = false;
            }),
            onClearCanvas: () => _clearCanvas(0),
            onUndo: () => _undo(0),
            onRedo: () => _redo(0),
            onSave: _saveDrawing,
          ),
        ],
      ),
    );
  }
}