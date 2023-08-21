import 'package:flutter/material.dart';
import 'package:todolistapp/todo_app.dart';

void main() {
  runApp(
    const MaterialApp(
      home: ToDoApp(),
      debugShowCheckedModeBanner: false,
    ),
  );
}
