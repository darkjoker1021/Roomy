import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:roomy/core/theme/palette.dart';
import 'package:roomy/core/widgets/button.dart';
import 'package:roomy/core/widgets/text_field.dart';
import 'package:roomy/core/widgets/back_button.dart';
import 'package:roomy/core/widgets/loading.dart';
import 'package:roomy/core/widgets/heading.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import '../controllers/join_house_controller.dart';

class JoinHouseView extends GetView<JoinHouseController> {
  const JoinHouseView({super.key});

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
              key: controller.joinHouseFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  
                  // Titolo e descrizione
                  const Heading(
                    title: "Entra in una casa",
                    subtitle: "Inserisci il codice invito che hai ricevuto per unirti alla casa",
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Icona
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Palette.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        FluentIcons.key_16_filled,
                        size: 50,
                        color: Palette.primaryColor,
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
                  
                  const Spacer(),
                  
                  // Pulsante continua
                  CustomButton(
                    onPressed: () => controller.joinHouseWithCode(context),
                    text: "Continua",
                    height: 55,
                  ),
                  
                  const SizedBox(height: 20),
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