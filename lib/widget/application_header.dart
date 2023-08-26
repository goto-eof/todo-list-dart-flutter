import 'package:flutter/material.dart';

class ApplicationHeader extends StatelessWidget {
  const ApplicationHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          "assets/images/icon-48.png",
        ),
        const SizedBox(
          width: 5,
        ),
        const Text("To Do List"),
      ],
    );
  }
}
