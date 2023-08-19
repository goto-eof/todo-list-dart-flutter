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

enum Category { travel, leisure, work }

final categoryIcon = {
  Category.travel: Icons.airplane_ticket,
  Category.leisure: Icons.music_note,
  Category.work: Icons.work
};

enum Priority { low, medium, hight }

final priorityIcon = {
  Priority.low: Icons.brightness_low,
  Priority.medium: Icons.brightness_medium,
  Priority.hight: Icons.brightness_high
};
