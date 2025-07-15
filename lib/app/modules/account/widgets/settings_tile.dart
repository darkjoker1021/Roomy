import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:roomy/core/theme/palette.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.onTap
  });

  final String title;
  final String? subtitle;
  final Widget icon;
  final VoidCallback onTap;


  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          if (subtitle != null) Text(subtitle!, style: const TextStyle(fontSize: 12, color: Palette.labelColor))
        ],
      ),
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          color: Theme.of(context).colorScheme.secondary,
        ),
        alignment: Alignment.center,
        child: icon,
      ),
      minTileHeight: 60,
      onTap: onTap,
      trailing: const Icon(FluentIcons.chevron_right_16_regular),
    );
  }
}