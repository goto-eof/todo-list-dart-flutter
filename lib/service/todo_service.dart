import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:todolistapp/model/todo.dart';

class ToDoService {
  var database;

  Future<Database> getDatabaseConnection() async {
    WidgetsFlutterBinding.ensureInitialized();
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    database ??= openDatabase(
      join(await getDatabasesPath(), 'todo.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE todo(id INTEGER PRIMARY KEY, text TEXT, date TEXT, category TEXT, priority TEXT)',
        );
      },
      version: 1,
    );
    return database;
  }

  Future<int> insert(ToDo todo) async {
    final db = await getDatabaseConnection();
    return await db.insert(
      'todo',
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ToDo>> list() async {
    final db = await getDatabaseConnection();

    final List<Map<String, dynamic>> maps = await db.query('todo');

    return List.generate(maps.length, (i) {
      return ToDo(
        id: maps[i]['id'],
        text: maps[i]['text'],
        date: DateTime.parse(maps[i]['date']),
        category: Category.values
            .where((element) => element.name == maps[i]['category'])
            .first,
        priority: Priority.values
            .where((element) => element.name == maps[i]['priority'])
            .first,
      );
    });
  }

  Future<void> delete(int id) async {
    final db = await getDatabaseConnection();

    await db.delete(
      'todo',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
