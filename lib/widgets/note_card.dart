import 'package:flutter/material.dart';
import 'package:pa/constants/app_styles.dart';
import 'package:pa/database/note_model.dart';

class NoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onTap;
  final Future<void> Function() onEdit;
  final Future<bool> Function() onDelete;
  final String Function(String) formatDate;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    final snippet = note.description.length > 50
        ? "${note.description.substring(0, 50)}..."
        : note.description;

    return Dismissible(
      key: Key(note.id.toString()),
      background: Container(
        color: Colors.blueAccent,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.redAccent,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) return await onDelete();
        if (direction == DismissDirection.startToEnd) {
          await onEdit();
          return false;
        }
        return false;
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  note.title,
                  style: AppStyles.titleStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(formatDate(note.date), style: AppStyles.dateStyle),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(snippet, style: AppStyles.snippetStyle),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
