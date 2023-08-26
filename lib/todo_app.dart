import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todolistapp/model/todo.dart';
import 'package:todolistapp/service/todo_service.dart';
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
  final ToDoService toDoService = ToDoService();
  var _isLoading = true;
  var _toggleViewArchivedButton = true;
  bool _disableSortByPriorityButton = false;
  SharedPreferences? sharedPreferences;
  ViewMode _viewMode = ViewMode.normal;
  PackageInfo? packageInfo;
  @override
  void initState() {
    _loadToDoList();
    _getSharedPreferences();
    _loadPreferences();
    super.initState();
  }

  Future<SharedPreferences> _getSharedPreferences() async {
    sharedPreferences ??= await SharedPreferences.getInstance();
    packageInfo ??= await PackageInfo.fromPlatform();
    return sharedPreferences!;
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
          if (a.priority.index > b.priority.index) {
            return 1 * (reverse ? -1 : 1);
          }
          if (a.priority.index < b.priority.index) {
            return -1 * (reverse ? -1 : 1);
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
          if (a.date.compareTo(b.date) > 0) {
            return 1 * (reverse ? -1 : 1);
          }
          if (a.date.compareTo(b.date) < 0) {
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
          onPressed: () {
            showDialog(context: context, builder: _aboutDialogBuilder);
          },
          icon: const Icon(Icons.info)),
      IconButton(
          onPressed: () {
            showModalBottomSheet(
                isScrollControlled: false,
                constraints: const BoxConstraints(minWidth: double.infinity),
                context: context,
                builder: _retrieveInsertToDoItemForm);
          },
          icon: const Icon(Icons.add)),
    ];
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
              width: 50,
            )
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
                    ? const Text("No data found")
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
