import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:roomy/app/data/lists.dart';
import 'package:roomy/core/theme/palette.dart';
import 'package:roomy/core/widgets/button.dart';
import 'package:roomy/core/widgets/dropdown_style.dart';
import 'package:roomy/core/widgets/heading.dart';
import 'package:roomy/core/widgets/loading.dart';
import 'package:roomy/core/widgets/text_field.dart';
import '../controllers/add_controller.dart';

class AddView extends GetView<AddController> {
  const AddView({super.key});

  @override
  Widget build(BuildContext context) {
    return controller.obx((state) =>
      Scaffold(
        body: Obx(() {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Heading(
                    title: controller.addType.value == AddType.task
                          ? controller.editingTask != null ? 'Modifica Task' : 'Aggiungi Task'
                          : controller.editingShoppingItem != null ? 'Modifica Prodotto' : 'Aggiungi Prodotto',
                    subtitle: controller.addType.value == AddType.task
                          ? controller.editingTask != null ? 'Modifica la tua Task' : 'Aggiungi una nuova Task'
                          : controller.editingShoppingItem != null ? 'Modifica il tuo Prodotto' : 'Aggiungi un nuovo Prodotto',
                    backButton: controller.editingTask != null || controller.editingShoppingItem != null,
                  ),

                  const SizedBox(height: 20),

                  _buildTypeSelector(context),
                  
                  const SizedBox(height: 20),
                  
                  // Form dinamico
                  controller.addType.value == AddType.task
                    ? _buildTaskForm(context)
                    : _buildProductForm(context),
                  
                  const SizedBox(height: 30),
                  
                  // Bottone salva
                  _buildSaveButton(context),
                ],
              ),
            ),
          );
        }),
      ),
      onLoading: const Loading(),
    );
  }

  Widget _buildTypeSelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child: Obx(() => GestureDetector(
              onTap: () {
                if (controller.editingTask != null || controller.editingShoppingItem != null) {
                  return;
                } else {
                  controller.changeAddType(AddType.task);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: controller.addType.value == AddType.task
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      FluentIcons.task_list_square_ltr_20_filled,
                      color: controller.addType.value == AddType.task
                          ? Colors.white
                          : Palette.labelColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Task',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: controller.addType.value == AddType.task
                            ? Colors.white
                            : Palette.labelColor,
                      ),
                    ),
                  ],
                ),
              ),
            )),
          ),
          Expanded(
            child: Obx(() => GestureDetector(
              onTap: () {
                if (controller.editingTask != null || controller.editingShoppingItem != null) {
                  return;
                } else {
                  controller.changeAddType(AddType.product);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: controller.addType.value == AddType.product
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      FluentIcons.box_20_filled,
                      color: controller.addType.value == AddType.product
                          ? Colors.white
                          : Palette.labelColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Prodotto',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: controller.addType.value == AddType.product
                            ? Colors.white
                            : Palette.labelColor,
                      ),
                    ),
                  ],
                ),
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Titolo della task*'),
        const SizedBox(height: 5),
        CustomTextField(
          controller: controller.titleController,
          hintText: 'Inserisci il titolo della task',
          obscureText: false,
        ),
        
        const SizedBox(height: 16),
        
        _buildSectionTitle('Descrizione (opzionale)'),
        const SizedBox(height: 5),
        CustomTextField(
          controller: controller.descriptionController,
          hintText: 'Descrizione della task',
          obscureText: false,
          keyboardType: TextInputType.multiline,
          maxLines: 3,
        ),
        
        const SizedBox(height: 16),
        
        _buildSectionTitle('Categoria'),
        const SizedBox(height: 5),
        _buildCategoryDropdown(context),
        
        const SizedBox(height: 16),
        
        _buildSectionTitle('Assegna a*'),
        const SizedBox(height: 5),
        _buildMemberSelector(context),
        
        const SizedBox(height: 16),
        
        _buildSectionTitle('Priorità'),
        const SizedBox(height: 5),
        _buildPriorityDropdown(context),

        const SizedBox(height: 16),
        
        _buildSectionTitle('Scadenza (opzionale)'),
        const SizedBox(height: 5),
        _buildDateSelector(
          selectedDate: controller.selectedDueDate.value,
          onDateSelected: (date) => controller.selectedDueDate.value = date,
          hintText: 'Seleziona scadenza',
          context: context
        ),
      ],
    );
  }

  Widget _buildProductForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Nome prodotto*'),
        const SizedBox(height: 5),
        CustomTextField(
          controller: controller.titleController,
          hintText: 'Nome del prodotto',
          obscureText: false,
        ),
        
        const SizedBox(height: 16),
        
        _buildSectionTitle('Marca (opzionale)'),
        const SizedBox(height: 5),
        CustomTextField(
          controller: controller.brandController,
          hintText: 'Marca del prodotto',
          obscureText: false,
        ),
        
        const SizedBox(height: 16),
        
        _buildSectionTitle('Categoria'),
        const SizedBox(height: 5),
        _buildProductCategoryDropdown(context),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Quantità*'),
                  const SizedBox(height: 5),
                  CustomTextField(
                    controller: controller.quantityController,
                    hintText: 'Es. 2',
                    obscureText: false,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 15),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Unità'),
                  const SizedBox(height: 5),
                  _buildUnitDropdown(context),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Obx(() => Switch(
              value: controller.isPerishable.value,
              onChanged: (value) {
                controller.isPerishable.value = value;
                if (!value) {
                  controller.selectedExpiryDate.value = null;
                }
              },
            )),
            const SizedBox(width: 8),
            const Text(
              'Prodotto deperibile',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        Obx(() => controller.isPerishable.value
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Data di scadenza'),
                const SizedBox(height: 5),
                _buildDateSelector(
                  selectedDate: controller.selectedExpiryDate.value,
                  onDateSelected: (date) => controller.selectedExpiryDate.value = date,
                  hintText: 'Seleziona data di scadenza',
                  showFutureOnly: false,
                  context: context
                ),
                const SizedBox(height: 16),
              ],
            )
          : const SizedBox.shrink()),
        
        _buildSectionTitle('Note (opzionale)'),
        const SizedBox(height: 5),
        CustomTextField(
          controller: controller.notesController,
          hintText: 'Note aggiuntive',
          obscureText: false,
          keyboardType: TextInputType.multiline,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildCategoryDropdown(BuildContext context) {
    return Obx(() => DropdownButtonFormField<String>(
      value: controller.selectedCategory.value,
      decoration: buildDropdownDecoration(context),
      items: taskCategories.map((category) => 
        DropdownMenuItem(value: category, child: Text(category))
      ).toList(),
      onChanged: (value) => controller.selectedCategory.value = value!,
    ));
  }

  Widget _buildProductCategoryDropdown(BuildContext context) {
    return Obx(() => DropdownButtonFormField<String>(
      value: controller.selectedProductCategory.value,
      decoration: buildDropdownDecoration(context),
      items: productCategories.map((category) => 
        DropdownMenuItem(value: category, child: Text(category))
      ).toList(),
      onChanged: (value) => controller.selectedProductCategory.value = value!,
    ));
  }

  Widget _buildUnitDropdown(BuildContext context) {
    return Obx(() => DropdownButtonFormField<String>(
      value: controller.selectedUnit.value,
      decoration: buildDropdownDecoration(context),
      items: productUnits.map((unit) => 
        DropdownMenuItem(value: unit, child: Text(unit))
      ).toList(),
      onChanged: (value) => controller.selectedUnit.value = value!,
    ));
  }

  Widget _buildPriorityDropdown(BuildContext context) {
    return Obx(() => DropdownButtonFormField<int>(
      value: controller.selectedPriority.value,
      decoration: buildDropdownDecoration(context),
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
      onChanged: (value) => controller.selectedPriority.value = value!,
    ));
  }

  Widget _buildMemberSelector(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingMembers.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return DropdownButtonFormField<String>(
        value: controller.selectedMember.value.isNotEmpty
            ? controller.selectedMember.value
            : 'Tutti i membri',
        decoration: buildDropdownDecoration(context),
        hint: const Text('Seleziona un membro'),
        items: [
          DropdownMenuItem<String>(
            value: 'Tutti i membri',
            child: Row(
              children: [
                Icon(
                  FluentIcons.people_community_20_filled,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Text('Tutti i membri'),
              ],
            ),
          ),
          ...controller.houseMembers.map((member) {
            final name = member.name;
            final id = member.id;

            return DropdownMenuItem<String>(
              value: name,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      name[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 8),
                  if (id == FirebaseAuth.instance.currentUser?.uid)
                    const Icon(
                      FluentIcons.person_20_filled,
                      color: Colors.green,
                      size: 16,
                    ),
                ],
              ),
            );
          }),
        ],
        onChanged: (newValue) {
          if (newValue != null) {
            controller.selectedMember.value = newValue;
          }
        },
      );
    });
  }

  Widget _buildDateSelector({
    required DateTime? selectedDate,
    required Function(DateTime?) onDateSelected,
    required String hintText,
    bool showFutureOnly = true,
    required BuildContext context
  }) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: Get.context!,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: showFutureOnly ? DateTime.now() : DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
        );
        if (date != null) {
          onDateSelected(date);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            const Icon(FluentIcons.calendar_ltr_20_regular, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedDate != null
                    ? DateFormat('dd/MM/yyyy').format(selectedDate)
                    : hintText,
                style: TextStyle(
                  color: selectedDate != null ? Colors.black : Colors.grey,
                ),
              ),
            ),
            if (selectedDate != null)
              IconButton(
                icon: const Icon(FluentIcons.dismiss_20_regular, color: Colors.red),
                onPressed: () => onDateSelected(null),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return Obx(() => CustomButton(
      onPressed: () => controller.saveItem(),
      text: controller.editingTask != null || controller.editingShoppingItem != null
            ? 'Salva Modifiche'
            : controller.addType.value == AddType.task ? 'Aggiungi Task' : 'Aggiungi Prodotto',
      icon: controller.addType.value == AddType.task
          ? const Icon(FluentIcons.task_list_square_ltr_20_filled, color: Colors.white)
          : const Icon(FluentIcons.box_20_filled, color: Colors.white),
      backgroundColor: Theme.of(context).colorScheme.primary,
      textColor: Colors.white,
    ));
  }
}