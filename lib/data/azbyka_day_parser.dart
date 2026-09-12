import 'package:churchkr/data/models.dart';

const azbykaOrigin = 'https://azbyka.ru';

String azbykaAbsoluteUrl(String? raw) {
  if (raw == null || raw.isEmpty) return '';
  if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
  if (raw.startsWith('//')) return 'https:$raw';
  if (raw.startsWith('/')) return '$azbykaOrigin$raw';
  return '$azbykaOrigin/$raw';
}

int julianOffsetDays(int year) {
  if (year >= 2100) return 14;
  if (year >= 1900) return 13;
  return 12;
}

DateTime julianDateOf(DateTime gregorian) {
  final day = DateTime(gregorian.year, gregorian.month, gregorian.day);
  return day.subtract(Duration(days: julianOffsetDays(day.year)));
}

String? parseHexColor(String? raw) {
  if (raw == null) return null;
  final value = raw.trim();
  if (RegExp(r'^#?[0-9a-fA-F]{6}$').hasMatch(value)) {
    return value.startsWith('#') ? value : '#$value';
  }
  return null;
}

AzbykaDayType parseDayType(Map<String, dynamic> json) {
  final type = (json['type'] as String?)?.trim() ?? '';
  final fastingText = (json['fasting'] as String?)?.trim() ?? '';
  final description = json['description'] as String?;
  final voice = (json['voice'] as num?)?.toInt();
  final week = _firstNonEmpty([
    json['feed'] as String?,
    json['round_week'] as String?,
    json['weeks'] as String?,
  ]);
  final fasting = type == 'fasting' ||
      type == 'fast' ||
      fastingText.isNotEmpty;
  return AzbykaDayType(
    week: week,
    tone: voice,
    fasting: fasting,
    fastingNote: _firstNonEmpty([description, fastingText]),
    weekColor: parseHexColor(json['color'] as String?),
  );
}

List<AzbykaImage> parsePresentationImages(dynamic raw) {
  if (raw is! List) return const [];
  final images = <AzbykaImage>[];
  final seen = <String>{};
  for (final tag in raw) {
    if (tag is! String) continue;
    final title = _attr(tag, 'title') ?? 'Икона';
    final href = azbykaAbsoluteUrl(_attr(tag, 'href'));
    var src = _attr(tag, 'src') ?? '';
    src = azbykaAbsoluteUrl(src);
    if (src.isEmpty || !seen.add(src)) continue;
    images.add(AzbykaImage(title: title, url: src, href: href.isEmpty ? null : href));
  }
  return images;
}

PresentationsContent parsePresentationsHtml(String html) {
  final holidays = <AzbykaHoliday>[];
  final saints = <AzbykaSaint>[];
  final liMatches = RegExp(
    r'<li class="ideograph-\d+">(.*?)</li>',
    dotAll: true,
    caseSensitive: false,
  ).allMatches(html);

  for (final match in liMatches) {
    final li = match.group(1) ?? '';
    final anchors = RegExp(
      r'<a[^>]*href="([^"]+)"[^>]*>(.*?)</a>',
      dotAll: true,
      caseSensitive: false,
    ).allMatches(li);
    for (final anchor in anchors) {
      final href = azbykaAbsoluteUrl(anchor.group(1));
      if (href.contains('p-znaki-prazdnikov')) continue;
      final title = stripHtml(anchor.group(2)).trim();
      if (title.isEmpty) continue;
      if (href.contains('/prazdnik-') || href.contains('/ikona-')) {
        holidays.add(AzbykaHoliday(title: title, url: href));
      } else if (_isSaintHref(href)) {
        final year = RegExp(r'\((.*?)\)').firstMatch(title)?.group(1);
        final name = title.replaceAll(RegExp(r'\(.*?\)'), '').trim();
        if (name.isNotEmpty) {
          saints.add(
            AzbykaSaint(
              name: name,
              year: year,
              url: href,
              isGroup: _isSaintGroupHref(href),
            ),
          );
        }
      }
    }
  }

  final fastingNote = _firstHtmlText(html, [
    r'fasting-message[^>]*>([^<]+)',
  ]);
  final fasting = fastingNote != null && fastingNote.isNotEmpty;

  return PresentationsContent(
    holidays: holidays,
    saints: saints,
    fasting: fasting,
    fastingNote: fastingNote,
  );
}

