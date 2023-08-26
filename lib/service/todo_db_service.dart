import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:todolistapp/model/todo.dart';

class ToDoDbService {
  var database;

  Future<Database> getDatabaseConnection() async {
    WidgetsFlutterBinding.ensureInitialized();
    String? directory;
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      final Directory appDocumentsDir = await getApplicationSupportDirectory();
      directory = appDocumentsDir.path;
    }
    database ??= openDatabase(
      join(directory ?? await getDatabasesPath(), 'todolistapp.db'),
      onCreate: (db, version) {
        return db.execute(
            'CREATE TABLE todo(id INTEGER PRIMARY KEY, text TEXT, date TEXT, category TEXT, priority TEXT, done INTEGER DEFAULT 0, archived INTEGER DEFAULT 0, insert_date_time TEXT, update_date_time TEXT, tags TEXT)');
      },
      onUpgrade: (db, oldVersion, newVersion) => {if (newVersion >= 2) {}},
      version: 2,
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

  Future<List<ToDo>> list({archived = false}) async {
    final db = await getDatabaseConnection();

    final List<Map<String, dynamic>> maps = await db.query('todo',
        orderBy: 'insert_date_time desc',
        where: 'archived = ${archived ? '1' : '0'}');

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
        done: maps[i]['done'] == 1,
        archived: maps[i]['archived'] == 1,
        insertDateTime: DateTime.parse(
          maps[i]['insert_date_time'],
        ),
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

  Future<int> update(ToDo todo) async {
    final db = await getDatabaseConnection();

    final result = await db
        .update('todo', todo.toMap(), where: "id = ?", whereArgs: [todo.id]);
    return result;
  }
}
