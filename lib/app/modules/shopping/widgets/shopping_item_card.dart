// widgets/task_card.dart
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:roomy/app/data/shopping_item.dart';
import 'package:roomy/app/modules/shopping/controllers/shopping_controller.dart';
import 'package:roomy/core/theme/palette.dart';
import 'package:roomy/core/widgets/button.dart';

class ShoppingItemCard extends StatelessWidget {
  final ShoppingItem item;
  final ShoppingController controller;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ShoppingItemCard({
    required this.item,
    required this.controller,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Theme.of(context).colorScheme.secondary,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      decoration: item.isPurchased ? TextDecoration.lineThrough : null,
                      color: item.isPurchased ? Colors.grey : null,
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(item.category, style: TextStyle(fontSize: 12, color: Colors.blue.shade700)),
                ),
              ],
            ),

            // Descrizione
            if (item.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                item.notes ?? "",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  decoration: item.isPurchased ? TextDecoration.lineThrough : null,
                ),
              ),
            ],
            const SizedBox(height: 12),
            // Info
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      FluentIcons.cart_20_filled,
                      size: 16,
                      color: Palette.labelColor,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Qtà: ${item.quantity}',
                      style: const TextStyle(
                        color: Palette.labelColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 15),
            // Pulsanti
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      height: 40,
                      onPressed: () => controller.togglePurchaseStatus(item.id, !item.isPurchased),
                      icon: Icon(
                        item.isPurchased ? FluentIcons.arrow_redo_16_filled : FluentIcons.checkmark_20_filled,
                        size: 20,
                        color: Colors.white
                      ),
                      text: item.isPurchased ? 'Riapri' : 'Acquista',
                      backgroundColor: item.isPurchased ? Colors.orange : Colors.green,
                      borderColor: item.isPurchased ? Colors.orange : Colors.green,
                    ),
                  ),
              
                  const SizedBox(width: 5),
              
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(FluentIcons.edit_20_filled, size: 20),
                    color: Colors.blue,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.blue.withValues(alpha: 0.1),
                      shape: const CircleBorder(),
                    ),
                  ),
              
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(FluentIcons.delete_20_filled, size: 20),
                    color: Colors.red,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red.withValues(alpha: 0.1),
                      shape: const CircleBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}