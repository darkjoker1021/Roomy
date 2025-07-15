import 'package:roomy/core/theme/palette.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final double? height;
  final double? width;

  const CustomButton({super.key, required this.onPressed, required this.text, this.height, this.icon, this.backgroundColor, this.borderColor, this.textColor, this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? Get.width,
      height: height ?? 50,
      child: ElevatedButton.icon(
        icon: icon,
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: backgroundColor ?? Theme.of(context).iconTheme.color,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: borderColor ?? Theme.of(context).iconTheme.color ?? Palette.primaryColor),
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        label: Text(text, style: TextStyle(color: textColor ?? Colors.white)),
      ),
    );
  }
}