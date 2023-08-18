import 'package:flutter/material.dart';
import 'package:todo_list/model/dummy_data.dart';
import 'package:todo_list/model/todo.dart';
import 'package:todo_list/widget/insert_todo_item_form.dart';
import 'package:todo_list/widget/todo_item.dart';

class ToDoApp extends StatefulWidget {
  const ToDoApp({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ToDoAppState();
  }
}

class _ToDoAppState extends State<ToDoApp> {
  List<ToDo> todos = [];

  Widget retrieveInsertToDoItemForm(BuildContext context) {
    return InsertTodoItemForm(
      onAddTodo: _addTodoItemToTheList,
    );
  }

  void _addTodoItemToTheList(ToDo todo) {
    setState(() {
      todos.add(todo);
    });
  }

  ToDoItem itemBuilder(BuildContext context, int index) {
    return ToDoItem(
      todo: todos[index],
      deleteItem: _deleteTodo,
    );
  }

  void _deleteTodo(String id) {
    setState(() {
      todos = todos.where((element) => element.id != id).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TODO List"),
        actions: [
          IconButton(
              onPressed: () {
                showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: retrieveInsertToDoItemForm);
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: ListView.builder(
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
