import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todolist/model/todo.dart';

final formatter = DateFormat.yMd();

class InsertTodoItemForm extends StatefulWidget {
  const InsertTodoItemForm({super.key, required this.onAddTodo});
  final Function(ToDo) onAddTodo;

  @override
  State<StatefulWidget> createState() {
    return _InsertTodoItemFormState();
  }
}

class _InsertTodoItemFormState extends State<InsertTodoItemForm> {
  final _textController = TextEditingController();
  Category _selectedCategory = Category.leisure;
  Priority _selectedPriority = Priority.medium;
  DateTime? _selectedDate = DateTime.now();

  void _showDatePicker() async {
    final initialDate = DateTime.now();
    final firstDate =
        DateTime(initialDate.year - 1, initialDate.month, initialDate.day);
    final lastDate =
        DateTime(initialDate.year + 1, initialDate.month, initialDate.day);

    final pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: firstDate,
        lastDate: lastDate);
    setState(() {
      _selectedDate = pickedDate;
    });
  }

  void _submitData() {
    if (!_validateForm()) {
      showDialog(
          context: context,
          builder: (BuildContext ctx) => _getErrorDialog(ctx));
      return;
    }
    widget.onAddTodo(ToDo(
        text: _textController.text,
        date: _selectedDate!,
        category: _selectedCategory,
        priority: _selectedPriority));

    Navigator.pop(context);
  }

  AlertDialog _getErrorDialog(BuildContext ctx) {
    return AlertDialog(
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
          },
          child: const Text("Ok"),
        ),
      ],
      title: const Text("Invalid input"),
      content: const Text("Please check the form and resubmit"),
    );
  }

  bool _validateForm() {
    if (_textController.text.trim().isEmpty) {
      return false;
    }
    return true;
  }

  String get formattedDate {
    return _selectedDate == null ? "" : formatter.format(_selectedDate!);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        const Row(
          children: [
            Expanded(child: Text("To Do")),
            SizedBox(
              width: 30,
            ),
            Expanded(child: Text("Date"))
          ],
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                keyboardType: TextInputType.text,
                maxLength: 50,
              ),
            ),
            const SizedBox(
              width: 30,
            ),
            Expanded(
                child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                    onPressed: _showDatePicker,
                    icon: const Icon(Icons.calendar_month)),
                Text(formattedDate),
              ],
            ))
          ],
        ),
        const Row(
          children: [
            Expanded(child: Text("Category")),
            SizedBox(
              width: 30,
            ),
            Expanded(child: Text("Priority"))
          ],
        ),
        Row(
          children: [
            Expanded(
                child: DropdownButton<Category>(
                    isExpanded: true,
                    value: _selectedCategory,
                    items: [
                      ...Category.values
                          .map((value) => DropdownMenuItem<Category>(
                                value: value,
                                child: Text(value.name),
                              )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    })),
            const SizedBox(
              width: 30,
            ),
            Expanded(
                child: DropdownButton<Priority>(
                    isExpanded: true,
                    value: _selectedPriority,
                    items: [
                      ...Priority.values
                          .map((priority) => DropdownMenuItem<Priority>(
                                value: priority,
                                child: Text(priority.name),
                              ))
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedPriority = value!;
                      });
                    })),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Close"),
            ),
            const SizedBox(
              width: 10,
            ),
            OutlinedButton(
              onPressed: _submitData,
              child: const Text("Submit"),
            ),
          ],
        )
      ]),
    );
  }
}
