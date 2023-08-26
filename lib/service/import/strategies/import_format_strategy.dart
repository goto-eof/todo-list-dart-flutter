import 'package:todolistapp/model/todo.dart';
import 'package:todolistapp/service/import/file_content_loader.dart';

abstract class ImportFormatStrategy {
  Future<List<ToDo>> loadContent(String fileNameAndPath);
  ImportFileType getFileType();
}
