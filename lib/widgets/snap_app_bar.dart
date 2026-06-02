import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SnapAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SnapAppBar({super.key, required this.title, this.subtitle, this.actions});

  final String title;
  final String? subtitle;
  final List<Widget>? actions;

  @override
  Size get preferredSize =>
      Size.fromHeight(subtitle != null ? 64 : 52);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: context.colors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 20,
      actions: actions,
      title: subtitle != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 1),
                Text(
                  subtitle!,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: context.colors.textSecondary),
                ),
              ],
            )
          : Text(title, style: Theme.of(context).textTheme.headlineSmall),
    );
  }
}
