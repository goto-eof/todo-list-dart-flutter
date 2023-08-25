import 'package:flutter/material.dart';

enum ViewMode { normal, compact }

class ViewModePanel extends StatelessWidget {
  const ViewModePanel(
      {super.key, required this.changeViewMode, required this.viewMode});
  final Function(ViewMode) changeViewMode;
  final ViewMode viewMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              changeViewMode(ViewMode.normal);
            },
            icon: Icon(
              Icons.view_column,
              color: viewMode == ViewMode.normal ? Colors.orange : null,
            ),
          ),
          IconButton(
            onPressed: () {
              changeViewMode(ViewMode.compact);
            },
            icon: Icon(
              Icons.view_compact,
              color: viewMode == ViewMode.compact ? Colors.orange : null,
            ),
          ),
        ],
      ),
    );
  }
}
