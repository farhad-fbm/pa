import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart' as path;
import 'note_model.dart';

class NoteDatabase {
  static final NoteDatabase instance = NoteDatabase._init();
  static sqflite.Database? _database;

  NoteDatabase._init();

  // Get database instance
  Future<sqflite.Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes.db');
    return _database!;
  }

  // Initialize DB
  Future<sqflite.Database> _initDB(String filePath) async {
    final dbPath = await sqflite.getDatabasesPath();
    final fullPath = path.join(dbPath, filePath);
    return await sqflite.openDatabase(
      fullPath,
      version: 1,
      onCreate: _createDB,
    );
  }

  // Create DB schema
  Future _createDB(sqflite.Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
      CREATE TABLE notes (
        id $idType,
        title $textType,
        description $textType,
        date $textType
      )
    ''');
  }

  // CREATE table
  Future<int> create(NoteModel noteModel) async {
    final db = await instance.database;
    return await db.insert('notes', noteModel.toMap());
  }

  // READ (single)
  Future<NoteModel?> readNote(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'notes',
      columns: ['id', 'title', 'description', 'date'],
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return NoteModel.fromMap(maps.first); // return the first result
    } else {
      return null;
    }
  }

  // READ (all)
  Future<List<NoteModel>> readAllNotes() async {
    final db = await instance.database;
    const orderBy = 'date DESC';
    final result = await db.query('notes', orderBy: orderBy);
    return result.map((map) => NoteModel.fromMap(map)).toList();
  }

  // UPDATE
  Future<int> update(NoteModel note) async {
    final db = await instance.database;
    return db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  // DELETE
  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  // CLOSE DB
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
