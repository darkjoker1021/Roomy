import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:roomy/app/data/lists.dart';
import 'package:roomy/app/modules/shopping/controllers/shopping_controller.dart';
import 'package:roomy/core/widgets/filter_chip.dart';

class ShoppingFilterChips extends StatelessWidget {
  final ShoppingController controller;
  const ShoppingFilterChips({required this.controller, super.key});

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