import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:roomy/app/data/shopping_item.dart';
import 'package:roomy/app/modules/shopping/widgets/filter_chips.dart';
import 'package:roomy/app/modules/shopping/widgets/shopping_item_card.dart';
import 'package:roomy/app/routes/app_pages.dart';
import 'package:roomy/core/theme/palette.dart';
import 'package:roomy/core/widgets/heading.dart';
import 'package:roomy/core/widgets/statistic_header.dart';
import '../controllers/shopping_controller.dart';

class ShoppingView extends GetView<ShoppingController> {
  const ShoppingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.houseId.value.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.home_outlined,
                  size: 80,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'Devi prima unirti a una casa',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Heading(
                  title: 'Shopping',
                  subtitle: 'Gestisci la tua lista della spesa',
                ),
                const SizedBox(height: 20),
                ShoppingFilterChips(controller: controller),
                const SizedBox(height: 20),
                if (controller.shoppingItems.isNotEmpty) ...[
                  StatisticsHeader(
                    completati: controller.shoppingItems.where((i) => i.isPurchased).length,
                    inCorso: controller.shoppingItems.where((i) => !i.isPurchased).length,
                    totali: controller.shoppingItems.length,
                    labelCompletati: 'Acquistati',
                    labelInCorso: 'Da comprare',
                    labelTotali: 'Totali',
                  ),
                  const SizedBox(height: 20),
                ],

                controller.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : _buildShoppingList(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildShoppingList() {
    return Obx(() {
      if (controller.filteredItems.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FluentIcons.cart_24_filled,
                size: 80,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              const Text(
                'Nessun articolo trovato',
                style: TextStyle(
                  fontSize: 18,
                  color: Palette.labelColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Aggiungi il primo articolo!',
                style: TextStyle(
                  fontSize: 14,
                  color: Palette.labelColor,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.filteredItems.length,
        itemBuilder: (context, index) {
          final item = controller.filteredItems[index];
          return ShoppingItemCard(
            item: item,
            controller: controller,
            onEdit: () {
              Get.toNamed(Routes.ADD, arguments: {
                'shopping': item,
              });
            },
            onDelete: () => _showDeleteConfirmDialog(item),
          );
        },
      );
    });
  }

  void _showDeleteConfirmDialog(ShoppingItem item) {
    Get.dialog(
      AlertDialog(
        title: const Text('Conferma Eliminazione'),
        content: Text('Sei sicuro di voler eliminare "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteItem(item.id);
              Get.back();
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