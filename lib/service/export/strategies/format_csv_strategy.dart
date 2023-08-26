import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:todolistapp/model/todo.dart';
import 'package:todolistapp/service/export/file_content_generator.dart';
import 'package:todolistapp/service/export/strategies/format_strategy.dart';

class FormatCsvStrategy implements FormatStrategy {
  @override
  Future<Uint8List> generateContent(List<ToDo> todos) async {
    final List<String> rowHeader = [
      "Done",
      "Priority",
      "ToDo",
      "Category",
      "Date",
      "Creation TS"
    ];
    List<List<dynamic>> rows = [];
    rows.add(rowHeader);
    for (ToDo todo in todos) {
      List<dynamic> dataRow = [];
      dataRow.add(todo.done ? 'YES' : "NO");
      dataRow.add(todo.priority.name);
      dataRow.add(todo.text);
      dataRow.add(todo.category.name);
      dataRow.add(todo.date.toIso8601String());
      dataRow.add(todo.insertDateTime!.toIso8601String());
      rows.add(dataRow);
    }
    String csv = const ListToCsvConverter().convert(rows);

    final bytes = utf8.encode(csv);
    final Uint8List unit8List = Uint8List.fromList(bytes);
    return unit8List;
  }

  @override
  FileType getFileType() {
    return FileType.csv;
  }
}
