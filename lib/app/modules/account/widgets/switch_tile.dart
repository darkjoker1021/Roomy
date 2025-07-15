import 'package:roomy/core/theme/palette.dart';
import 'package:flutter/material.dart';

class SwitchSettingsTile extends StatelessWidget {
  const SwitchSettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.onChanged,
    required this.value
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final bool value;
  final Future<void> Function(dynamic) onChanged;


  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title),
          if (subtitle != null) Text(subtitle!, style: const TextStyle(fontSize: 12, color: Palette.labelColor)),
        ],
      ),
      value: value,
      secondary: Container(
        width: 50,
        height: 50,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          color: Theme.of(context).colorScheme.secondary,
        ),
        child: Icon(icon, color: Theme.of(context).iconTheme.color),
      ),
      inactiveTrackColor: Theme.of(context).scaffoldBackgroundColor,
      activeColor: Theme.of(context).iconTheme.color,
      onChanged: (value) => onChanged(value),
      contentPadding: const EdgeInsets.only(left: 17, top: 5, bottom: 5, right: 20),
    );
  }
}