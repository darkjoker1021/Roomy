import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:roomy/core/widgets/button.dart';
import 'package:roomy/core/widgets/heading.dart';
import '../controllers/tasks_controller.dart';
import 'package:roomy/core/widgets/text_field.dart';
import 'package:roomy/app/data/task.dart';

void showTaskFormModal(BuildContext context, TasksController controller, {Task? task}) {
  final titleController = TextEditingController(text: task?.title ?? '');
  final descriptionController = TextEditingController(text: task?.description ?? '');

  String selectedCategory = task?.category ?? 'Pulizie';
  int selectedPriority = task?.priority ?? 1;
  DateTime? selectedDueDate = task?.dueDate;
  String? selectedMember = task?.assignedTo;

  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    useRootNavigator: true,
    useSafeArea: true,
    scrollControlDisabledMaxHeightRatio: 0.5,
    isScrollControlled: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return SingleChildScrollView(
          padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Heading(
                  title: titleController.text.isEmpty ? 'Aggiungi Task' : 'Modifica Task',
                  subtitle: "Modifica i dettagli della task",
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                "Titolo della task*",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 5),

              CustomTextField(
                controller: titleController,
                hintText: task == null ? "Titolo della task*" : "Modifica titolo*",
                obscureText: false,
              ),

              const SizedBox(height: 15),

              const Text(
                "Descrizione (opzionale)",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 5),

              CustomTextField(
                controller: descriptionController,
                hintText: task == null ? "Descrizione (opzionale)" : "Modifica descrizione (opzionale)",
                obscureText: false,
                keyboardType: TextInputType.multiline,
                maxLines: 3,
              ),

              const SizedBox(height: 15),

              const Text(
                "Categoria",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 5),

              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                    borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                items: controller.categories.skip(1).map((category) => 
                  DropdownMenuItem(value: category, child: Text(category))
                ).toList(),
                onChanged: (value) => setState(() {
                  selectedCategory = value!;
                }),
              ),

              const SizedBox(height: 15),

              Obx(() {
                if (controller.isLoadingMembers.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                return _buildMemberSelector(selectedMember, (member) {
                  setState(() {
                    selectedMember = member;
                  });
                }, controller, context);
              }),

              const SizedBox(height: 15),

              const Text(
                "Priorità",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 5),

              DropdownButtonFormField<int>(
                value: selectedPriority,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                    borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 1,
                    child: Row(
                      children: [
                        Icon(FluentIcons.gauge_20_filled, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Bassa'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 2,
                    child: Row(
                      children: [
                        Icon(FluentIcons.gauge_20_filled, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Media'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 3,
                    child: Row(
                      children: [
                        Icon(FluentIcons.gauge_20_filled, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Alta'),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) => setState(() {
                  selectedPriority = value!;
                }),
              ),

              const SizedBox(height: 15),

              const Text(
                "Scadenza (opzionale)",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 5),

              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDueDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() {
                      selectedDueDate = date;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      const Icon(FluentIcons.calendar_ltr_20_regular, color: Colors.grey),
                      const SizedBox(width: 12),
                      Text(
                        selectedDueDate != null
                            ? 'Scadenza: ${DateFormat('dd/MM/yyyy').format(selectedDueDate!)}'
                            : 'Seleziona scadenza (opzionale)',
                      ),
                      const Spacer(),
                      if (selectedDueDate != null)
                        IconButton(
                          icon: const Icon(FluentIcons.dismiss_20_regular, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              selectedDueDate = null;
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              CustomButton(
                onPressed: () {
                  if (titleController.text.isNotEmpty && selectedMember != null) {
                    if (task == null) {
                      controller.addTask(
                        title: titleController.text,
                        description: descriptionController.text,
                        category: selectedCategory,
                        assignedTo: selectedMember!,
                        dueDate: selectedDueDate,
                        priority: selectedPriority,
                      );
                    } else {
                      controller.updateTask(
                        taskId: task.id,
                        title: titleController.text,
                        description: descriptionController.text,
                        category: selectedCategory,
                        assignedTo: selectedMember!,
                        dueDate: selectedDueDate,
                        priority: selectedPriority,
                      );
                    }
                    Get.back();
                  }
                },
                text: task == null ? 'Aggiungi' : 'Salva',
              ),
            ],
          ),
        );
      },
    ),
  );
}

Widget _buildMemberSelector(String? selectedMember, Function(String) onMemberSelected, TasksController controller, BuildContext context, {Task? task}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Assegna a:*',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),

      const SizedBox(height: 5),

      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(15),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedMember,
            hint: const Text('Seleziona un membro'),
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down),
            items: [
              DropdownMenuItem<String>(
                value: task?.assignedTo ?? 'Tutti i membri',
                child: Row(
                  children: [
                    Icon(FluentIcons.people_community_20_filled, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8),
                    const Text('Tutti i membri'),
                  ],
                ),
              ),
              ...controller.houseMembers.map((member) {
                final name = member['name'] ?? member['email'] ?? 'Membro';
                return DropdownMenuItem<String>(
                  value: name,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          name[0].toUpperCase(),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                );
              }),
            ],
            onChanged: (newValue) {
              if (newValue != null) onMemberSelected(newValue);
            },
          ),
        ),
      ),
    ],
  );
}