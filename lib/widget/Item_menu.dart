import 'package:flutter/material.dart';
import 'package:todolistapp/model/todo.dart';

class ItemMenu extends StatefulWidget {
  const ItemMenu({super.key, required this.setPriority});

  final Function(Priority) setPriority;

  @override
  State<StatefulWidget> createState() {
    return _ItemMenuState();
  }
}

class _ItemMenuState extends State<ItemMenu> {
  Priority? selectedMenu;

  @override
  Widget build(Object context) {
    return PopupMenuButton<Priority>(
      initialValue: selectedMenu,
      onSelected: (Priority item) {
        setState(() {
          selectedMenu = item;
        });
        widget.setPriority(item);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<Priority>>[
        const PopupMenuItem<Priority>(
          value: Priority.low,
          child: Text('Set low priority'),
        ),
        const PopupMenuItem<Priority>(
          value: Priority.medium,
          child: Text('Set medium priority'),
        ),
        const PopupMenuItem<Priority>(
          value: Priority.hight,
          child: Text('Set hight priority'),
        ),
      ],
    );
  }
}
