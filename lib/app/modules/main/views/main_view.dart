import 'dart:io';
import 'package:roomy/app/modules/account/views/account_view.dart';
import 'package:roomy/app/modules/shopping/views/shopping_view.dart';
import 'package:roomy/core/theme/palette.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../../tasks/views/tasks_view.dart';
import '../controllers/main_controller.dart';

class MainView extends GetView<MainController> {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      const TasksView(),
      const ShoppingView(),
      const AccountView(),
    ];

    return PersistentTabView(
      context,
      screens: pages,
      items: <PersistentBottomNavBarItem> [
        PersistentBottomNavBarItem(
          icon: const Icon(FluentIcons.task_list_square_ltr_20_regular),
          activeColorPrimary: Palette.buttonColor,
          inactiveColorPrimary: Palette.labelColor,
        ),
        PersistentBottomNavBarItem(
          icon: const Icon(FluentIcons.cart_20_regular),
          activeColorPrimary: Palette.buttonColor,
          inactiveColorPrimary: Palette.labelColor,
        ),
        PersistentBottomNavBarItem(
          icon: const Icon(FluentIcons.person_20_regular),
          activeColorPrimary: Palette.buttonColor,
          inactiveColorPrimary: Palette.labelColor,
        ),
      ],
      stateManagement: false,
      onWillPop: (p0) => exit(0),
      navBarStyle: NavBarStyle.style16,
      decoration: const NavBarDecoration(
        colorBehindNavBar: Colors.transparent,
        borderRadius: BorderRadius.all(Radius.circular(0)),
      ),
      resizeToAvoidBottomInset: true,
      onItemSelected: (value) => controller.setIndex(value),
      backgroundColor: Theme.of(context).colorScheme.secondary,
    );
  }
}