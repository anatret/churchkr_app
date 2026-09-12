import 'package:cached_network_image/cached_network_image.dart';
import 'package:churchkr/core/theme.dart';
import 'package:churchkr/data/azbyka_client.dart';
import 'package:churchkr/data/azbyka_day_parser.dart';
import 'package:churchkr/data/models.dart';
import 'package:churchkr/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SaintPage extends StatefulWidget {
  const SaintPage({super.key, required this.saint});

  final AzbykaSaint saint;

  @override
  State<SaintPage> createState() => _SaintPageState();
}

class _SaintPageState extends State<SaintPage> {
  late final Future<AzbykaSaintDetail> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<AzbykaSaintDetail> _load() async {
    final saint = widget.saint;
    if (saint.id == null || saint.id == 0) {
      return AzbykaSaintDetail(saint: saint);
    }
    final json = await context.read<AzbykaClient>().loadSaintEntity(
          id: saint.id!,
          isGroup: saint.isGroup,
        );
    if (json == null) return AzbykaSaintDetail(saint: saint);
    final icons = <AzbykaImage>[];
    final rawIcons = json['icons'];
    if (rawIcons is List) {
      for (final icon in rawIcons) {
        if (icon is! Map) continue;
        final map = icon.cast<String, dynamic>();
        final url = firstIconUrl({'icons': [map]});
        if (url == null || url.isEmpty) continue;
        icons.add(
          AzbykaImage(
            title: (map['title'] as String?) ?? saint.name,
            url: url,
          ),
        );
      }
    }
    final body = _firstNonEmpty([
      json['description'] as String?,
      json['text'] as String?,
      json['life'] as String?,
    ]);
    return AzbykaSaintDetail(
      saint: applySaintJson(saint, json),
      body: body,
      icons: icons,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<AzbykaSaintDetail>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(l10n.connectionError));
          }
          final detail = snapshot.data!;
          final saint = detail.saint;
          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            children: [
              Text(
                saint.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              if (saint.year != null && saint.year!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  saint.year!,
                  style: const TextStyle(color: ChurchColors.secondaryText),
                ),
              ],
              if (detail.icons.isNotEmpty) ...[
                const SizedBox(height: 16),
                SizedBox(
                  height: 180,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: detail.icons.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final image = detail.icons[index];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: image.url,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
              ] else if (saint.imageUrl != null && saint.imageUrl!.isNotEmpty) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: saint.imageUrl!,
                    height: 220,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              if (detail.body != null && detail.body!.trim().isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  stripHtml(detail.body),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.5,
                      ),
                ),
              ],
              if (saint.url != null && saint.url!.isNotEmpty) ...[
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => launchUrl(
                    Uri.parse(saint.url!),
                    mode: LaunchMode.externalApplication,
                  ),
                  child: Text(l10n.openOnAzbyka),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class AzbykaSaintDetail {
  const AzbykaSaintDetail({
    required this.saint,
    this.body,
    this.icons = const [],
  });

  final AzbykaSaint saint;
  final String? body;
  final List<AzbykaImage> icons;
}

String? _firstNonEmpty(List<String?> values) {
  for (final value in values) {
    final trimmed = value?.trim();
    if (trimmed != null && trimmed.isNotEmpty) return trimmed;
  }
  return null;
}
