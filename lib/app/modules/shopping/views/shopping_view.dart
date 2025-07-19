import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:roomy/app/data/shopping_item.dart';
import 'package:roomy/app/modules/shopping/widgets/filter_chips.dart';
import 'package:roomy/app/modules/shopping/widgets/shopping_item_card.dart';
import 'package:roomy/app/routes/app_pages.dart';
import 'package:roomy/core/widgets/custom_floating_button.dart';
import 'package:roomy/core/widgets/empty_placeholder.dart';
import 'package:roomy/core/widgets/heading.dart';
import 'package:roomy/core/widgets/loading.dart';
import 'package:roomy/core/widgets/statistic_header.dart';
import '../controllers/shopping_controller.dart';

class ShoppingView extends GetView<ShoppingController> {
  const ShoppingView({super.key});

  @override
  Widget build(BuildContext context) {
    return controller.obx((state) =>
      Scaffold(
        floatingActionButton: const CustomFloatingButton(task: false),
        body: Obx(() {
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

                  controller.filteredItems.isEmpty
                  ? EmptyPlaceholder(
                    task: false,
                    onPressed: controller.filteredItems.isNotEmpty
                    ? () {
                      controller.resetFilters();
                    }
                    : null
                  )
                  : _buildShoppingList(),
                ],
              ),
            ),
          );
        }),
      ),
      onLoading: const Loading()
    );
  }

  Widget _buildShoppingList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.filteredItems.length,
      itemBuilder: (context, index) {
        final item = controller.filteredItems[index];
        return ShoppingItemCard(
          item: item,
          controller: controller,
          onEdit: () => _navigateToEdit(item),
          onDelete: () => _showDeleteConfirmation(context, item),
        );
      },
    );
  }

  // Metodo dedicato per la navigazione alla modifica
  void _navigateToEdit(ShoppingItem item) {
    try {
      Get.toNamed(
        Routes.ADD,
        arguments: {
          'shopping': item,
        },
      )?.then((result) {
        controller.loadShoppingItems();
      });
    } catch (e) {
      Get.snackbar(
        'Errore',
        'Impossibile aprire la pagina di modifica',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

 void _showDeleteConfirmation(BuildContext context, ShoppingItem item) {
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
          'Sei sicuro di voler eliminare la task "${item.name}"?\n\nQuesta azione non può essere annullata.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteItem(item.id);
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