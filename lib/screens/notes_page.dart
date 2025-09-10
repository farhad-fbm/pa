import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pa/database/note_model.dart';
import 'package:pa/database/notes_database.dart';
import 'package:pa/screens/view_note_page.dart';
import 'edit_note_page.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  late Future<List<NoteModel>> _notesFuture;

  @override
  void initState() {
    super.initState();
    _refreshNotes();
  }

  void _refreshNotes() {
    setState(() {
      _notesFuture = NoteDatabase.instance.readAllNotes();
    });
  }

  Future<bool> _deleteNoteDialog(NoteModel note) async {
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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat.yMMMd().format(date); // e.g., Sep 10, 2025
    } catch (_) {
      return dateString; // fallback if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notes")),
      body: FutureBuilder<List<NoteModel>>(
        future: _notesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No notes yet.",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          } else {
            final notes = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return _NoteCard(
                  note: note,
                  formatDate: _formatDate,
                  onDelete: () => _deleteNoteDialog(note),
                  onEdit: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditNotePage(note: note),
                      ),
                    );
                    _refreshNotes();
                  },
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ViewNotePage(note: note),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditNotePage()),
          );
          _refreshNotes();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Separate widget for a note card with swipe actions
class _NoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onTap;
  final Future<void> Function() onEdit;
  final Future<bool> Function() onDelete;
  final String Function(String) formatDate;

  const _NoteCard({
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
        if (direction == DismissDirection.endToStart) {
          return await onDelete();
        } else if (direction == DismissDirection.startToEnd) {
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
                  overflow: TextOverflow.ellipsis, // long title truncated
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

/// Styles (can move to separate file)
class AppStyles {
  static const titleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static const snippetStyle = TextStyle(fontSize: 15, color: Colors.grey);

  static const dateStyle = TextStyle(fontSize: 13, color: Colors.grey);
}
