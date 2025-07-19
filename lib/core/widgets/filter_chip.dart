import 'package:flutter/material.dart';
import 'package:roomy/core/widgets/dropdown_style.dart';

class CustomFilterChip extends StatelessWidget {
  final String? value;
  final String hint;
  final List<String> items;
  final IconData icon;
  final Function(String?) onChanged;

  const CustomFilterChip({
    super.key,
    required this.value,
    required this.hint,
    required this.items,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        constraints: const BoxConstraints(minWidth: 100),
        child: DropdownButtonHideUnderline(
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: buildDropdownDecoration(context, hintText: hint, icon: icon),
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}