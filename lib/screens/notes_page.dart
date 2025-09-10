import 'package:flutter/material.dart';
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
            onPressed: () => Navigator.pop(context, false), // cancel
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), // confirm
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
            return const Center(child: Text("No notes yet."));
          } else {
            final notes = snapshot.data!;
            return ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];

                // Create a short snippet for description
                final snippet = note.description.length > 50
                    ? "${note.description.substring(0, 50)}..."
                    : note.description;

                return Dismissible(
                  key: Key(note.id.toString()),

                  // Background for left -> right swipe (Edit)
                  background: Container(
                    color: Colors.blue,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    child: const Icon(Icons.edit, color: Colors.white),
                  ),

                  // Background for right -> left swipe (Delete)
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),

                  // Handle swipe
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      // Right -> left swipe = delete
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Delete Note"),
                          content: Text(
                            "Are you sure you want to delete '${note.title}'?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text(
                                "Delete",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await NoteDatabase.instance.delete(note.id!);
                        _refreshNotes();
                      }
                      return confirm ?? false;
                    } else if (direction == DismissDirection.startToEnd) {
                      // Left -> right swipe = edit
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditNotePage(note: note),
                        ),
                      );
                      _refreshNotes();
                      return false; // don't dismiss the item
                    }
                    return false;
                  },

                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      title: Text(note.title),
                      subtitle: Text(snippet),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ViewNotePage(note: note),
                          ),
                        );
                      },
                    ),
                  ),
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
