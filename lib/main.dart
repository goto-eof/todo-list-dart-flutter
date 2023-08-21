import 'package:flutter/material.dart';
import 'package:todolist/todo_app.dart';

void main() {
  runApp(
    const MaterialApp(
      home: ToDoApp(),
      debugShowCheckedModeBanner: false,
    ),
  );
}
