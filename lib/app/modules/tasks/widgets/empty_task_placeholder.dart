// widgets/empty_tasks_placeholder.dart
import 'package:flutter/material.dart';

class EmptyTasksPlaceholder extends StatelessWidget {
  const EmptyTasksPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_alt, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('Nessuna task trovata', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Text('Aggiungi una nuova task per iniziare', style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}