List<AzbykaHoliday> parseHolidaysJson(dynamic raw) {
  if (raw is! List) return const [];
  final holidays = <AzbykaHoliday>[];
  for (final item in raw) {
    if (item is String) {
      final title = item.trim();
      if (title.isNotEmpty) holidays.add(AzbykaHoliday(title: title));
      continue;
    }
    if (item is! Map) continue;
    final map = item.cast<String, dynamic>();
    final title = (map['title'] as String?) ??
        (map['name'] as String?) ??
        (map['cacheTitle'] as String?) ??
        '';
    if (title.trim().isEmpty) continue;
    final uri = map['url'] as String? ?? map['uri'] as String?;
    String? url;
    if (uri != null && uri.trim().isNotEmpty) {
      final value = uri.trim();
      if (value.startsWith('http') || value.startsWith('/')) {
        url = azbykaAbsoluteUrl(value);
      } else {
        url = '$azbykaOrigin/days/prazdnik-$value';
      }
    }
    holidays.add(
      AzbykaHoliday(
        id: (map['id'] as num?)?.toInt(),
        title: title.trim(),
        text: map['text'] as String?,
        url: url,
      ),
    );
  }
  return holidays;
}

List<AzbykaHoliday> mergeHolidays(
  List<AzbykaHoliday> primary,
  List<AzbykaHoliday> extra,
) {
  final result = [...primary];
  final seen = {
    for (final item in primary) _normalizeTitle(item.title),
  };
  for (final item in extra) {
    if (seen.add(_normalizeTitle(item.title))) {
      result.add(item);
    }
  }
  return result;
}

List<AzbykaSaint> parseSaintGroupsJson(dynamic raw) {
  if (raw is! List) return const [];
  final groups = <AzbykaSaint>[];
  for (final item in raw) {
    if (item is! Map) continue;
    final wrapper = item.cast<String, dynamic>();
    final group = wrapper['saintsGroup'] is Map
        ? (wrapper['saintsGroup'] as Map).cast<String, dynamic>()
        : wrapper;
    final id = (group['id'] as num?)?.toInt();
    final title = ((group['cacheTitle'] as String?) ??
            (group['title'] as String?) ??
            '')
        .trim();
    if (title.isEmpty && id == null) continue;
    final uri = (group['uri'] as String?) ?? (group['url'] as String?) ?? '';
    String? url;
    if (uri.isNotEmpty) {
      if (uri.startsWith('http') || uri.startsWith('/')) {
        url = azbykaAbsoluteUrl(uri);
      } else {
        url = '$azbykaOrigin/days/sv-sobor-$uri';
      }
    }
    groups.add(
      AzbykaSaint(
        id: id,
        name: title,
        url: url,
        isGroup: true,
      ),
    );
  }
  return groups;
}

List<AzbykaSaint> mergeSaints({
  required List<AzbykaSaint> fromPresentations,
  required List<AzbykaSaint> fromCache,
  List<AzbykaImage> images = const [],
}) {
  final result = <AzbykaSaint>[];
  final seen = <String>{};

  void add(AzbykaSaint saint) {
    final withImage = saint.imageUrl == null || saint.imageUrl!.isEmpty
        ? saint.copyWith(imageUrl: _imageForHref(images, saint.url))
        : saint;
    final key = _saintKey(withImage);
    if (!seen.add(key)) {
      final index = result.indexWhere((item) => _saintKey(item) == key);
      if (index >= 0) {
        result[index] = _preferSaint(result[index], withImage);
      }
      return;
    }
    result.add(withImage);
  }

  for (final saint in fromPresentations) {
    add(saint);
  }
  for (final saint in fromCache) {
    add(saint);
  }
  return result;
}

