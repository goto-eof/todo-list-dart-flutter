import 'package:flutter/material.dart';
import 'package:todolistapp/model/todo.dart';

class SortByPanel extends StatefulWidget {
  const SortByPanel(
      {super.key, required this.sortByPriority, required this.sortByDate});

  final Function(bool) sortByPriority;
  final Function(bool) sortByDate;

  @override
  State<StatefulWidget> createState() {
    return _ItemMenuState();
  }
}

class _ItemMenuState extends State<SortByPanel> {
  Priority? selectedMenu;
  bool reversePriority = false;
  bool reverseDate = false;

  @override
  Widget build(Object context) {
    return Row(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () {
                widget.sortByPriority(reversePriority);
                setState(
                  () {
                    reversePriority = !reversePriority;
                  },
                );
              },
              icon: Icon(reversePriority
                  ? Icons.keyboard_double_arrow_down
                  : Icons.keyboard_double_arrow_up),
            ),
            const Text("Priority")
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: () {
                widget.sortByDate(reverseDate);
                setState(
                  () {
                    reverseDate = !reverseDate;
                  },
                );
              },
              icon: Icon(reverseDate
                  ? Icons.keyboard_double_arrow_down
                  : Icons.keyboard_double_arrow_up),
            ),
            const Text("Date")
          ],
        ),
      ],
    );
  }
}
