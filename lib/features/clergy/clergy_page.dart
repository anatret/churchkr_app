import 'package:churchkr/core/catalog_l10n.dart';
import 'package:churchkr/core/theme.dart';
import 'package:churchkr/data/content_catalog.dart';
import 'package:churchkr/features/widgets/chrome.dart';
import 'package:flutter/material.dart';
import 'package:churchkr/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class ClergyPage extends StatelessWidget {
  const ClergyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BackdropScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          const LanguageSwitcher(),
          Text(
            l10n.clergy.toUpperCase(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          for (final person in ContentCatalog.clergy)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Material(
                color: ChurchColors.surfaceSoft,
                borderRadius: BorderRadius.circular(24),
                clipBehavior: Clip.antiAlias,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      person.imageAsset,
                      width: 140,
                      height: 160,
                      fit: BoxFit.cover,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              catalogText(l10n, person.rankKey),
                              style: const TextStyle(
                                color: ChurchColors.secondaryText,
                              ),
                            ),
                            Text(
                              catalogText(l10n, person.nameKey),
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(catalogText(l10n, person.roleKey)),
                            if (person.wikiUrl != null)
                              TextButton(
                                onPressed: () => launchUrl(
                                  Uri.parse(person.wikiUrl!),
                                  mode: LaunchMode.externalApplication,
                                ),
                                child: const Text('wiki'),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
