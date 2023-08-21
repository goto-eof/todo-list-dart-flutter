import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();
final formatter = DateFormat.yMd();

class ToDo {
  ToDo(
      {this.id,
      required this.text,
      required this.date,
      required this.category,
      required this.priority});

  var id;
  final String text;
  final DateTime date;
  final Category category;
  final Priority priority;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      "date": date.toIso8601String(),
      "category": category.name,
      "priority": priority.name
    };
  }

  String get formattedDate {
    return formatter.format(date);
  }
}

enum Category { food, travel, leisure, work }

final categoryIcon = {
  Category.travel: Icons.airplane_ticket,
  Category.leisure: Icons.coffee,
  Category.work: Icons.work,
  Category.food: Icons.food_bank
};

enum Priority { low, medium, hight }

final Map<Priority, Widget> priorityIcon = {
  Priority.low: const Row(
    children: [
      Icon(Icons.label_important, color: Colors.green),
      Icon(Icons.label_important_outline, color: Colors.green),
      Icon(Icons.label_important_outline, color: Colors.green)
    ],
  ),
  Priority.medium: const Row(
    children: [
      Icon(
        Icons.label_important,
        color: Colors.orange,
      ),
      Icon(
        Icons.label_important,
        color: Colors.orange,
      ),
      Icon(
        Icons.label_important_outline,
        color: Colors.orange,
      )
    ],
  ),
  Priority.hight: const Row(
    children: [
      Icon(
        Icons.label_important,
        color: Colors.red,
      ),
      Icon(
        Icons.label_important,
        color: Colors.red,
      ),
      Icon(
        Icons.label_important,
        color: Colors.red,
      )
    ],
  ),
};
