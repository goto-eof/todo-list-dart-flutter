import 'package:flutter/material.dart';
import 'package:todolistapp/todo_app.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.center();
  });
  runApp(
    MaterialApp(
      themeMode: ThemeMode.system,
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: const ToDoApp(),
      debugShowCheckedModeBanner: false,
    ),
  );
}
