import 'package:flutter/material.dart';
import 'package:todo_list/todo_app.dart';

void main() {
  runApp(
    const MaterialApp(
      home: ToDoApp(),
      debugShowCheckedModeBanner: false,
    ),
  );
}
