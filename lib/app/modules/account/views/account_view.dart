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
    return controller.obx(
      (state) => Scaffold(
        body: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),

                // Header utente
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Obx(() => Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          controller.user.value.name,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          controller.user.value.email,
                          style: const TextStyle(color: Palette.labelColor),
                        ),
                      ],
                    ),
                  )),
                ),

                // Sezione gestione casa
                Obx(() {
                  if (controller.houseId.value.isNotEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        headingText("La tua casa"),
                        _buildHouseInfoTile(),
                        _buildHouseMembersTile(context),
                        _buildInviteCodeTile(),
                        if (controller.isHouseAdmin.value) ...[
                          SettingsTile(
                            title: "Rigenera codice invito",
                            subtitle: "Crea un nuovo codice per invitare persone",
                            icon: Icon(FluentIcons.arrow_clockwise_20_filled, color: Theme.of(context).iconTheme.color),
                            onTap: () => controller.regenerateInviteCode(context),
                          ),
                          SettingsTile(
                            title: "Elimina casa",
                            subtitle: "Elimina definitivamente la casa",
                            icon: const Icon(FluentIcons.delete_20_filled, color: Colors.redAccent),
                            onTap: () => controller.deleteHouse(context),
                          ),
                        ],
                        SettingsTile(
                          title: "Esci dalla casa",
                          subtitle: "Lascia la casa corrente",
                          icon: const Icon(FluentIcons.sign_out_20_filled, color: Colors.orangeAccent),
                          onTap: () => controller.leaveHouse(context),
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                }),

                // Sezione personalizzazione account
                headingText("Personalizza il tuo account"),

                SettingsTile(
                  title: "Modifica profilo",
                  subtitle: "Modifica le informazioni personali",
                  icon: Icon(FluentIcons.person_20_filled, color: Theme.of(context).iconTheme.color),
                  onTap: () => Get.toNamed(Routes.MANAGE_ACCOUNT, arguments: controller.user.value),
                ),

                // Sezione personalizzazione esperienza
                headingText("Personalizza la tua esperienza"),

                Obx(() => SwitchSettingsTile(
                  title: "Tema scuro",
                  subtitle: "Abilita o disabilita il tema scuro",
                  icon: FluentIcons.dark_theme_20_filled,
                  value: controller.isDarkMode.value,
                  onChanged: (value) => controller.changeTheme(),
                )),

                // Sezione account
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
                  child: Text(
                    "2025 © Roomy, tutti i diritti riservati",
                    style: TextStyle(color: Palette.labelColor),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
      onLoading: const Loading(),
    );
  }

  Widget _buildHouseInfoTile() {
    return Obx(() =>
      SettingsTile(
        onTap: () {},
        icon: Icon(FluentIcons.home_20_filled, color: Theme.of(Get.context!).iconTheme.color),
        title: controller.houseName.value.isNotEmpty 
                  ? controller.houseName.value 
                  : "Casa senza nome",
        subtitle: controller.isHouseAdmin.value ? "Amministratore" : "Membro",
        trailing: controller.isHouseAdmin.value 
                  ? Icon(FluentIcons.shield_checkmark_20_filled, color: Theme.of(Get.context!).iconTheme.color) 
                  : const Icon(FluentIcons.person_20_filled, color: Palette.labelColor),
      ),
    );
  }

  Widget _buildHouseMembersTile(BuildContext context) {
    return SettingsTile(
      title: "Membri della casa",
      subtitle: "Visualizza e gestisci i membri",
      icon: Icon(FluentIcons.home_person_20_filled, color: Theme.of(Get.context!).iconTheme.color),
      onTap: () => _showHouseMembersDialog(context),
    );
  }

  Widget _buildInviteCodeTile() {
    return Obx(() =>
      SettingsTile(
        title: "Codice invito",
        subtitle: controller.houseInviteCode.value.isNotEmpty
                  ? controller.houseInviteCode.value
                  : "Caricamento...",
        icon: Icon(FluentIcons.qr_code_20_filled, color: Theme.of(Get.context!).iconTheme.color),
        onTap: () => controller.copyInviteCode(Get.context!),
        trailing: const Icon(FluentIcons.copy_20_regular),
      ),
    );
  }

  void _showHouseMembersDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      builder: (context) => SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  const Icon(FluentIcons.people_20_filled),
                  const SizedBox(width: 5),
                  const Text(
                    "Membri della casa",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                    )
                  ),

                  const Spacer(),
                  
                  Obx(() => Text(
                    "${controller.houseMembers.length}",
                    style: const TextStyle(fontSize: 16, color: Palette.labelColor),
                  )),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Obx(() {
              if (controller.isLoadingHouse.value) {
                return const Center(child: CircularProgressIndicator());
              }
            
              if (controller.houseMembers.isEmpty) {
                return const Center(
                  child: Text(
                    "Nessun membro trovato",
                    style: TextStyle(color: Palette.labelColor),
                  ),
                );
              }
            
              return ListView.builder(
                shrinkWrap: true,
                itemCount: controller.houseMembers.length,
                itemBuilder: (context, index) {
                  final member = controller.houseMembers[index];
                  final isCurrentUser = member.id == controller.user.value.id;
                  final isAdmin = controller.isHouseAdmin.value;
            
                  return ListTile(
                    title: Text(member.name),
                    subtitle: Text(member.email),
                    trailing: isAdmin && !isCurrentUser
                        ? PopupMenuButton<String>(
                            icon: const Icon(FluentIcons.more_vertical_20_filled, color: Palette.labelColor),
                            onSelected: (value) {
                              if (value == 'kick') {
                                controller.kickMember(context, member);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'kick',
                                child: ListTile(
                                  leading: Icon(FluentIcons.person_delete_20_filled, color: Colors.red),
                                  title: Text('Espelli', style: TextStyle(color: Colors.red)),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ],
                          )
                        : const Text(
                            "Tu",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  );
                },
              );
            }),
          ],
        ),
      )
    );
  }

  Widget headingText(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, bottom: 5, top: 15),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}