import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:todolistapp/model/todo.dart';
import 'package:todolistapp/service/export/file_content_generator.dart';
import 'package:todolistapp/service/export/strategies/format_strategy.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class FormatPdfStrategy implements FormatStrategy {
  @override
  Future<Uint8List> generateContent(List<ToDo> todos) async {
    final pdf = pw.Document();
    const double fontSize = 7;

    rowDecoration(final bool darkBackground) {
      return pw.BoxDecoration(
        color: darkBackground ? const PdfColor(0.8, 0.8, 0.8) : null,
        border: pw.Border.all(
          color: const PdfColor(0, 0, 0),
          width: 1,
        ),
      );
    }

    pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Center(
              child: pw.Table(children: [
                pw.TableRow(
                  decoration: rowDecoration(true),
                  children: [
                    pw.Text("Done",
                        style: const pw.TextStyle(fontSize: fontSize)),
                    pw.Text("Priority",
                        style: const pw.TextStyle(fontSize: fontSize)),
                    pw.Text("ToDo",
                        style: const pw.TextStyle(fontSize: fontSize)),
                    pw.Text("Category",
                        style: const pw.TextStyle(fontSize: fontSize)),
                    pw.Text("Date",
                        style: const pw.TextStyle(fontSize: fontSize)),
                  ],
                ),
                ...todos.map(
                  (todo) => pw.TableRow(
                    decoration: rowDecoration(false),
                    children: [
                      pw.Column(
                        mainAxisSize: pw.MainAxisSize.max,
                        children: [
                          pw.Text(todo.done ? "YES" : "NO",
                              style: const pw.TextStyle(fontSize: fontSize))
                        ],
                      ),
                      pw.Text(todo.priority.name,
                          style: const pw.TextStyle(fontSize: fontSize)),
                      pw.Text(todo.text,
                          style: const pw.TextStyle(fontSize: fontSize)),
                      pw.Text(todo.category.name,
                          style: const pw.TextStyle(fontSize: fontSize)),
                      pw.Text(todo.formattedDate,
                          style: const pw.TextStyle(fontSize: fontSize)),
                    ],
                  ),
                ),
              ]),
            )
          ]; // Center
        })); // Page
    return await pdf.save();
  }

  @override
  FileType getFileType() {
    return FileType.pdf;
  }
}