AzbykaSaint applySaintJson(AzbykaSaint saint, Map<String, dynamic> json) {
  final title = ((json['cacheTitle'] as String?) ??
          (json['title'] as String?) ??
          saint.name)
      .trim();
  final uri = json['uri'] as String?;
  String? url = saint.url;
  if ((url == null || url.isEmpty) && uri != null && uri.isNotEmpty) {
    url = saint.isGroup
        ? '$azbykaOrigin/days/sv-sobor-$uri'
        : '$azbykaOrigin/days/sv-$uri';
  }
  return saint.copyWith(
    name: saint.name.isNotEmpty ? saint.name : title,
    url: url,
    imageUrl: saint.imageUrl ?? firstIconUrl(json),
  );
}

String? firstIconUrl(Map<String, dynamic> json) {
  final icons = json['icons'];
  if (icons is! List) return null;
  for (final icon in icons) {
    if (icon is! Map) continue;
    final map = icon.cast<String, dynamic>();
    final url = _firstNonEmpty([
      map['preview_absolute_url_2x'] as String?,
      map['previewAbsoluteUrl2x'] as String?,
      map['preview_absolute_url'] as String?,
      map['src'] as String?,
      map['url'] as String?,
    ]);
    if (url != null && url.isNotEmpty) return azbykaAbsoluteUrl(url);
  }
  return null;
}

List<AzbykaRef> parseIdRefs(dynamic raw, {String? urlPrefix}) {
  if (raw is! List) return const [];
  final refs = <AzbykaRef>[];
  for (final item in raw) {
    if (item is num) {
      refs.add(AzbykaRef(id: item.toInt()));
      continue;
    }
    if (item is! Map) continue;
    final map = item.cast<String, dynamic>();
    final nested = map['saintsGroup'] is Map
        ? (map['saintsGroup'] as Map).cast<String, dynamic>()
        : map['iconsOfOurLady'] is Map
            ? (map['iconsOfOurLady'] as Map).cast<String, dynamic>()
            : map;
    final id = (nested['id'] as num?)?.toInt();
    if (id == null || id == 0) continue;
    final title = ((nested['title'] as String?) ??
            (nested['cacheTitle'] as String?) ??
            (nested['titleShort'] as String?) ??
            '')
        .trim();
    final uri = nested['uri'] as String? ?? nested['url'] as String?;
    String? url;
    if (uri != null && uri.isNotEmpty) {
      url = uri.startsWith('http') || uri.startsWith('/')
          ? azbykaAbsoluteUrl(uri)
          : (urlPrefix == null ? azbykaAbsoluteUrl(uri) : '$urlPrefix$uri');
    }
    refs.add(AzbykaRef(id: id, title: title, url: url));
  }
  return refs;
}

AzbykaHymn parseHymnJson(Map<String, dynamic> json) {
  final audio = json['audioSource'] as String?;
  return AzbykaHymn(
    id: (json['id'] as num?)?.toInt() ?? 0,
    kind: ((json['type'] as String?) ?? '').trim(),
    title: ((json['title'] as String?) ?? '').trim(),
    text: json['text'] as String?,
    voice: (json['voice'] as num?)?.toInt(),
    audioUrl: audio == null || audio.trim().isEmpty
        ? null
        : azbykaAbsoluteUrl(audio),
    explanation: json['explanation'] as String?,
  );
}

AzbykaCanon parseCanonJson(Map<String, dynamic> json) {
  final redirect = json['redirectUrl'] as String? ?? json['url'] as String?;
  final title = ((json['title'] as String?) ??
          (json['titleShort'] as String?) ??
          '')
      .trim();
  return AzbykaCanon(
    id: (json['id'] as num?)?.toInt() ?? 0,
    kind: ((json['type'] as String?) ?? '').trim(),
    subtype: (json['subtype'] as num?)?.toInt(),
    title: title,
    redirectUrl: redirect == null || redirect.trim().isEmpty
        ? null
        : azbykaAbsoluteUrl(redirect),
    text: json['text'] as String?,
  );
}

