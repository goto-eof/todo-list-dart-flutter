import 'dart:typed_data';

import 'package:todolistapp/model/todo.dart';
import 'package:todolistapp/service/export/file_content_generator.dart';

abstract class ExportFormatStrategy {
  Future<Uint8List> generateContent(List<ToDo> todos);
  FileType getFileType();
}
