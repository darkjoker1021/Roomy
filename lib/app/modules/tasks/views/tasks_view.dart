import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:roomy/app/modules/tasks/widgets/empty_task_placeholder.dart';
import 'package:roomy/app/routes/app_pages.dart';
import 'package:roomy/core/widgets/heading.dart';
import 'package:roomy/core/widgets/statistic_header.dart';
import '../controllers/tasks_controller.dart';
import '../widgets/task_card.dart';
import '../widgets/filter_chips.dart';

class TasksView extends GetView<TasksController> {
  const TasksView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          controller.refreshTasks();
        },
        child: Obx(() {
          if (controller.isLoading.value && controller.tasks.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return SafeArea(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con contatore task
                  const Heading(
                    title: 'Tasks',
                    subtitle: 'Gestisci le tue task',
                  ),

                  const SizedBox(height: 20),

                  // Filtri
                  SizedBox(
                    height: 50,
                    child: TasksFilterChips(controller: controller)
                  ),

                  const SizedBox(height: 20),

                  // Lista task o placeholder vuoto
                  controller.filteredTasks.isEmpty
                      ? EmptyTasksPlaceholder(controller: controller)
                      : _buildTasksList(context),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTasksList(BuildContext context) {
    return Column(
      children: [
        // Header con statistiche rapide
        if (controller.tasks.isNotEmpty) ...[
          if (controller.tasks.isNotEmpty) ...[
            StatisticsHeader(
              completati: controller.tasks.where((t) => t.isCompleted).length,
              inCorso: controller.tasks.where((t) => !t.isCompleted).length,
              totali: controller.tasks.length,
              labelCompletati: 'Completate',
              labelInCorso: 'In corso',
              labelTotali: 'Totali',
            ),
            const SizedBox(height: 20),
          ],
        ],
        
        // Lista delle task
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.filteredTasks.length,
          itemBuilder: (context, index) {
            final task = controller.filteredTasks[index];
            return TaskCard(
              task: task,
              controller: controller,
              onEdit: () async {
                final result = await Get.toNamed(
                  Routes.ADD,
                  arguments: task,
                );
                if (result == true) {
                  controller.loadTasks();
                }
              },
              onDelete: () => _showDeleteConfirmation(context, task),
            );
          },
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(FluentIcons.delete_20_filled, color: Colors.red.shade400),
            const SizedBox(width: 8),
            const Text('Eliminazione'),
          ],
        ),
        content: Text(
          'Sei sicuro di voler eliminare la task "${task.title}"?\n\nQuesta azione non può essere annullata.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteTask(task.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
  }
}