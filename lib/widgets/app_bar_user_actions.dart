import 'package:flutter/material.dart';

class AppBarUserActions extends StatelessWidget {
  final String name;
  final String? subtitle;
  final VoidCallback onLogout;

  const AppBarUserActions({
    super.key,
    required this.name,
    this.subtitle,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
            if (subtitle != null && subtitle!.isNotEmpty)
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onPrimary.withValues(alpha: 0.9),
                ),
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        const SizedBox(width: 12),
        CircleAvatar(
          backgroundColor: colorScheme.onPrimary,
          child: Icon(Icons.person, color: colorScheme.primary),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: onLogout,
          tooltip: 'Sair',
        ),
      ],
    );
  }
}
