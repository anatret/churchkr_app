import 'package:churchkr/core/theme.dart';
import 'package:churchkr/features/clergy/clergy_page.dart';
import 'package:churchkr/features/home/home_page.dart';
import 'package:churchkr/features/parishes/parishes_page.dart';
import 'package:flutter/material.dart';
import 'package:churchkr/l10n/app_localizations.dart';

class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const pages = [
      HomePage(),
      ParishesPage(),
      ClergyPage(),
    ];
    return Scaffold(
      backgroundColor: ChurchColors.background,
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (value) => setState(() => _index = value),
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: l10n.home),
          BottomNavigationBarItem(
            icon: const Icon(Icons.schedule),
            label: l10n.parishes,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.church_outlined),
            label: l10n.clergy,
          ),
        ],
      ),
    );
  }
}
