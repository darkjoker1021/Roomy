import 'package:roomy/core/theme/palette.dart';
import 'package:flutter/material.dart';

class Heading extends StatelessWidget {
  const Heading({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),

        if (subtitle != null)
          Text(
            subtitle!,
            style: const TextStyle(color: Palette.labelColor),
          ),
      ],
    );
  }
}