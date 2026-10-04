import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'diary.dart';

class DatabaseHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;

    _db = await openDatabase(
      join(await getDatabasesPath(), 'mydiary.db'),
      version: 2,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE diaries('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'title TEXT NOT NULL, '
          'content TEXT NOT NULL, '
          'date TEXT NOT NULL, '
          'mood TEXT NOT NULL, '
          'quote TEXT)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE diaries ADD COLUMN quote TEXT');
        }
      },
    );

    return _db!;
  }

  static Future<void> insert(Diary diary) async {
    final db = await database;
    await db.insert('diaries', diary.toMap());
  }

  static Future<List<Diary>> getAll() async {
    final db = await database;
    final maps = await db.query('diaries', orderBy: 'id DESC');
    return maps.map(Diary.fromMap).toList();
  }

  static Future<void> update(Diary diary) async {
    final db = await database;
    await db.update(
      'diaries',
      diary.toMap(),
      where: 'id = ?',
      whereArgs: [diary.id],
    );
  }

  static Future<void> delete(int id) async {
    final db = await database;
    await db.delete('diaries', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
