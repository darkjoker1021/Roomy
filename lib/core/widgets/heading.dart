import 'package:roomy/core/theme/palette.dart';
import 'package:flutter/material.dart';
import 'package:roomy/core/widgets/back_button.dart';

class Heading extends StatelessWidget {
  const Heading({super.key, required this.title, this.subtitle, this.backButton = false});

  final String title;
  final String? subtitle;
  final bool backButton;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        backButton ? Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const CustomBackButton(),
            
            const SizedBox(width: 10),

            Text(
              title,
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ],
        )
        : Text(
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