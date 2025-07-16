import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:roomy/core/theme/palette.dart';
import 'package:roomy/core/widgets/button.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import '../controllers/house_controller.dart';

class HouseView extends GetView<HouseController> {
  const HouseView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              // Logo
              Image.asset(
                "assets/logos/logo.png",
                width: 100,
                height: 100,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 30),

              // Titolo
              const Text(
                "Benvenuto in Roomy",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              // Sottotitolo
              const Text(
                "Gestisci la tua casa condivisa\nin modo semplice e organizzato",
                style: TextStyle(
                  fontSize: 16,
                  color: Palette.labelColor,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 50),

              // Opzione: Entra in una casa
              Obx(() => GestureDetector(
                    onTap: () => controller.selectJoinHouse(),
                    child: Container(
                      width: Get.width,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: controller.selectedOption.value == 'join'
                            ? Palette.primaryColor.withValues(alpha: 0.1)
                            : Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: controller.selectedOption.value == 'join'
                              ? Palette.primaryColor
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            FluentIcons.home_16_filled,
                            size: 40,
                            color: controller.selectedOption.value == 'join'
                                ? Palette.primaryColor
                                : Palette.labelColor,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Entra in una casa",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: controller.selectedOption.value == 'join'
                                  ? Palette.primaryColor
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Inserisci il codice invito per unirti\na una casa esistente",
                            style: TextStyle(
                              fontSize: 14,
                              color: controller.selectedOption.value == 'join'
                                  ? Palette.primaryColor
                                  : Palette.labelColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )),

              const SizedBox(height: 20),

              // Opzione: Crea una nuova casa
              Obx(() => GestureDetector(
                    onTap: () => controller.selectCreateHouse(),
                    child: Container(
                      width: Get.width,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: controller.selectedOption.value == 'create'
                            ? Palette.primaryColor.withValues(alpha: 0.1)
                            : Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: controller.selectedOption.value == 'create'
                              ? Palette.primaryColor
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            FluentIcons.add_circle_16_filled,
                            size: 40,
                            color: controller.selectedOption.value == 'create'
                                ? Palette.primaryColor
                                : Palette.labelColor,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Crea una nuova casa",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: controller.selectedOption.value == 'create'
                                  ? Palette.primaryColor
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Configura una nuova casa e invita\ni tuoi coinquilini",
                            style: TextStyle(
                              fontSize: 14,
                              color: controller.selectedOption.value == 'create'
                                  ? Palette.primaryColor
                                  : Palette.labelColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )),

              const SizedBox(height: 40),

              // Pulsante continua
              Obx(() => CustomButton(
                    onPressed: controller.selectedOption.value == 'join'
                        ? controller.proceedToJoinHouse
                        : controller.selectedOption.value == 'create'
                            ? controller.proceedToCreateHouse
                            : () {},
                    text: controller.selectedOption.value == 'join'
                        ? "Entra con codice invito"
                        : controller.selectedOption.value == 'create'
                            ? "Crea nuova casa"
                            : "Seleziona un'opzione",
                    height: 55,
                    backgroundColor: controller.selectedOption.value.isNotEmpty
                        ? null
                        : Palette.labelColor,
                  )),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
