import 'package:churchkr/core/locale_controller.dart';
import 'package:churchkr/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LocaleController>();
    const options = [
      (Locale('ko'), '한국어'),
      (Locale('ru'), 'Русский'),
      (Locale('en'), 'English'),
    ];
    return Padding(
      padding: compact
          ? EdgeInsets.zero
          : const EdgeInsets.only(top: 12, right: 12),
      child: Align(
        alignment: Alignment.topRight,
        child: Material(
          color: ChurchColors.surfaceSoft,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final option in options)
                  TextButton(
                    onPressed: () => controller.setLocale(option.$1),
                    style: TextButton.styleFrom(
                      foregroundColor:
                          controller.locale.languageCode == option.$1.languageCode
                              ? ChurchColors.primary
                              : ChurchColors.secondaryText,
                    ),
                    child: Text(option.$2),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BackdropScaffold extends StatelessWidget {
  const BackdropScaffold({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/back7.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
            child: SizedBox.expand(),
          ),
          SafeArea(child: child),
        ],
      ),
    );
  }
}
