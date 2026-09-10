import 'package:churchkr/core/theme.dart';
import 'package:churchkr/data/azbyka_client.dart';
import 'package:churchkr/data/content_catalog.dart';
import 'package:churchkr/data/models.dart';
import 'package:churchkr/features/home/text_page.dart';
import 'package:churchkr/features/widgets/chrome.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<AzbykaDay> _future;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    _future = context.read<AzbykaClient>().loadDay(_date);
  }

  void _reload(DateTime date) {
    setState(() {
      _date = date;
      _future = context.read<AzbykaClient>().loadDay(date);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BackdropScaffold(
      child: Column(
        children: [
          const LanguageSwitcher(),
          Expanded(
            child: FutureBuilder<AzbykaDay>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(l10n.connectionError),
                    ),
                  );
                }
                final day = snapshot.data!;
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    _DateCard(
                      label: day.dateLabel,
                      fasting: day.fasting,
                      onPick: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _date,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) _reload(picked);
                      },
                    ),
                    if (day.images.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 220,
                        child: PageView(
                          children: [
                            for (final image in day.images)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: CachedNetworkImage(
                                    imageUrl: image.url,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                    if (day.saints.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _SectionTitle(l10n.saints),
                      const SizedBox(height: 8),
                      for (final saint in day.saints)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            saint.year == null || saint.year!.isEmpty
                                ? saint.name
                                : '${saint.name} (${saint.year})',
                          ),
                        ),
                    ],
                    if (day.texts.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _SectionTitle(l10n.textsOfTheDay),
                      const SizedBox(height: 8),
                      for (final text in day.texts)
                        Card(
                          color: ChurchColors.surfaceSoft,
                          child: ListTile(
                            title: Text(
                              ContentCatalog.textTypes[text.type] ?? text.title,
                            ),
                            subtitle: text.title.isEmpty ? null : Text(text.title),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => TextPage(textId: text.id),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DateCard extends StatelessWidget {
  const _DateCard({
    required this.label,
    required this.fasting,
    required this.onPick,
  });

  final String label;
  final bool fasting;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: ChurchColors.surfaceSoft,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onPick,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (fasting) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.fasting,
                  style: const TextStyle(color: ChurchColors.secondaryText),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            letterSpacing: 1.2,
            color: ChurchColors.primary,
          ),
    );
  }
}
