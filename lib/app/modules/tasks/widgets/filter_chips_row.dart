// widgets/filter_chips_row.dart
import 'package:flutter/material.dart';
import '../controllers/tasks_controller.dart';

class FilterChipsRow extends StatelessWidget {
  final TasksController controller;
  const FilterChipsRow({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              onSelected: (_) => controller.changeCategory(category),
              backgroundColor: Colors.grey.shade200,
              selectedColor: Colors.blue.shade100,
            ),
          );
        },
      ),
    );
  }
}