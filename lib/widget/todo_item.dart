import 'package:flutter/material.dart';
import 'package:todolist/model/todo.dart';

class ToDoItem extends StatelessWidget {
  ToDoItem({super.key, required this.todo, required this.deleteItem});

  void Function(ToDo) deleteItem;

  final ToDo todo;

  @override
  Widget build(BuildContext context) {
    return Card(
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
              Text(
                todo.text,
              ),
              const Spacer(),
              Column(
                children: [
                  Text(todo.formattedDate),
                  const SizedBox(
                    height: 10,
                  ),
                  Icon(priorityIcon[todo.priority])
                ],
              ),
              const SizedBox(
                width: 20,
              ),
              IconButton(
                  onPressed: () {
                    deleteItem(todo);
                  },
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ))
            ],
          ),
        ]),
      ),
    );
  }
}
