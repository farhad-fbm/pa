import 'package:flutter/material.dart';
import 'package:pa/database/note_model.dart';
import 'package:pa/database/notes_database.dart';

class EditNotePage extends StatefulWidget {
  final NoteModel? note;

  const EditNotePage({super.key, this.note});

  @override
  State<EditNotePage> createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? "");
    _descController = TextEditingController(
      text: widget.note?.description ?? "",
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now().toIso8601String().split("T").first;
    if (widget.note == null) {
      // CREATE
      final newNote = NoteModel(
        title: _titleController.text,
        description: _descController.text,
        date: now,
      );
      await NoteDatabase.instance.create(newNote);
    } else {
      // UPDATE
      final updatedNote = NoteModel(
        id: widget.note!.id,
        title: _titleController.text,
        description: _descController.text,
        date: now,
      );
      await NoteDatabase.instance.update(updatedNote);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? "Add Note" : "Edit Note"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Title"),
                validator: (val) =>
                    val == null || val.isEmpty ? "Enter title" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: "Description"),
                validator: (val) =>
                    val == null || val.isEmpty ? "Enter description" : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _saveNote, child: const Text("Save")),
            ],
          ),
        ),
      ),
    );
  }
}
