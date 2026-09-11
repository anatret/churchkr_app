import 'package:churchkr/core/catalog_l10n.dart';
import 'package:churchkr/core/theme.dart';
import 'package:churchkr/data/content_catalog.dart';
import 'package:churchkr/features/parishes/schedule_sheet.dart';
import 'package:churchkr/features/widgets/chrome.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:churchkr/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class ParishesPage extends StatelessWidget {
  const ParishesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BackdropScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          const LanguageSwitcher(),
          Text(
            l10n.koreanDiocese,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(
            l10n.moscowPatriarchate,
            style: const TextStyle(color: ChurchColors.secondaryText),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.parishes.toUpperCase(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          for (final parish in ContentCatalog.parishes)
            _ParishCard(parish: parish),
          const SizedBox(height: 24),
          _ContactsCard(),
        ],
      ),
    );
  }
}

class _ParishCard extends StatelessWidget {
  const _ParishCard({required this.parish});

  final ParishInfo parish;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: ChurchColors.surfaceSoft,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset(parish.imageAsset, height: 220, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    catalogText(l10n, parish.nameKey),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    catalogText(l10n, parish.cityKey),
                    style: const TextStyle(color: ChurchColors.secondaryText),
                  ),
                  const SizedBox(height: 8),
                  Text(catalogText(l10n, parish.addressKey)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => launchUrl(Uri.parse('tel:${parish.phone}')),
                    child: Text(
                      parish.phone,
                      style: const TextStyle(
                        color: ChurchColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => ScheduleSheet(pid: parish.pid),
                    ),
                    child: Text(l10n.schedule),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: ChurchColors.surfaceSoft,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.legalNameKo, style: Theme.of(context).textTheme.titleLarge),
            Text(l10n.legalName),
            const SizedBox(height: 12),
            Text(l10n.addressLabel,
                style: const TextStyle(color: ChurchColors.secondaryText)),
            Text(l10n.hqAddress),
            const SizedBox(height: 12),
            Text(l10n.donation,
                style: const TextStyle(color: ChurchColors.secondaryText)),
            Text(l10n.bankName),
            InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: l10n.bankAccount));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.bankAccount)),
                );
              },
              child: Text(
                l10n.bankAccount,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Text(l10n.bankHolder),
            const SizedBox(height: 16),
            Text(l10n.contactInfo, style: Theme.of(context).textTheme.titleMedium),
            Text(l10n.communitySupport),
            const SizedBox(height: 8),
            _ContactRow(phone: l10n.phoneKo, label: l10n.supportKo),
            _ContactRow(phone: l10n.phoneRu, label: l10n.supportRu),
            InkWell(
              onTap: () => launchUrl(Uri.parse('mailto:${l10n.email}')),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  l10n.email,
                  style: const TextStyle(color: ChurchColors.primary),
                ),
              ),
            ),
            Text(l10n.copyright,
                style: const TextStyle(color: ChurchColors.secondaryText)),
          ],
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.phone, required this.label});

  final String phone;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(phone),
      subtitle: Text(label),
      onTap: () => launchUrl(Uri.parse('tel:$phone')),
    );
  }
}
