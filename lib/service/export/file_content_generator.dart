import 'dart:typed_data';

import 'package:todolistapp/model/todo.dart';
import 'package:todolistapp/service/export/strategies/export_format_csv_strategy.dart';
import 'package:todolistapp/service/export/strategies/export_format_pdf_strategy.dart';
import 'package:todolistapp/service/export/strategies/export_format_strategy.dart';

enum FileType { pdf, csv }

class FileContentGenerator {
  static List<ExportFormatStrategy> strategies = [
    ExportFormatCsvStrategy(),
    ExportFormatPdfStrategy()
  ];

  FileContentGenerator._();

  factory FileContentGenerator() => _privateConstructor;
  static final _privateConstructor = FileContentGenerator._();

  Future<Uint8List> convertToUint8List(List<ToDo> todos, FileType fileType) {
    return strategies
        .firstWhere((todo) => todo.getFileType() == fileType)
        .generateContent(todos);
  }
}
