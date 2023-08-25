import 'package:flutter/material.dart';
import 'package:todolistapp/model/todo.dart';
import 'package:todolistapp/widget/Item_menu.dart';
import 'package:todolistapp/widget/view_mode_panel.dart';

class ToDoItem extends StatelessWidget {
  ToDoItem(
      {super.key,
      required this.todo,
      required this.deleteItem,
      required this.setItemToDone,
      required this.setPriority,
      required this.archiveItem,
      required this.viewMode});

  final void Function(ToDo) deleteItem;
  final void Function(ToDo) setItemToDone;
  final void Function(ToDo) archiveItem;
  final void Function(Priority, ToDo) setPriority;
  final ViewMode viewMode;

  final ToDo todo;

  void _dismissItem(direction) {
    deleteItem(todo);
  }

  void _setPriority(final Priority priority) {
    setPriority(priority, todo);
  }

  @override
  Widget build(BuildContext context) {
    if (viewMode == ViewMode.compact) {
      return _viewCompact();
    }
    return _viewNormal();
  }

  Widget _viewCompact() {
    return Dismissible(
      key: Key(todo.id.toString()),
      onDismissed: _dismissItem,
      background: Container(color: Colors.red),
      child: Card(
        child: Container(
          decoration: BoxDecoration(
            boxShadow: todo.done
                ? []
                : [
                    BoxShadow(
                      color: const Color.fromARGB(255, 203, 244, 244)
                          .withOpacity(0.2),
                      spreadRadius: 5,
                      blurRadius: 1,
                      offset: const Offset(0, 0),
                    ),
                  ],
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 5,
              ),
              getPriorityIcon(todo.done, 16)[todo.priority]!,
              const SizedBox(
                width: 5,
              ),
              Icon(
                categoryIcon[todo.category],
                size: 16,
                color: todo.done
                    ? const Color.fromARGB(255, 167, 169, 168)
                    : Colors.blue,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(todo.formattedDate),
              const SizedBox(
                width: 5,
              ),
              Text(todo.text),
              const Spacer(),
              Card(
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 0),
                        ),
                      ]),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          deleteItem(todo);
                        },
                        color: Colors.red,
                        icon: const Icon(
                          Icons.delete,
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: () {
                          archiveItem(todo);
                        },
                        color: todo.archived
                            ? Colors.blue
                            : const Color.fromARGB(255, 178, 155, 38),
                        icon: Icon(
                          todo.archived ? Icons.unarchive : Icons.archive,
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: () {
                          setItemToDone(todo);
                        },
                        color: todo.done ? Colors.blue : Colors.green,
                        icon: Icon(
                          todo.done ? Icons.undo : Icons.done,
                        ),
                      ),
                      ItemMenu(
                        setPriority: _setPriority,
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _viewNormal() {
    return Dismissible(
      background: Container(color: Colors.red),
      key: Key(todo.id.toString()),
      onDismissed: _dismissItem,
      child: Card(
        child: Container(
          decoration: BoxDecoration(
            boxShadow: todo.done
                ? []
                : [
                    BoxShadow(
                      color: const Color.fromARGB(255, 203, 244, 244)
                          .withOpacity(0.2),
                      spreadRadius: 5,
                      blurRadius: 1,
                      offset: const Offset(0, 0),
                    ),
                  ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(children: [
              Row(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                        color: Color.fromARGB(6, 0, 0, 0),
                        borderRadius: BorderRadius.all(Radius.circular(0))),
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      "#${todo.id.toString()}",
                      style: TextStyle(
                          fontSize: 15,
                          color: todo.done
                              ? const Color.fromARGB(255, 151, 149, 149)
                              : null),
                    ),
                  ),
                  Text(
                    todo.formattedInserDateTime,
                    style: TextStyle(
                        color: todo.done
                            ? const Color.fromARGB(255, 151, 149, 149)
                            : null),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(Icons.watch_later_outlined),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        todo.formattedDate,
                        style: TextStyle(
                            color: todo.done
                                ? const Color.fromARGB(255, 151, 149, 149)
                                : null),
                      ),
                      ItemMenu(
                        setPriority: _setPriority,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Row(
                    children: [
                      getPriorityIcon(todo.done, 35)[todo.priority]!,
                      Icon(
                        categoryIcon[todo.category],
                        size: 40,
                        color: todo.done
                            ? const Color.fromARGB(255, 167, 169, 168)
                            : Colors.blue,
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    flex: 1000,
                    child: Text(
                      todo.text,
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: todo.done
                              ? const Color.fromARGB(255, 151, 149, 149)
                              : null),
                    ),
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      Card(
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  offset: const Offset(0, 0),
                                ),
                              ]),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  deleteItem(todo);
                                },
                                color: Colors.red,
                                icon: const Icon(
                                  Icons.delete,
                                ),
                              ),
                              const SizedBox(width: 10),
                              IconButton(
                                onPressed: () {
                                  archiveItem(todo);
                                },
                                color: todo.archived
                                    ? Colors.blue
                                    : const Color.fromARGB(255, 178, 155, 38),
                                icon: Icon(
                                  todo.archived
                                      ? Icons.unarchive
                                      : Icons.archive,
                                ),
                              ),
                              const SizedBox(width: 10),
                              IconButton(
                                onPressed: () {
                                  setItemToDone(todo);
                                },
                                color: todo.done ? Colors.blue : Colors.green,
                                icon: Icon(
                                  todo.done ? Icons.undo : Icons.done,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
