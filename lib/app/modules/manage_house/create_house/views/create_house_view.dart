import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:roomy/core/theme/palette.dart';
import 'package:roomy/core/widgets/button.dart';
import 'package:roomy/core/widgets/text_field.dart';
import 'package:roomy/core/widgets/back_button.dart';
import 'package:roomy/core/widgets/loading.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import '../controllers/create_house_controller.dart';

class CreateHouseView extends GetView<CreateHouseController> {
  const CreateHouseView({super.key});

  @override
  Widget build(BuildContext context) {
    return controller.obx(
      (state) => Scaffold(
        bottomNavigationBar: BottomAppBar(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: CustomButton(
            onPressed: () => controller.createHouse(context),
            text: "Crea casa",
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Form(
              key: controller.createHouseFormKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CustomBackButton(),
            
                        SizedBox(width: 10),
            
                        Text(
                          "Crea una nuova casa",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Configura la tua casa condivisa e inizia a organizzare la convivenza",
                      style: TextStyle(
                        fontSize: 16,
                        color: Palette.labelColor,
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Icona
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          FluentIcons.home_add_20_filled,
                          size: 50,
                          color: Theme.of(context).iconTheme.color,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Nome della casa
                    CustomTextField(
                      controller: controller.houseNameController,
                      hintText: "Nome della casa",
                      obscureText: false,
                      keyboardType: TextInputType.streetAddress,
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
                                        
                    const SizedBox(height: 20),
                    
                    // Informazioni sui benefici
                    Container(
                      width: Get.width,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                FluentIcons.info_16_filled,
                                color: Theme.of(context).iconTheme.color,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Cosa include:",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).iconTheme.color,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _buildBenefitRow("Codice invito automatico", context),
                          _buildBenefitRow("Calendario delle pulizie", context),
                          _buildBenefitRow("Lista della spesa collaborativa", context),
                        ],
                      ),
                    ),
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

  Widget _buildBenefitRow(String text, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Icon(
            FluentIcons.checkmark_16_filled,
            color: Theme.of(context).iconTheme.color,
            size: 16,
          ),

          const SizedBox(width: 10),

          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).iconTheme.color,
            ),
          ),
        ],
      ),
    );
  }
}