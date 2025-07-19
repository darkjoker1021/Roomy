import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:roomy/app/data/lists.dart';
import 'package:roomy/core/widgets/filter_chip.dart';
import '../controllers/tasks_controller.dart';

class TasksFilterChips extends StatelessWidget {
  final TasksController controller;
  const TasksFilterChips({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          // Filtro: Stato
          CustomFilterChip(
            value: controller.selectedFilter.value,
            hint: 'Stato',
            items: controller.filters,
            icon: FluentIcons.filter_20_filled,
            onChanged: (value) => controller.changeFilter(value),
          ),

          // Filtro: Categoria
          CustomFilterChip(
            value: controller.selectedCategory.value,
            hint: 'Categoria',
            items: taskCategories,
            icon: FluentIcons.tag_20_filled,
            onChanged: (value) => controller.changeCategory(value),
          ),

          // Filtro: Priorità
          CustomFilterChip(
            value: controller.selectedPriority.value,
            hint: 'Priorità',
            items: const ['Alta', 'Media', 'Bassa'],
            icon: FluentIcons.gauge_20_filled,
            onChanged: (value) => controller.changePriority(value),
          ),

          // Filtro: Assegnata a
          CustomFilterChip(
            value: controller.selectedAssignedTo.value,
            hint: 'Assegnata a',
            items: controller.houseMembers.map((m) => m.name).toList(),
            icon: FluentIcons.people_community_20_filled,
            onChanged: (value) => controller.changeAssignedTo(value),
          ),

          // Pulsante Reset
          IntrinsicWidth(
            child: IconButton(
              onPressed: () => controller.resetFilters(),
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              icon: const Icon(FluentIcons.filter_dismiss_20_filled),
            ),
          ),
        ],
      ),
    ));
  }
}
