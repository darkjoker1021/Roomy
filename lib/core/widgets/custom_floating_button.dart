import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:roomy/app/routes/app_pages.dart';

class CustomFloatingButton extends StatelessWidget {
  const CustomFloatingButton({
    super.key, required this.task,
  });

  final bool task;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: null,
      onPressed: () => Get.toNamed(Routes.ADD, arguments: {'page' : task ? 'task' : 'shopping'}),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: const Icon(
        FluentIcons.add_20_filled,
        color: Colors.white
      ),
    );
  }
}