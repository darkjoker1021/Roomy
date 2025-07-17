import 'package:roomy/core/theme/palette.dart';
import 'package:roomy/core/widgets/back_button.dart';
import 'package:roomy/core/widgets/button.dart';
import 'package:roomy/core/widgets/loading.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/manage_account_controller.dart';

class ManageAccountView extends GetView<ManageAccountController> {
  const ManageAccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return controller.obx((state) =>
      Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      CustomBackButton(),
      
                      SizedBox(width: 10),
                      
                      Text(
                        "Modifica i tuoi dati personali",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
          
                  TextField(
                    controller: controller.nameController,
                    decoration: InputDecoration(
                      hintText: "Nome",
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.secondary,
                      border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15)), borderSide: BorderSide.none),
                    ),
                  ),
          
                  const SizedBox(height: 10),
          
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(FluentIcons.info_20_regular, color: Palette.labelColor),
          
                      SizedBox(width: 5),
          
                      Expanded(
                        child: Text(
                          "Il nome è pubblico e verrà usato per le interazioni.",
                          style: TextStyle(color: Palette.labelColor),
                        ),
                      ),
                    ],
                  ),
          
                  const SizedBox(height: 30),

                  CustomButton(
                    onPressed: () => controller.updateAccount(context),
                    text: "Aggiorna le informazioni",
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      onLoading: const Loading()
    );
  }
}