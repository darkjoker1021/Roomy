import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:roomy/app/data/task.dart';
import '../controllers/tasks_controller.dart';

class TasksView extends GetView<TasksController> {
  const TasksView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks di Casa'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.tasks.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return Column(
          children: [
            // Filtri categoria
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.categories.length,
                itemBuilder: (context, index) {
                  final category = controller.categories[index];
                  final isSelected = controller.selectedCategory.value == category;
                  
                  return Container(
                    margin: const EdgeInsets.only(left: 8),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        controller.changeCategory(category);
                      },
                      backgroundColor: Colors.grey.shade200,
                      selectedColor: Colors.blue.shade100,
                    ),
                  );
                },
              ),
            ),
            
            // Lista tasks
            Expanded(
              child: controller.filteredTasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.task_alt,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nessuna task trovata',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Aggiungi una nuova task per iniziare',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = controller.filteredTasks[index];
                        return _buildTaskCard(context, task);
                      },
                    ),
            ),
          ],
        );
      }),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        backgroundColor: Colors.blue.shade600,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, Task task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                    color: controller.getPriorityColor(task.priority).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
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
            
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                task.description,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            ],
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    task.category,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                Text(
                  'Assegnato a: ${task.assignedTo}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                
                const Spacer(),
                
                if (task.dueDate != null)
                  Text(
                    'Scadenza: ${DateFormat('dd/MM/yyyy').format(task.dueDate!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: task.dueDate!.isBefore(DateTime.now()) && !task.isCompleted
                          ? Colors.red
                          : Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => controller.toggleTaskCompletion(
                      task.id,
                      !task.isCompleted,
                    ),
                    icon: Icon(
                      task.isCompleted ? Icons.undo : Icons.check,
                      size: 20,
                    ),
                    label: Text(
                      task.isCompleted ? 'Riapri' : 'Completa',
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: task.isCompleted ? Colors.orange : Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                IconButton(
                  onPressed: () => _showEditTaskDialog(context, task),
                  icon: const Icon(Icons.edit, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.blue.shade100,
                    foregroundColor: Colors.blue.shade700,
                  ),
                ),
                
                const SizedBox(width: 8),
                
                IconButton(
                  onPressed: () => _showDeleteConfirmation(context, task),
                  icon: const Icon(Icons.delete, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red.shade100,
                    foregroundColor: Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtri'),
        content: Obx(() => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Stato tasks:'),
            ...controller.filters.map((filter) => RadioListTile<String>(
              title: Text(filter),
              value: filter,
              groupValue: controller.selectedFilter.value,
              onChanged: (value) {
                controller.changeFilter(value!);
                Navigator.pop(context);
              },
            )),
          ],
        )),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    _showTaskDialog(context, null);
  }

  void _showEditTaskDialog(BuildContext context, Task task) {
    _showTaskDialog(context, task);
  }

  void _showTaskDialog(BuildContext context, Task? task) {
    final titleController = TextEditingController(text: task?.title ?? '');
    final descriptionController = TextEditingController(text: task?.description ?? '');
    final assignedToController = TextEditingController(text: task?.assignedTo ?? '');
    
    String selectedCategory = task?.category ?? 'Pulizie';
    int selectedPriority = task?.priority ?? 1;
    DateTime? selectedDueDate = task?.dueDate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task == null ? 'Nuova Task' : 'Modifica Task'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Titolo',
                  border: OutlineInputBorder(),
                ),
              ),
              
              const SizedBox(height: 16),
              
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrizione',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  border: OutlineInputBorder(),
                ),
                items: controller.categories.skip(1).map((category) => 
                  DropdownMenuItem(value: category, child: Text(category))
                ).toList(),
                onChanged: (value) => selectedCategory = value!,
              ),
              
              const SizedBox(height: 16),
              
              TextField(
                controller: assignedToController,
                decoration: const InputDecoration(
                  labelText: 'Assegnato a',
                  border: OutlineInputBorder(),
                ),
              ),
              
              const SizedBox(height: 16),
              
              DropdownButtonFormField<int>(
                value: selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'Priorità',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Bassa')),
                  DropdownMenuItem(value: 2, child: Text('Media')),
                  DropdownMenuItem(value: 3, child: Text('Alta')),
                ],
                onChanged: (value) => selectedPriority = value!,
              ),
              
              const SizedBox(height: 16),
              
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  selectedDueDate != null
                      ? 'Scadenza: ${DateFormat('dd/MM/yyyy').format(selectedDueDate!)}'
                      : 'Seleziona scadenza (opzionale)',
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDueDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    selectedDueDate = date;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty && assignedToController.text.isNotEmpty) {
                if (task == null) {
                  controller.addTask(
                    title: titleController.text,
                    description: descriptionController.text,
                    category: selectedCategory,
                    assignedTo: assignedToController.text,
                    dueDate: selectedDueDate,
                    priority: selectedPriority,
                  );
                } else {
                  controller.updateTask(
                    taskId: task.id,
                    title: titleController.text,
                    description: descriptionController.text,
                    category: selectedCategory,
                    assignedTo: assignedToController.text,
                    dueDate: selectedDueDate,
                    priority: selectedPriority,
                  );
                }
              }
            },
            child: Text(task == null ? 'Aggiungi' : 'Salva'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Task task) {
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