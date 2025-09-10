import 'package:flutter/material.dart';
import 'package:pa/database/note_model.dart';
import 'package:pa/database/notes_database.dart';
import 'edit_note_page.dart';

class ViewNotePage extends StatelessWidget {
  final NoteModel note;
  const ViewNotePage({super.key, required this.note});

  Future<void> _delete(BuildContext context) async {
    await NoteDatabase.instance.delete(note.id!);
    Navigator.pop(context); // go back after deletion
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("View Note"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EditNotePage(note: note)),
              );
              Navigator.pop(context); // go back to list after edit
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _delete(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(note.date, style: const TextStyle(color: Colors.grey)),
            const Divider(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  note.description,
                  style: const TextStyle(fontSize: 18, height: 1.5),
                   textAlign: TextAlign.start,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
