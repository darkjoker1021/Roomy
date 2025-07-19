// widgets/empty_tasks_placeholder.dart
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:roomy/core/widgets/button.dart';

class EmptyPlaceholder extends StatelessWidget {
  const EmptyPlaceholder({super.key, required this.task, required this.onPressed});
  final bool task;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              FluentIcons.question_circle_20_filled,
              size: 60,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              task ? 'Nessuna task' : 'Nessun prodotto',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              task ? 'Nessuna task disponibile' : 'Nessun prodotto disponibile nel carrello',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            if (onPressed != null) ...[
              const SizedBox(height: 10),
              CustomButton(
                onPressed: onPressed ?? () {},
                text: 'Mostra tutt${task ? 'e le tasks' : 'i i prodotti'}',
              )
            ]
          ],
        ),
      ),
    );
  }
}