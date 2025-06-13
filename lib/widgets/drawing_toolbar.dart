import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class DrawingToolbar extends StatefulWidget {
  final Color selectedColor;
  final double strokeWidth;
  final bool isEraser;
  final bool isPenSelected;
  final bool isHighlighterSelected;
  final Function(Color) onColorChanged;
  final Function(double) onStrokeWidthChanged;
  final Function(bool) onEraserToggled;
  final Function(bool) onPenToggled;
  final Function(bool) onHighlighterToggled;
  final VoidCallback onClearCanvas;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onSave;

  const DrawingToolbar({
    super.key,
    required this.selectedColor,
    required this.strokeWidth,
    required this.isEraser,
    required this.isPenSelected,
    required this.isHighlighterSelected,
    required this.onColorChanged,
    required this.onStrokeWidthChanged,
    required this.onEraserToggled,
    required this.onPenToggled,
    required this.onHighlighterToggled,
    required this.onClearCanvas,
    required this.onUndo,
    required this.onRedo,
    required this.onSave,
  });

  @override
  State<DrawingToolbar> createState() => _DrawingToolbarState();
}

class _DrawingToolbarState extends State<DrawingToolbar> {
  bool _isMinimized = true;
  Offset _position = const Offset(16, 100);
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanStart: (details) {
          setState(() {
            _isDragging = true;
          });
        },
        onPanUpdate: (details) {
          setState(() {
            _position += details.delta;
          });
        },
        onPanEnd: (details) {
          setState(() {
            _isDragging = false;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: _isMinimized ? 50 : 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: _isMinimized
              ? _buildMinimizedView()
              : _buildExpandedView(),
        ),
      ),
    );
  }

  Widget _buildMinimizedView() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _isMinimized = false;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          child: const Icon(
            Icons.edit,
            color: Colors.blue,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDragHandle(),
        _ToolButton(
          icon: Icons.edit,
          label: 'Pen',
          isSelected: widget.isPenSelected,
          onPressed: () => widget.onPenToggled(true),
        ),
        _ToolButton(
          icon: Icons.cleaning_services,
          label: 'Eraser',
          isSelected: widget.isEraser,
          onPressed: () => widget.onEraserToggled(true),
        ),
        _ToolButton(
          icon: Icons.highlight,
          label: 'Highlighter',
          isSelected: widget.isHighlighterSelected,
          onPressed: () => widget.onHighlighterToggled(true),
        ),
        const Divider(height: 1),
        _ToolButton(
          icon: Icons.undo,
          label: 'Undo',
          isSelected: false,
          onPressed: widget.onUndo,
        ),
        _ToolButton(
          icon: Icons.redo,
          label: 'Redo',
          isSelected: false,
          onPressed: widget.onRedo,
        ),
        const Divider(height: 1),
        _ToolButton(
          icon: Icons.delete,
          label: 'Clear',
          isSelected: false,
          onPressed: widget.onClearCanvas,
        ),
        _ToolButton(
          icon: Icons.save,
          label: 'Save',
          isSelected: false,
          onPressed: widget.onSave,
        ),
        const Divider(height: 1),
        _ColorPickerButton(
          selectedColor: widget.selectedColor,
          onColorChanged: widget.onColorChanged,
        ),
        _StrokeWidthButton(
          strokeWidth: widget.strokeWidth,
          onStrokeWidthChanged: widget.onStrokeWidthChanged,
        ),
      ],
    );
  }

  Widget _buildDragHandle() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isMinimized = true;
        });
      },
      child: Container(
        height: 24,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const _ToolButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.blue : Colors.grey,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.blue : Colors.grey,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorPickerButton extends StatelessWidget {
  final Color selectedColor;
  final Function(Color) onColorChanged;

  const _ColorPickerButton({
    required this.selectedColor,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showColorPicker(context),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: selectedColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Color',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ColorPickerSheet(
        selectedColor: selectedColor,
        onColorChanged: onColorChanged,
      ),
    );
  }
}

class _StrokeWidthButton extends StatelessWidget {
  final double strokeWidth;
  final Function(double) onStrokeWidthChanged;

  const _StrokeWidthButton({
    required this.strokeWidth,
    required this.onStrokeWidthChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showStrokeWidthPicker(context),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey),
                ),
                child: Center(
                  child: Container(
                    width: strokeWidth,
                    height: strokeWidth,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Width',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStrokeWidthPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => StrokeWidthPickerSheet(
        strokeWidth: strokeWidth,
        onStrokeWidthChanged: onStrokeWidthChanged,
      ),
    );
  }
}

class ColorPickerSheet extends StatefulWidget {
  final Color selectedColor;
  final Function(Color) onColorChanged;

  const ColorPickerSheet({
    super.key,
    required this.selectedColor,
    required this.onColorChanged,
  });

  @override
  State<ColorPickerSheet> createState() => _ColorPickerSheetState();
}

class _ColorPickerSheetState extends State<ColorPickerSheet> {
  late Color selectedColor;
  final TextEditingController hexController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedColor = widget.selectedColor;
    hexController.text = '#${selectedColor.value.toRadixString(16).substring(2)}';
  }

  @override
  void dispose() {
    hexController.dispose();
    super.dispose();
  }

  void _updateColor(Color color) {
    setState(() {
      selectedColor = color;
      hexController.text = '#${color.value.toRadixString(16).substring(2)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Pick a color',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ColorPicker(
            pickerColor: selectedColor,
            onColorChanged: _updateColor,
            enableAlpha: false,
            labelTypes: const [],
            pickerAreaHeightPercent: 0.5,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: hexController,
            decoration: const InputDecoration(
              labelText: 'Hex Color',
              prefixText: '#',
            ),
            onChanged: (value) {
              if (value.length == 6) {
                try {
                  final color = Color(int.parse('0xFF$value'));
                  _updateColor(color);
                } catch (_) {}
              }
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  widget.onColorChanged(selectedColor);
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StrokeWidthPickerSheet extends StatelessWidget {
  final double strokeWidth;
  final Function(double) onStrokeWidthChanged;

  const StrokeWidthPickerSheet({
    super.key,
    required this.strokeWidth,
    required this.onStrokeWidthChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Stroke Width',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Slider(
            value: strokeWidth,
            min: 1,
            max: 20,
            divisions: 19,
            label: strokeWidth.round().toString(),
            onChanged: onStrokeWidthChanged,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 