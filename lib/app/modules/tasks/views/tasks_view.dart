import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:roomy/app/modules/tasks/widgets/empty_task_placeholder.dart';
import 'package:roomy/app/routes/app_pages.dart';
import '../controllers/tasks_controller.dart';
import '../widgets/task_card.dart';
import '../widgets/filter_chips_row.dart';
import '../widgets/filter_dialog.dart';

class TasksView extends GetView<TasksController> {
  const TasksView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks di Casa'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => showFilterDialog(context, controller),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.tasks.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            FilterChipsRow(controller: controller),
            Expanded(
              child: controller.filteredTasks.isEmpty
                  ? const EmptyTasksPlaceholder()
                  : ListView.builder(
                      padding: const EdgeInsets.all(15),
                      itemCount: controller.filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = controller.filteredTasks[index];
                        return TaskCard(
                          task: task,
                          controller: controller,
                          onEdit: () {
                            Get.toNamed(Routes.ADD, arguments: {
                              'task': task,
                            });
                          },
                          onDelete: () => _showDeleteConfirmation(context, task),
                        );
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }

  void _showDeleteConfirmation(BuildContext context, task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma eliminazione'),
        content: Text('Sei sicuro di voler eliminare la task "${task.title}"?'),
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Elimina', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}