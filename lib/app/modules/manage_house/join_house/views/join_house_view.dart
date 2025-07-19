import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:roomy/core/theme/palette.dart';
import 'package:roomy/core/widgets/button.dart';
import 'package:roomy/core/widgets/heading.dart';
import 'package:roomy/core/widgets/text_field.dart';
import 'package:roomy/core/widgets/loading.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import '../controllers/join_house_controller.dart';

class JoinHouseView extends GetView<JoinHouseController> {
  const JoinHouseView({super.key});

  @override
  Widget build(BuildContext context) {
    return controller.obx(
      (state) => Scaffold(
        bottomNavigationBar: BottomAppBar(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: CustomButton(
            onPressed: () => controller.joinHouseWithCode(context),
            text: "Continua",
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Form(
              key: controller.joinHouseFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [                  
                  const Heading(
                    title: 'Entra in una casa',
                    backButton: true,
                  ),
          
                  const SizedBox(height: 10),
          
                  // Descrizione
                  const Text(
                    "Per entrare in una casa condivisa, inserisci il codice invito fornito da un amministratore.",
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
                        FluentIcons.key_16_filled,
                        size: 50,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Campo codice invito
                  CustomTextField(
                    controller: controller.inviteCodeController,
                    hintText: "Codice invito (es: ABC123)",
                    obscureText: false,
                    keyboardType: TextInputType.text,
                    prefixIcon: const Icon(FluentIcons.key_16_filled),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Testo informativo
                  const Text(
                    "Il codice invito è composto da 6 caratteri e ti è stato fornito da un amministratore della casa.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Palette.labelColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      onLoading: const Loading(),
    );
  }
}