// widgets/task_card.dart
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:roomy/app/data/task.dart';
import 'package:roomy/core/theme/palette.dart';
import 'package:roomy/core/widgets/button.dart';
import '../controllers/tasks_controller.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final TasksController controller;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    required this.task,
    required this.controller,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Theme.of(context).colorScheme.secondary,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      color: task.isCompleted ? Colors.grey : null,
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(task.category, style: TextStyle(fontSize: 12, color: Colors.blue.shade700)),
                ),

                const SizedBox(width: 5),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: controller.getPriorityColor(task.priority).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),

                  child: Text(
                    controller.getPriorityText(task.priority),
                    style: TextStyle(
                      fontSize: 12,
                      color: controller.getPriorityColor(task.priority),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            // Descrizione
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                task.description,
                style: TextStyle(
                  color: Palette.labelColor,
                  decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            ],
            const SizedBox(height: 12),
            // Info
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Assegnato a: ${task.assignedTo}', style: const TextStyle(fontSize: 12, color: Palette.labelColor)),

                if (task.dueDate != null)
                  Text(
                    'Scadenza: ${DateFormat('dd/MM/yyyy').format(task.dueDate!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: task.dueDate!.isBefore(DateTime.now()) && !task.isCompleted
                          ? Colors.red
                          : Palette.labelColor,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 15),
            // Pulsanti
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      height: 40,
                      onPressed: () => controller.toggleTaskCompletion(task.id, !task.isCompleted),
                      icon: Icon(
                        task.isCompleted ? FluentIcons.arrow_redo_16_filled : FluentIcons.checkmark_20_filled,
                        size: 20, 
                        color: Colors.white
                      ),
                      text: task.isCompleted ? 'Riapri' : 'Completa',
                      backgroundColor: task.isCompleted ? Colors.orange : Colors.green,
                      borderColor: task.isCompleted ? Colors.orange : Colors.green,
                    ),
                  ),
              
                  const SizedBox(width: 5),
              
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(FluentIcons.edit_20_filled, size: 20),
                    color: Colors.blue,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.blue.withValues(alpha: 0.1),
                      shape: const CircleBorder(),
                    ),
                  ),
              
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(FluentIcons.delete_20_filled, size: 20),
                    color: Colors.red,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red.withValues(alpha: 0.1),
                      shape: const CircleBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}