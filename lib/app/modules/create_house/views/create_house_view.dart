import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:roomy/core/theme/palette.dart';
import 'package:roomy/core/widgets/button.dart';
import 'package:roomy/core/widgets/text_field.dart';
import 'package:roomy/core/widgets/back_button.dart';
import 'package:roomy/core/widgets/loading.dart';
import 'package:roomy/core/widgets/heading.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import '../controllers/create_house_controller.dart';

class CreateHouseView extends GetView<CreateHouseController> {
  const CreateHouseView({super.key});

  @override
  Widget build(BuildContext context) {
    return controller.obx(
      (state) => Scaffold(
        appBar: AppBar(
          leading: const Padding(
            padding: EdgeInsets.all(8.0),
            child: CustomBackButton(),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: controller.createHouseFormKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    
                    // Titolo e descrizione
                    const Heading(
                      title: "Crea una nuova casa",
                      subtitle: "Configura la tua casa condivisa e inizia a organizzare la convivenza",
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Icona
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Palette.primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          FluentIcons.home_add_20_filled,
                          size: 50,
                          color: Palette.primaryColor,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Nome della casa
                    CustomTextField(
                      controller: controller.houseNameController,
                      hintText: "Nome della casa",
                      obscureText: false,
                      keyboardType: TextInputType.text,
                      prefixIcon: const Icon(FluentIcons.home_16_filled),
                    ),
                    
                    const SizedBox(height: 15),
                    
                    // Indirizzo
                    CustomTextField(
                      controller: controller.addressController,
                      hintText: "Indirizzo",
                      obscureText: false,
                      keyboardType: TextInputType.streetAddress,
                      prefixIcon: const Icon(FluentIcons.location_16_filled),
                    ),
                    
                    const SizedBox(height: 15),
                    
                    // Descrizione
                    TextFormField(
                      controller: controller.descriptionController,
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Inserisci una descrizione";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "Descrizione della casa (opzionale)",
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.secondary,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                        prefixIcon: const Icon(FluentIcons.text_description_16_filled),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Informazioni sui benefici
                    Container(
                      width: Get.width,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Palette.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                FluentIcons.info_16_filled,
                                color: Palette.primaryColor,
                                size: 20,
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Cosa include:",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Palette.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _buildBenefitRow("Codice invito automatico"),
                          _buildBenefitRow("Gestione spese condivise"),
                          _buildBenefitRow("Calendario delle pulizie"),
                          _buildBenefitRow("Lista della spesa collaborativa"),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Pulsante crea casa
                    CustomButton(
                      onPressed: () => controller.createHouse(context),
                      text: "Crea casa",
                      height: 55,
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      onLoading: const Loading(),
    );
  }

  Widget _buildBenefitRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          const Icon(
            FluentIcons.checkmark_16_filled,
            color: Palette.primaryColor,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Palette.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}