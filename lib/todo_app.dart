import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart' as FilePicker;
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todolistapp/model/secondary_menu_items.dart';
import 'package:todolistapp/model/todo.dart';
import 'package:todolistapp/service/export/file_content_generator.dart';
import 'package:todolistapp/service/import/file_content_loader.dart';
import 'package:todolistapp/service/todo_db_service.dart';
import 'package:todolistapp/widget/application_header.dart';
import 'package:todolistapp/widget/insert_todo_item_form.dart';
import 'package:todolistapp/widget/sort_by_panel.dart';
import 'package:todolistapp/widget/todo_item.dart';
import 'package:todolistapp/widget/view_mode_panel.dart';
import 'package:todolistapp/widget/about_dialog.dart' as ToDoListAboutDialog;

class ToDoApp extends StatefulWidget {
  const ToDoApp({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ToDoAppState();
  }
}

class _ToDoAppState extends State<ToDoApp> {
  List<ToDo> todos = [];
  final ToDoDbService toDoService = ToDoDbService();
  var _isLoading = true;
  var _toggleViewArchivedButton = true;
  bool _disableSortByPriorityButton = false;
  SharedPreferences? sharedPreferences;
  ViewMode _viewMode = ViewMode.normal;
  PackageInfo? packageInfo;
  bool _importingData = false;
  bool _exportingData = false;
  @override
  void initState() {
    _loadToDoList();
    _getSharedPreferences();
    _initInstances();
    _loadPreferences();
    super.initState();
  }

  Future<SharedPreferences> _getSharedPreferences() async {
    sharedPreferences ??= await SharedPreferences.getInstance();
    return sharedPreferences!;
  }

  Future<void> _initInstances() async {
    packageInfo ??= await PackageInfo.fromPlatform();
  }

  void _loadPreferences() async {
    SharedPreferences sharedPreferences = await _getSharedPreferences();
    String? viewMode = sharedPreferences.getString('viewMode');
    if (viewMode != null) {
      ViewMode convertedViewMode =
          ViewMode.values.where((element) => element.name == viewMode).first;
      setState(() {
        _viewMode = convertedViewMode;
      });
    }
  }

