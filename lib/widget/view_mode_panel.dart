import 'package:flutter/material.dart';

enum ViewMode { normal, compact }

class ViewModePanel extends StatelessWidget {
  const ViewModePanel(
      {super.key, required this.changeViewMode, required this.viewMode});
  final Function(ViewMode) changeViewMode;
  final ViewMode viewMode;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: "Classic view",
          onPressed: () {
            changeViewMode(ViewMode.normal);
          },
          icon: Icon(
            Icons.view_stream,
            color: viewMode == ViewMode.normal ? Colors.orange : null,
          ),
        ),
        IconButton(
          tooltip: "Compact view",
          onPressed: () {
            changeViewMode(ViewMode.compact);
          },
          icon: Icon(
            Icons.view_headline,
            color: viewMode == ViewMode.compact ? Colors.orange : null,
          ),
        ),
      ],
    );
  }
}
