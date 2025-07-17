// widgets/filter_dialog.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/tasks_controller.dart';

void showFilterDialog(BuildContext context, TasksController controller) {
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