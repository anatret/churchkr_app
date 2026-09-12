import 'package:churchkr/core/theme.dart';
import 'package:churchkr/data/azbyka_day_parser.dart';
import 'package:churchkr/data/models.dart';
import 'package:churchkr/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DayReadingsCard extends StatelessWidget {
  const DayReadingsCard({super.key, required this.readings});

  final List<AzbykaText> readings;

  @override
  Widget build(BuildContext context) {
    return _LiturgyCard(
      children: [
        for (final reading in readings)
          ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            title: Text(
              reading.title.isEmpty
                  ? AppLocalizations.of(context)!.textsOfTheDay
                  : reading.title,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  stripHtml(reading.body),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.45,
                      ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class DayHymnsCard extends StatelessWidget {
  const DayHymnsCard({super.key, required this.hymns});

  final List<AzbykaHymn> hymns;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _LiturgyCard(
      children: [
        for (final hymn in hymns)
          ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            title: Text(
              _hymnTitle(hymn, l10n),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: hymn.voice == null ? null : Text(l10n.toneNumber(hymn.voice!)),
            children: [
              if (stripHtml(hymn.text).isNotEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    stripHtml(hymn.text),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.45,
                        ),
                  ),
                ),
              if (hymn.audioUrl != null && hymn.audioUrl!.isNotEmpty)
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    tooltip: l10n.listenAudio,
                    onPressed: () => launchUrl(
                      Uri.parse(hymn.audioUrl!),
                      mode: LaunchMode.externalApplication,
                    ),
                    icon: const Icon(Icons.volume_up_outlined),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  String _hymnTitle(AzbykaHymn hymn, AppLocalizations l10n) {
    final kind = hymn.kind.trim();
    final title = hymn.title.trim();
    if (kind.isNotEmpty && title.isNotEmpty && kind != title) {
      return '$kind. $title';
    }
    if (title.isNotEmpty) return title;
    if (kind.isNotEmpty) return kind;
    return l10n.hymnsOfTheDay;
  }
}

class DayCanonsCard extends StatelessWidget {
  const DayCanonsCard({super.key, required this.canons});

  final List<AzbykaCanon> canons;

  @override
  Widget build(BuildContext context) {
    return _LiturgyCard(
      children: [
        for (final canon in canons)
          ListTile(
            title: Text(
              canon.title.isEmpty ? canon.kind : canon.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: canon.kind.isEmpty || canon.kind == canon.title
                ? null
                : Text(canon.kind),
            trailing: canon.redirectUrl == null || canon.redirectUrl!.isEmpty
                ? null
                : const Icon(Icons.open_in_new, size: 18),
            onTap: canon.redirectUrl == null || canon.redirectUrl!.isEmpty
                ? null
                : () => launchUrl(
                      Uri.parse(canon.redirectUrl!),
                      mode: LaunchMode.externalApplication,
                    ),
          ),
      ],
    );
  }
}

class _LiturgyCard extends StatelessWidget {
  const _LiturgyCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ChurchColors.surfaceSoft,
      elevation: 0,
      borderRadius: BorderRadius.circular(22),
      child: Column(children: children),
    );
  }
}
