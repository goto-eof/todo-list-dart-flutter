import 'package:flutter/material.dart';
import 'package:todolist/model/todo.dart';

class ToDoItem extends StatelessWidget {
  const ToDoItem({super.key, required this.todo, required this.deleteItem});

  final void Function(ToDo) deleteItem;

  final ToDo todo;

  void _dismissItem(direction) {
    deleteItem(todo);
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      background: Container(color: Colors.red),
      key: Key(todo.id.toString()),
      onDismissed: _dismissItem,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            Row(
              children: [
                Icon(
                  categoryIcon[todo.category],
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  flex: 1000,
                  child: Text(
                    todo.text,
                  ),
                ),
                const Spacer(),
                Column(
                  children: [
                    Text(todo.formattedDate),
                    const SizedBox(
                      height: 10,
                    ),
                    priorityIcon[todo.priority]!,
                    Row(
                      children: [
                        const SizedBox(
                          width: 20,
                        ),
                        IconButton(
                          onPressed: () {
                            deleteItem(todo);
                          },
                          icon: const Icon(
                            Icons.delete,
                            color: Color.fromARGB(255, 0, 162, 255),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}
