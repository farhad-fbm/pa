import 'package:flutter/material.dart';
import 'package:pa/database/note_model.dart';
import 'package:pa/database/notes_database.dart';
import 'edit_note_page.dart';

class ViewNotePage extends StatelessWidget {
  final NoteModel note;
  const ViewNotePage({super.key, required this.note});

  Future<void> _delete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
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
      Navigator.pop(context); // go back after deletion
    }
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
            _TitleSection(title: note.title, date: note.date),
            const SizedBox(height: 16),
            const Divider(height: 24),
            Expanded(child: _DescriptionSection(description: note.description)),
          ],
        ),
      ),
    );
  }
}

/// Separate widget for title + date
class _TitleSection extends StatelessWidget {
  final String title;
  final String date;

  const _TitleSection({required this.title, required this.date});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppStyles.titleStyle),
        const SizedBox(height: 6),
        Text(date, style: AppStyles.dateStyle),
      ],
    );
  }
}

/// Separate widget for description
class _DescriptionSection extends StatelessWidget {
  final String description;

  const _DescriptionSection({required this.description});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Text(
        description,
        style: AppStyles.descriptionStyle,
        textAlign: TextAlign.start,
      ),
    );
  }
}

/// Styles (can be moved to separate styles.dart)
class AppStyles {
  static const titleStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const dateStyle = TextStyle(fontSize: 14, color: Colors.grey);

  static const descriptionStyle = TextStyle(fontSize: 18, height: 1.5);
}
