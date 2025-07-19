// widgets/empty_tasks_placeholder.dart
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:roomy/app/modules/tasks/controllers/tasks_controller.dart';
import 'package:roomy/core/widgets/button.dart';

class EmptyTasksPlaceholder extends StatelessWidget {
  const EmptyTasksPlaceholder({super.key, required this.controller});
  final TasksController controller;

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
              'Nessuna task trovata',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.tasks.isEmpty
                  ? 'Aggiungi una nuova task per iniziare'
                  : 'Modifica i filtri per vedere altre task',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            if (controller.tasks.isNotEmpty) ...[
              const SizedBox(height: 16),
              CustomButton(
                onPressed: controller.resetFilters,
                text: 'Mostra tutte le task',
              ),
            ],
          ],
        ),
      ),
    );
  }
}