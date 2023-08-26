import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:todolistapp/model/todo.dart';
import 'package:todolistapp/service/import/file_content_loader.dart';
import 'package:todolistapp/service/import/strategies/import_format_strategy.dart';
import 'package:todolistapp/model/todo_status.dart';

class ImportFormatCsvStrategy implements ImportFormatStrategy {
  @override
  ImportFileType getFileType() {
    return ImportFileType.csv;
  }

  @override
  Future<List<ToDo>> loadContent(String fileNameAndPath) async {
    final input = File(fileNameAndPath).openRead();
    final rows = await input
        .transform(utf8.decoder)
        .transform(const CsvToListConverter())
        .toList();

    var todos = rows
        .skip(1)
        .map(
          (fields) => ToDo(
              text: "${fields[2]}",
              date: DateTime.parse(fields[4]),
              category: Category.values
                  .firstWhere((element) => element.name == fields[3]),
              priority: Priority.values
                  .firstWhere((element) => element.name == fields[1]),
              done: fields[0] == ToDoStatus.done.name,
              archived: false),
        )
        .toList();

    return todos;
  }
}
