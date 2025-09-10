import 'package:flutter/material.dart';
import 'package:pa/database/note_model.dart';
import 'package:pa/database/notes_database.dart';


Future<bool> _deleteNoteDialog(NoteModel note, context, _refreshNotes ) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Delete Note"),
      content: Text("Are you sure you want to delete '${note.title}'?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text("Delete", style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );

  if (confirm == true) {
    await NoteDatabase.instance.delete(note.id!);
    _refreshNotes();
  }
  return confirm ?? false;
}
