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
      } else if (href.contains('/sv-')) {
        final year = RegExp(r'\((.*?)\)').firstMatch(title)?.group(1);
        final name = title.replaceAll(RegExp(r'\(.*?\)'), '').trim();
        if (name.isNotEmpty) {
          saints.add(AzbykaSaint(name: name, year: year, url: href));
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
