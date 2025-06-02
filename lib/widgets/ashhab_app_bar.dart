import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class AshhabAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  const AshhabAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.bottom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Image.asset(
              'assets/images/ashhab_logo.png',
              height: 40,
              fit: BoxFit.contain,
            ),
          ),
          Text(title),
        ],
      ),
      actions: actions,
      bottom: bottom,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade700,
              Colors.blue.shade500,
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(bottom == null ? kToolbarHeight : kToolbarHeight + 48);
} 