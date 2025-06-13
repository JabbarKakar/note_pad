import 'package:flutter/material.dart';
import 'package:note_pad/widgets/note_listTile.dart';
import 'package:uuid/uuid.dart';
import '../models/note.dart';
import '../models/page.dart';
import 'drawing_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Note> _notes = [];
  final _uuid = const Uuid();
  int _nextUntitledNumber = 1;

  String _generateUntitledName() {
    final untitledName = 'Untitled Note $_nextUntitledNumber';
    _nextUntitledNumber++;
    return untitledName;
  }

  void _addNewNote() {
    final newNote = Note(
      id: _uuid.v4(),
      title: _generateUntitledName(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      pages: [
        NotePage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          strokes: [],
          backgroundColor: Colors.white,
        ),
      ],
      strokes: [], // Initialize empty strokes for backward compatibility
    );

    setState(() {
      _notes.insert(0, newNote);
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DrawingScreen(
          note: newNote,
          onNoteUpdated: (updatedNote) {
            setState(() {
              final index = _notes.indexWhere((note) => note.id == updatedNote.id);
              if (index != -1) {
                _notes[index] = updatedNote;
              }
            });
          },
          onRequestNewTitle: _generateUntitledName,
        ),
      ),
    );
  }

  void _openNote(Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DrawingScreen(
          note: note,
          onNoteUpdated: (updatedNote) {
            setState(() {
              final index = _notes.indexWhere((n) => n.id == updatedNote.id);
              if (index != -1) {
                _notes[index] = updatedNote;
              }
            });
          },
          onRequestNewTitle: _generateUntitledName,
        ),
      ),
    );
  }

  void _deleteNote(Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _notes.removeWhere((n) => n.id == note.id);
              });
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ],
      ),
      body: _notes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.note_add,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notes yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to create a new note',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return NoteListTile(
                  id: note.id,
                  title: note.title,
                  backgroundColor: note.backgroundColor,
                  hasStrokes: note.strokes.isNotEmpty || note.pages.first.strokes.isNotEmpty,
                  lastEditedText: 'Last edited: ${_formatDate(note.updatedAt)}',
                  onTap: () => _openNote(note),
                  onDelete: () => _deleteNote(note),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewNote,
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
} 