  void _loadToDoList() async {
    try {
      List<ToDo> list = await toDoService.list();
      setState(
        () {
          _isLoading = false;
          todos = list;
          _sortByPriority(true);
        },
      );
    } catch (exception) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(exception.toString()),
        ),
      );
    }
  }

  Widget _retrieveInsertToDoItemForm(BuildContext context) {
    return InsertTodoItemForm(
      onAddTodo: _addTodoItemToTheList,
    );
  }

  void _addTodoItemToTheList(ToDo todo) async {
    int id = await toDoService.insert(todo);
    todo.insertDateTime = DateTime.now();
    if (_toggleViewArchivedButton == false) {
      await _viewActive();
    }
    if (Navigator.of(context).mounted) {
      setState(
        () {
          todo.id = id;
          todos.insert(0, todo);
        },
      );
      _updateDisableSortByPriority();
    }
  }

  bool _checkIfAllItemsHasSamePriority() {
    Priority priority = todos[0].priority;
    ToDo? toDoWithOtherPriority =
        todos.where((ToDo todo) => todo.priority != priority).firstOrNull;
    return toDoWithOtherPriority == null;
  }

  ToDoItem _toDoItemBuilder(BuildContext context, int index) {
    return ToDoItem(
        todo: todos[index],
        deleteItem: _deleteTodo,
        setItemToDone: _toggleDoneValue,
        setPriority: _setPriority,
        archiveItem: _archiveItem,
        viewMode: _viewMode);
  }

  void _undoToDoDeletion(index, ToDo todo) async {
    int id = await toDoService.insert(todo);
    setState(
      () {
        todo.id = id;
        todos.insert(index, todo);
      },
    );
  }

  Widget _aboutDialogBuilder(BuildContext context) {
    return ToDoListAboutDialog.AboutDialog(
      applicationName: "To Do List",
      applicationSnapName: "todolistapp",
      applicationIcon: Image.asset("assets/images/icon-48.png"),
      applicationVersion: packageInfo!.version,
      applicationLegalese: "MIT",
      applicationDeveloper: "Andrei Dodu",
    );
  }

  void _toggleDoneValue(ToDo todo) async {
    setState(() {
      todo.done = todo.done ? false : true;
    });
    await toDoService.update(todo);
  }

  void _archiveItem(ToDo todo) async {
    setState(() {
      todo.archived = todo.archived ? false : true;
      todos.remove(todo);
    });
    await toDoService.update(todo);
    _updateDisableSortByPriority();
  }

  void _setPriority(final Priority priority, final ToDo todo) async {
    setState(() {
      todo.priority = priority;
    });
    await toDoService.update(todo);
  }

  void _deleteTodo(ToDo todo) async {
    final index = todos.indexOf(todo);
    await toDoService.delete(todo.id);
    setState(
      () {
        todos = todos.where((element) => element.id != todo.id).toList();
      },
    );

    if (!context.mounted) {
      return;
    }
    ScaffoldMessengerState scaffoldMessengerState =
        ScaffoldMessenger.of(context);
    scaffoldMessengerState.clearSnackBars();
    scaffoldMessengerState.showSnackBar(
      SnackBar(
        action: SnackBarAction(
            label: "Undo",
            onPressed: () {
              _undoToDoDeletion(index, todo);
            }),
        duration: const Duration(seconds: 5),
        content: const Text("Do you want to undo the change?"),
      ),
    );
    _updateDisableSortByPriority();
  }

  void _updateDisableSortByPriority() {
    setState(() {
      _disableSortByPriorityButton = _checkIfAllItemsHasSamePriority();
    });
  }

  void _viewArchived() async {
    setState(() {
      _isLoading = true;
    });
    List<ToDo> list = await toDoService.list(archived: true);

    setState(() {
      _toggleViewArchivedButton = !_toggleViewArchivedButton;
      todos = list;
      _isLoading = false;
    });
    _updateDisableSortByPriority();
  }

  Future<void> _viewActive() async {
    setState(() {
      _isLoading = true;
    });
    List<ToDo> list = await toDoService.list(archived: false);

    setState(() {
      _toggleViewArchivedButton = !_toggleViewArchivedButton;
      todos = list;
      _isLoading = false;
    });
    _updateDisableSortByPriority();
  }

  void _sortByPriority(final bool reverse) async {
    setState(() {
      todos.sort(
        (ToDo a, ToDo b) {
          if (a.done) {
            if (!b.done) {
              return 1;
            }
            return 0;
          }
          if (a.priority.index > b.priority.index) {
            if (b.done) {
              return 0;
            }
            return 1 * (reverse ? -1 : 1);
          }
          if (a.priority.index < b.priority.index) {
            if (b.done) {
              return 0;
            }
            return -1 * (reverse ? -1 : 1);
          }
          if (!a.done && !b.done && a.priority.index == b.priority.index) {
            if (a.date.compareTo(b.date) > 0) {
              return -1 * (reverse ? -1 : 1);
            }
            if (a.date.compareTo(b.date) < 0) {
              return 1 * (reverse ? -1 : 1);
            }
            return 0;
          }
          return 0;
        },
      );
    });
  }

  void _sortByDate(final bool reverse) async {
    setState(() {
      todos.sort(
        (ToDo a, ToDo b) {
          if (a.done) {
            if (!b.done) {
              return 1;
            }
            return 0;
          }
          if (a.date.compareTo(b.date) > 0) {
            if (b.done) {
              return 0;
            }
            return 1 * (reverse ? -1 : 1);
          }
          if (a.date.compareTo(b.date) < 0) {
            if (b.done) {
              return 0;
            }
            return -1 * (reverse ? -1 : 1);
          }
          return 0;
        },
      );
    });
  }

  void _changeViewMode(ViewMode newViewMode) async {
    SharedPreferences sharedPreferences = await _getSharedPreferences();
    sharedPreferences.setString("viewMode", newViewMode.name);
    setState(() {
      _viewMode = newViewMode;
    });
  }

  List<Widget> _generateApplicationButtons() {
    return [
      IconButton(
          tooltip: "About",
          onPressed: () {
            showDialog(context: context, builder: _aboutDialogBuilder);
          },
          icon: const Icon(Icons.info)),
      IconButton(
          tooltip: "Add new TO DO",
          onPressed: _openAddNewToDoForm,
          icon: const Icon(Icons.add)),
    ];
  }

  void _openAddNewToDoForm() {
    showModalBottomSheet(
        isScrollControlled: false,
        constraints: const BoxConstraints(minWidth: double.infinity),
        context: context,
        builder: _retrieveInsertToDoItemForm);
  }

  Widget _calculatedViewArchiveButton() {
    return _toggleViewArchivedButton
        ? OutlinedButton(
            style: const ButtonStyle(
              shadowColor:
                  MaterialStatePropertyAll(Color.fromARGB(255, 59, 92, 255)),
              foregroundColor:
                  MaterialStatePropertyAll(Color.fromARGB(255, 170, 182, 8)),
            ),
            onPressed: _viewArchived,
            child: const Text("View archived tasks"),
          )
        : OutlinedButton(
            style: const ButtonStyle(
              foregroundColor: MaterialStatePropertyAll(Colors.green),
            ),
            onPressed: _viewActive,
            child: const Text("View active tasks"),
          );
  }

  void _showOperationInProgressAlert() {
    showAdaptiveDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          actions: [
            OutlinedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: const Text("Close"))
          ],
          content:
              const Text("An operation is already in progress. Please wait."),
        );
      },
    );
  }

  Widget _generateApplicationContent() {
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.only(left: 40),
              child: Row(
                children: [
                  Text(_toggleViewArchivedButton
                      ? "Active tasks (${todos.length})"
                      : "Archived tasks (${todos.length})"),
                ],
              ),
            ),
            const Spacer(),
            _calculatedViewArchiveButton(),
            const SizedBox(
              width: 10,
            ),
            ViewModePanel(changeViewMode: _changeViewMode, viewMode: _viewMode),
            const SizedBox(
              width: 10,
            ),
            SortByPanel(
                sortByPriority: _sortByPriority,
                sortByDate: _sortByDate,
                disableSortByPriorityButton: _disableSortByPriorityButton),
            const SizedBox(
              width: 10,
            ),
            Row(
              children: [
                PopupMenuButton<ImportFileType>(
                  position: PopupMenuPosition.under,
                  icon: _importingData
                      ? Transform.scale(
                          scale: 0.5,
                          child: const CircularProgressIndicator(),
                        )
                      : const Icon(Icons.subdirectory_arrow_left),
                  onSelected: _isOperationInProgress()
                      ? (ImportFileType importFileType) {
                          _showOperationInProgressAlert();
                        }
                      : _importData,
                  tooltip: "Import the TODO items from the file",
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<ImportFileType>>[
                    const PopupMenuItem<ImportFileType>(
                      value: ImportFileType.csv,
                      child: Text('CSV'),
                    ),
                  ],
                ),
                Text(
                  "Import",
                  style: TextStyle(
                    color: _importingData || _exportingData
                        ? const Color.fromARGB(255, 114, 114, 114)
                        : null,
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
              ],
            ),
            Row(
              children: [
                PopupMenuButton<FileType>(
                  position: PopupMenuPosition.under,
                  icon: _exportingData
                      ? Transform.scale(
                          scale: 0.5,
                          child: const CircularProgressIndicator(),
                        )
                      : const Icon(Icons.subdirectory_arrow_right),
                  onSelected: _isOperationInProgress()
                      ? (FileType fileType) {
                          _showOperationInProgressAlert();
                        }
                      : _exportData,
                  tooltip: "Export the TODO items from the current list",
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<FileType>>[
                    const PopupMenuItem<FileType>(
                      value: FileType.csv,
                      child: Text('CSV'),
                    ),
                    const PopupMenuItem<FileType>(
                      value: FileType.pdf,
                      child: Text('PDF'),
                    ),
                  ],
                ),
                Text(
                  "Export",
                  style: TextStyle(
                    color: _importingData || _exportingData
                        ? const Color.fromARGB(255, 114, 114, 114)
                        : null,
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
              ],
            ),
            Row(
              children: [
                PopupMenuButton<SecondaryMenuItem>(
                  position: PopupMenuPosition.under,
                  icon: _exportingData
                      ? Transform.scale(
                          scale: 0.5,
                          child: const CircularProgressIndicator(),
                        )
                      : const Icon(Icons.settings),
                  onSelected: _isOperationInProgress()
                      ? (SecondaryMenuItem menuItem) {
                          _showOperationInProgressAlert();
                        }
                      : _secondaryMenuActionExecute,
                  tooltip: "Other functions",
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<SecondaryMenuItem>>[
                    const PopupMenuItem<SecondaryMenuItem>(
                      value: SecondaryMenuItem.deleteAll,
                      child: Text('Delete all'),
                    ),
                  ],
                ),
                Text(
                  "Actions",
                  style: TextStyle(
                    color: _isOperationInProgress()
                        ? const Color.fromARGB(255, 114, 114, 114)
                        : null,
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
              ],
            ),
          ],
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : todos.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          const Text("No data found"),
                          const SizedBox(
                            height: 10,
                          ),
                          OutlinedButton(
                              onPressed: _openAddNewToDoForm,
                              child: const Text("Add new TO DO"))
                        ],
                      )
                    : ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemBuilder: _toDoItemBuilder,
                        itemCount: todos.length,
                      ),
          ),
        )
      ],
    );
  }

  void _secondaryMenuActionExecute(SecondaryMenuItem secondaryMenuItem) async {
    if (secondaryMenuItem == SecondaryMenuItem.deleteAll) {
      setState(() {
        _isLoading = true;
      });
      for (ToDo todo in todos) {
        await toDoService.delete(todo.id);
      }
      setState(() {
        todos = [];
        _isLoading = false;
      });
    }
  }

  bool _isOperationInProgress() {
    return _exportingData || _importingData || _isLoading;
  }

  void _exportData(FileType fileType) async {
    String? filePathAndName = await FilePicker.FilePicker.platform.saveFile();
    if (filePathAndName != null) {
      setState(() {
        _exportingData = true;
      });
      FileContentGenerator fileGenerator = FileContentGenerator();
      Uint8List data = await fileGenerator.convertToUint8List(todos, fileType);
      final file = File("$filePathAndName.${fileType.name}");
      await file.writeAsBytes(data);
      setState(() {
        _exportingData = false;
      });
    }
  }

  void _importData(ImportFileType fileType) async {
    FilePicker.FilePickerResult? filePickerResult =
        await FilePicker.FilePicker.platform.pickFiles(
            allowMultiple: false,
            type: FilePicker.FileType.custom,
            allowedExtensions: ["csv"]);
    if (filePickerResult != null) {
      setState(() {
        _importingData = true;
      });
      FileContentLoader fileContentLoader = FileContentLoader();
      List<ToDo> importedToDos = await fileContentLoader.convertToToDoList(
          filePickerResult.files[0].path!, fileType);

      if (_toggleViewArchivedButton == false) {
        await _viewActive();
      }
      for (ToDo todo in importedToDos) {
        int id = await toDoService.insert(todo);
        todo.insertDateTime = DateTime.now();
        todo.id = id;
      }
      setState(() {
        todos.addAll(importedToDos);
        _importingData = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ApplicationHeader(),
        backgroundColor: Theme.of(context).primaryColor,
        actions: _generateApplicationButtons(),
      ),
      body: _generateApplicationContent(),
    );
  }
}
