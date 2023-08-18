import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();
final formatter = DateFormat.yMd();

class ToDo {
  ToDo(
      {required this.text,
      required this.date,
      required this.category,
      required this.priority})
      : id = uuid.v4();

  final String id;
  final String text;
  final DateTime date;
  final Category category;
  final Priority priority;

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
