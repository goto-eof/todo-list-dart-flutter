import 'package:flutter/material.dart';
import 'package:todolistapp/model/todo.dart';

class SortByPanel extends StatefulWidget {
  const SortByPanel(
      {super.key,
      required this.sortByPriority,
      required this.sortByDate,
      required this.disableSortByPriorityButton});

  final Function(bool) sortByPriority;
  final Function(bool) sortByDate;
  final bool disableSortByPriorityButton;

  @override
  State<StatefulWidget> createState() {
    return _ItemMenuState();
  }
}

class _ItemMenuState extends State<SortByPanel> {
  Priority? selectedMenu;
  bool reversePriority = false;
  bool reverseDate = false;

  Color? _calculateSortByPriorityColor() {
    return widget.disableSortByPriorityButton
        ? const Color.fromARGB(255, 78, 76, 76)
        : null;
  }

  void _reversePriority() {
    widget.sortByPriority(reversePriority);
    setState(
      () {
        reversePriority = !reversePriority;
      },
    );
  }

  @override
  Widget build(Object context) {
    return Row(
      children: [
        Row(
          children: [
            IconButton(
              tooltip: "Sort by priority",
              color: _calculateSortByPriorityColor(),
              onPressed:
                  widget.disableSortByPriorityButton ? null : _reversePriority,
              icon: Icon(
                  reversePriority ? Icons.switch_left : Icons.switch_right),
            ),
            Text(
              "Priority",
              style: TextStyle(color: _calculateSortByPriorityColor()),
            )
          ],
        ),
        Row(
          children: [
            IconButton(
              tooltip: "Sort by date",
              onPressed: () {
                widget.sortByDate(reverseDate);
                setState(
                  () {
                    reverseDate = !reverseDate;
                  },
                );
              },
              icon: Icon(reverseDate ? Icons.switch_left : Icons.switch_right),
            ),
            const Text("Date")
          ],
        ),
      ],
    );
  }
}
