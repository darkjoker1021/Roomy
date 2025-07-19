import 'package:flutter/material.dart';
import 'package:roomy/core/theme/palette.dart';

InputDecoration buildDropdownDecoration(BuildContext context, {IconData? icon, String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 1),
      ),
      enabledBorder: OutlineInputBorder(  
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1),
      ),
      filled: true,
      fillColor: Theme.of(context).colorScheme.secondary,
      hintStyle: const TextStyle(color: Palette.labelColor),
      errorStyle: const TextStyle(fontSize: 12),
      errorMaxLines: 2,
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
      prefixIcon: icon != null
        ? Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ) : null,
    );
  }