import 'package:flutter/material.dart';

class CustomFloatingActionButton extends StatelessWidget {
  const CustomFloatingActionButton({super.key, this.icon, required this.onPressed, this.backgroudColor, this.imageIcon});

  final IconData? icon;
  final VoidCallback onPressed;
  final Color? backgroudColor;
  final Widget? imageIcon;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: backgroudColor ?? Theme.of(context).iconTheme.color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: imageIcon ?? Icon(
        icon,
        color: backgroudColor != null ? Theme.of(context).iconTheme.color : Colors.white
      ),
    );
  }
}