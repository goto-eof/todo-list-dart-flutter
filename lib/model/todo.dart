import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();
final formatter = DateFormat.yMd();
final formatterTime = DateFormat.Hms();

class ToDo {
  ToDo(
      {this.id,
      required this.text,
      required this.date,
      required this.category,
      required this.priority,
      required this.done,
      required this.archived,
      this.insertDateTime});

  var id;
  bool done;
  bool archived;
  final String text;
  final DateTime date;
  final Category category;
  Priority priority;
  DateTime? insertDateTime;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'done': done ? 1 : 0,
      'archived': archived ? 1 : 0,
      'text': text,
      "date": date.toIso8601String(),
      "category": category.name,
      "priority": priority.name,
      "insert_date_time": DateTime.now().toIso8601String(),
      "update_date_time": DateTime.now().toIso8601String()
    };
  }

  String get formattedDate {
    return formatter.format(date);
  }

  String get formattedInserDateTime {
    return formatter.format(insertDateTime!) +
        " " +
        formatterTime.format(insertDateTime!);
  }
}

enum Category { travel, leisure, work }

final categoryIcon = {
  Category.travel: Icons.airplane_ticket,
  Category.leisure: Icons.coffee,
  Category.work: Icons.work,
};

enum Priority { low, medium, hight }

Map<Priority, Widget> getPriorityIcon(final bool disabled) {
  return {
    Priority.low: Row(
      children: [
        Icon(
          Icons.label_important,
          color: disabled ? const Color.fromARGB(109, 0, 0, 0) : Colors.green,
          size: 35,
        ),
      ],
    ),
    Priority.medium: Row(
      children: [
        Icon(
          Icons.label_important,
          color: disabled ? const Color.fromARGB(109, 0, 0, 0) : Colors.orange,
          size: 35,
        ),
      ],
    ),
    Priority.hight: Row(
      children: [
        Icon(
          Icons.label_important,
          color: disabled ? const Color.fromARGB(109, 0, 0, 0) : Colors.red,
          size: 35,
        ),
      ],
    ),
  };
}
