import 'package:flutter/material.dart';

class NoteListTile extends StatelessWidget {
  final String id;
  final String title;
  final Color backgroundColor;
  final bool hasStrokes;
  final String lastEditedText;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const NoteListTile({
    Key? key,
    required this.id,
    required this.title,
    required this.backgroundColor,
    required this.hasStrokes,
    required this.lastEditedText,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: !hasStrokes
              ? const Icon(Icons.edit, color: Colors.grey)
              : null,
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          lastEditedText,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
