import 'package:churchkr/core/theme.dart';
import 'package:churchkr/data/azbyka_client.dart';
import 'package:churchkr/data/azbyka_day_parser.dart';
import 'package:churchkr/data/content_catalog.dart';
import 'package:churchkr/data/models.dart';
import 'package:flutter/material.dart';
import 'package:churchkr/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class TextPage extends StatefulWidget {
  const TextPage({super.key, required this.textId});

  final int textId;

  @override
  State<TextPage> createState() => _TextPageState();
}

class _TextPageState extends State<TextPage> {
  late final Future<AzbykaText> _future =
      context.read<AzbykaClient>().loadText(widget.textId);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<AzbykaText>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(l10n.connectionError));
          }
          final text = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                ContentCatalog.textTypes[text.type] ?? text.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (text.title.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  text.title,
                  style: const TextStyle(color: ChurchColors.secondaryText),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                stripHtml(text.body),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
              ),
              if (text.url != null && text.url!.isNotEmpty) ...[
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => launchUrl(
                    Uri.parse(
                      text.url!.startsWith('http')
                          ? text.url!
                          : 'https://azbyka.ru${text.url}',
                    ),
                    mode: LaunchMode.externalApplication,
                  ),
                  child: const Text('azbyka.ru'),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
