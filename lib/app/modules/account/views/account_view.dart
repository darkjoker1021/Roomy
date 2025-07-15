import 'package:roomy/app/modules/account/widgets/settings_tile.dart';
import 'package:roomy/app/modules/account/widgets/switch_tile.dart';
import 'package:roomy/app/routes/app_pages.dart';
import 'package:roomy/core/theme/palette.dart';
import 'package:roomy/core/widgets/loading.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/account_controller.dart';

class AccountView extends GetView<AccountController> {
  const AccountView({super.key});
  @override
  Widget build(BuildContext context) {
    return controller.obx((state) =>
      Scaffold(
        body: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Obx(() =>
                    Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "${controller.user.value.name} ${controller.user.value.surname}",
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                      
                          Text(controller.user.value.email, style: const TextStyle(color: Palette.labelColor))
                        ],
                      ),
                    ),
                  ),
                ),
      
                headingText("Personalizza il tuo account"),
      
                SettingsTile(
                  title: "Modifica profilo",
                  subtitle: "Modifica le informazioni personali",
                  icon: Icon(FluentIcons.person_20_filled, color: Theme.of(context).iconTheme.color),
                  onTap: () => Get.toNamed(Routes.MANAGE_ACCOUNT, arguments: controller.user.value),
                ),
      
                headingText("Personalizza la tua esperienza"),
      
                Obx(() => SwitchSettingsTile(
                  title: "Tema scuro",
                  subtitle: "Abilita o disabilita il tema scuro",
                  icon: FluentIcons.dark_theme_20_filled,
                  value: controller.isDarkMode.value,
                  onChanged: (value) => controller.changeTheme(),
                )),
      
                headingText("Esci o elimina il tuo account"),
      
                SettingsTile(
                  title: "Esci",
                  subtitle: "Esci dal tuo account",
                  icon: const Icon(FluentIcons.arrow_exit_20_filled, color: Colors.redAccent),
                  onTap: () => controller.logout(context),
                ),
      
                SettingsTile(
                  title: "Elimina account",
                  subtitle: "Elimina il tuo account",
                  icon: const Icon(FluentIcons.delete_20_filled, color: Colors.redAccent),
                  onTap: () => controller.deleteAccount(context),
                ),
      
                const SizedBox(height: 20),
      
                const Center(
                  child: Text("2025 © Roomy, tutti i diritti riservati", style: TextStyle(color: Palette.labelColor))
                ),
      
                const SizedBox(height: 30),
              ],
            )
          ),
        )
      ),
      onLoading: const Loading(),
    );
  }

  Widget headingText(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, bottom: 5, top: 15),
      child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
    );
  }
}