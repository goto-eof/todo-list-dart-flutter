import 'package:flutter/material.dart';
import 'package:todolistapp/todo_app.dart';

void main() async {
  runApp(
    MaterialApp(
      themeMode: ThemeMode.system,
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: const ToDoApp(),
      debugShowCheckedModeBanner: false,
    ),
  );
}
