import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BackButton(
      style: ElevatedButton.styleFrom(
        iconColor: Theme.of(context).iconTheme.color,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        )
      ),
      onPressed: () => Get.back(),
    );
  }
}