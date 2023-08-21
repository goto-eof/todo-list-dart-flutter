import 'package:flutter/material.dart';
import 'package:todolist/model/todo.dart';
import 'package:todolist/service/todo_service.dart';
import 'package:todolist/widget/insert_todo_item_form.dart';
import 'package:todolist/widget/todo_item.dart';
import 'package:url_launcher/url_launcher.dart';

final Uri projectUri =
    Uri.parse("https://github.com/goto-eof/todo-list-dart-flutter");

class ToDoApp extends StatefulWidget {
  const ToDoApp({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ToDoAppState();
  }
}

class _ToDoAppState extends State<ToDoApp> {
  List<ToDo> todos = [];
  final ToDoService toDoService = ToDoService();
  var _isLoading = true;

  @override
  void initState() {
    loadToDoList();
    super.initState();
  }

  void loadToDoList() async {
    try {
      List<ToDo> list = await toDoService.list();

      setState(
        () {
          _isLoading = false;
          todos = list;
        },
      );
    } catch (exception) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(exception.toString()),
        ),
      );
    }
  }

  Future<void> _launchUrl() async {
    if (!await launchUrl(projectUri)) {
      throw Exception('Could not launch $projectUri');
    }
  }

  Widget retrieveInsertToDoItemForm(BuildContext context) {
    return InsertTodoItemForm(
      onAddTodo: _addTodoItemToTheList,
    );
  }

  void _addTodoItemToTheList(ToDo todo) async {
    int id = await toDoService.insert(todo);
    setState(
      () {
        todo.id = id;
        todos.add(todo);
      },
    );
  }

  ToDoItem itemBuilder(BuildContext context, int index) {
    return ToDoItem(
      todo: todos[index],
      deleteItem: _deleteTodo,
    );
  }

  void _undo(index, ToDo todo) async {
    int id = await toDoService.insert(todo);
    setState(
      () {
        todo.id = id;
        todos.insert(index, todo);
      },
    );
  }

  Widget _aboutDialogBuilder(BuildContext context) {
    return AlertDialog(
      content: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Developed by Andrei Dodu in 2023."),
            SizedBox(
              height: 10,
            ),
            const Text("Version: 0.1.0"),
          ]),
      actions: [
        TextButton(
          child: const Text('View Source Code'),
          onPressed: () {
            _launchUrl();
          },
        ),
        TextButton(
          child: const Text('Close'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  void _deleteTodo(ToDo todo) async {
    final index = todos.indexOf(todo);
    await toDoService.delete(todo.id);
    setState(
      () {
        todos = todos.where((element) => element.id != todo.id).toList();
      },
    );

    if (!context.mounted) {
      return;
    }
    ScaffoldMessengerState scaffoldMessengerState =
        ScaffoldMessenger.of(context);
    scaffoldMessengerState.clearSnackBars();
    scaffoldMessengerState.showSnackBar(
      SnackBar(
        action: SnackBarAction(
            label: "Undo",
            onPressed: () {
              _undo(index, todo);
            }),
        duration: const Duration(seconds: 3),
        content: const Text("Do you want to undo the change?"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TODO List"),
        actions: [
          IconButton(
              onPressed: () {
                showDialog(context: context, builder: _aboutDialogBuilder);
              },
              icon: const Icon(Icons.info)),
          IconButton(
              onPressed: () {
                showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: retrieveInsertToDoItemForm);
              },
              icon: const Icon(Icons.add)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemBuilder: itemBuilder,
                      itemCount: todos.length,
                    ),
            ),
          )
        ],
      ),
    );
  }
}