String stripHtml(String? raw) {
  if (raw == null || raw.isEmpty) return '';
  return raw
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n')
      .replaceAll(RegExp(r'<[^>]+>'), ' ')
      .replaceAll(RegExp(r'&nbsp;'), ' ')
      .replaceAll(RegExp(r'&quot;'), '"')
      .replaceAll(RegExp(r'&laquo;'), '«')
      .replaceAll(RegExp(r'&raquo;'), '»')
      .replaceAll(RegExp(r'&mdash;'), '—')
      .replaceAll(RegExp(r'\s+\n'), '\n')
      .replaceAll(RegExp(r'[ \t]+'), ' ')
      .trim();
}

class AzbykaDayType {
  const AzbykaDayType({
    this.week,
    this.tone,
    required this.fasting,
    this.fastingNote,
    this.weekColor,
  });

  final String? week;
  final int? tone;
  final bool fasting;
  final String? fastingNote;
  final String? weekColor;
}

class PresentationsContent {
  const PresentationsContent({
    required this.holidays,
    required this.saints,
    required this.fasting,
    this.fastingNote,
  });

  final List<AzbykaHoliday> holidays;
  final List<AzbykaSaint> saints;
  final bool fasting;
  final String? fastingNote;
}

String _normalizeTitle(String title) =>
    title.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();

String? _attr(String html, String name) {
  return RegExp(
    '$name="([^"]+)"',
    caseSensitive: false,
  ).firstMatch(html)?.group(1);
}

String? _firstNonEmpty(List<String?> values) {
  for (final value in values) {
    final trimmed = value?.trim();
    if (trimmed != null && trimmed.isNotEmpty) return trimmed;
  }
  return null;
}

String? _firstHtmlText(String html, List<String> patterns) {
  for (final pattern in patterns) {
    final match =
        RegExp(pattern, caseSensitive: false, dotAll: true).firstMatch(html);
    final value = stripHtml(match?.group(1)).trim();
    if (value.isNotEmpty) return value;
  }
  return null;
}

bool _isSaintHref(String href) {
  return href.contains('/sv-') || href.contains('/svv-');
}

bool _isSaintGroupHref(String href) {
  return href.contains('/svv-') || href.contains('/sv-sobor-');
}

String _saintKey(AzbykaSaint saint) {
  final url = (saint.url ?? '').toLowerCase();
  if (url.isNotEmpty) {
    final path = Uri.tryParse(url)?.path ?? url;
    return path.replaceAll(RegExp(r'[-_]+'), '-');
  }
  return _normalizeTitle(saint.name);
}

AzbykaSaint _preferSaint(AzbykaSaint current, AzbykaSaint extra) {
  return current.copyWith(
    id: current.id ?? extra.id,
    year: (current.year == null || current.year!.isEmpty) ? extra.year : current.year,
    url: (current.url == null || current.url!.isEmpty) ? extra.url : current.url,
    imageUrl: (current.imageUrl == null || current.imageUrl!.isEmpty)
        ? extra.imageUrl
        : current.imageUrl,
    isGroup: current.isGroup || extra.isGroup,
    name: current.name.length >= extra.name.length ? current.name : extra.name,
  );
}

String? _imageForHref(List<AzbykaImage> images, String? href) {
  if (href == null || href.isEmpty || images.isEmpty) return null;
  final needle = (Uri.tryParse(href)?.path ?? href).toLowerCase();
  for (final image in images) {
    final imageHref = image.href ?? '';
    if (imageHref.isEmpty) continue;
    final path = (Uri.tryParse(imageHref)?.path ?? imageHref).toLowerCase();
    if (path == needle || path.contains(needle) || needle.contains(path)) {
      return image.url;
    }
  }
  return null;
}
