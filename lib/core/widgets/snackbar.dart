import 'package:flutter/material.dart';

class CustomSnackbar {
  static void showSnackbar(BuildContext context, String title, Color color, SnackBarAction? action) {
    ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(
      SnackBar(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
        backgroundColor: color,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        content: Text(title, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  static void showSuccessSnackbar(BuildContext context, String title) {
    CustomSnackbar.showSnackbar(context, title, Colors.green, null);
  }

  static void showErrorSnackbar(BuildContext context, String title) {
    CustomSnackbar.showSnackbar(context, title, Colors.red, null);
  }
}