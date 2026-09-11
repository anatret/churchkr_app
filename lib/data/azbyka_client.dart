import 'dart:convert';

import 'package:churchkr/config/azbyka_auth.dart';
import 'package:churchkr/data/models.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AzbykaException implements Exception {
  AzbykaException(this.message);
  final String message;

  @override
  String toString() => message;
}

class AzbykaClient {
  AzbykaClient({http.Client? httpClient})
      : _http = httpClient ?? http.Client();

  static const _base = 'https://azbyka.ru/days/api';
  final http.Client _http;
  String? _token;

  Future<String> ensureToken() async {
    if (_token != null && _token!.isNotEmpty) return _token!;
    final response = await _http.post(
      Uri.parse('$_base/login'),
      headers: const {
        'accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': AzbykaAuth.email,
        'password': AzbykaAuth.password,
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AzbykaException('Azbyka login failed (${response.statusCode})');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    _token = body['token'] as String?;
    if (_token == null || _token!.isEmpty) {
      throw AzbykaException('Azbyka login returned no token');
    }
    return _token!;
  }

  Map<String, String> get _headers => {
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_token ?? ''}',
      };

  Future<AzbykaDay> loadDay(DateTime date) async {
    await ensureToken();
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    final uri = Uri.parse('$_base/cache_dates').replace(
      queryParameters: {'date[exact]': dateKey},
    );
    final response = await _http.get(uri, headers: _headers);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AzbykaException('Could not load calendar day');
    }
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! List || decoded.isEmpty) {
      return AzbykaDay(
        dateLabel: dateKey,
        fasting: false,
        images: const [],
        saints: const [],
        holidays: const [],
        texts: const [],
      );
    }
    final first = decoded.first as Map<String, dynamic>;
    final abstractDate =
        (first['abstractDate'] as Map<String, dynamic>?) ?? first;
    final textsJson = abstractDate['texts'] as List<dynamic>? ?? const [];
    final texts = textsJson
        .whereType<Map<String, dynamic>>()
        .map(
          (item) => AzbykaText(
            id: (item['id'] as num?)?.toInt() ?? 0,
            type: (item['type'] as num?)?.toInt() ?? 0,
            title: (item['title'] as String?) ?? '',
            url: item['url'] as String?,
          ),
        )
        .toList();

    final parsed = _parsePresentations(abstractDate);
    return AzbykaDay(
      dateLabel: parsed.dateLabel.isEmpty ? dateKey : parsed.dateLabel,
      fasting: parsed.fasting,
      week: parsed.week,
      tone: parsed.tone,
      fastingNote: parsed.fastingNote,
      description: parsed.description,
      images: parsed.images,
      saints: parsed.saints,
      holidays: _parseHolidays(abstractDate['holidays']),
      texts: texts,
    );
  }

  Future<AzbykaText> loadText(int id) async {
    await ensureToken();
    final response = await _http.get(
      Uri.parse('$_base/texts/$id'),
      headers: _headers,
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AzbykaException('Could not load text');
    }
    final data =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return AzbykaText(
      id: (data['id'] as num?)?.toInt() ?? id,
      type: (data['type'] as num?)?.toInt() ?? 0,
      title: (data['title'] as String?) ?? '',
      body: data['text'] as String?,
      url: data['url'] as String?,
    );
  }

  List<AzbykaHoliday> _parseHolidays(dynamic raw) {
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
      holidays.add(
        AzbykaHoliday(
          title: title.trim(),
          text: map['text'] as String?,
          url: map['url'] as String? ?? map['uri'] as String?,
        ),
      );
    }
    return holidays;
  }

  ({
    String dateLabel,
    bool fasting,
    String? week,
    String? tone,
    String? fastingNote,
    String? description,
    List<AzbykaImage> images,
    List<AzbykaSaint> saints,
  }) _parsePresentations(Map<String, dynamic> data) {
    final html = (data['presentations'] as String?) ?? '';
    final imgTags = data['imgs'] as List<dynamic>? ?? const [];
    final images = <AzbykaImage>[];
    for (final tag in imgTags) {
      if (tag is! String) continue;
      final title = RegExp(r'title="([^"]+)"').firstMatch(tag)?.group(1) ??
          'Икона';
      var url = RegExp(r'src="([^"]+)"').firstMatch(tag)?.group(1) ?? '';
      if (url.isEmpty) continue;
      if (!url.startsWith('http')) url = 'https://azbyka.ru$url';
      images.add(AzbykaImage(title: title, url: url));
    }

    final saints = <AzbykaSaint>[];
    final liMatches = RegExp(
      r'<li class="ideograph-\d+">.*?<a[^>]*>(.*?)</a>',
      dotAll: true,
    ).allMatches(html);
    for (final match in liMatches) {
      final clean = (match.group(1) ?? '')
          .replaceAll(RegExp(r'<[^>]+>'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      if (clean.isEmpty) continue;
      final year = RegExp(r'\((.*?)\)').firstMatch(clean)?.group(1);
      final name = clean.replaceAll(RegExp(r'\(.*?\)'), '').trim();
      if (name.isNotEmpty) {
        saints.add(AzbykaSaint(name: name, year: year));
      }
    }

    final date = RegExp(r'(\d{1,2}\s+[а-яА-ЯёЁ]+\s+\d{4})').firstMatch(html);
    final week = _firstHtmlText(html, [
      r'class="[^"]*week[^"]*"[^>]*>([^<]+)',
      r'(Седмица[^<]{3,80})',
      r'(Неделя[^<]{3,80})',
    ]);
    final tone = _firstHtmlText(html, [
      r'(Глас\s+[^\s<,]+)',
      r'class="[^"]*glas[^"]*"[^>]*>([^<]+)',
    ]);
    final fastingNote = _firstHtmlText(html, [
      r'fasting-message[^>]*>([^<]+)',
      r'class="[^"]*fasting[^"]*"[^>]*>([^<]+)',
    ]);
    final fasting = (fastingNote != null && fastingNote.isNotEmpty) ||
        (html.contains('class="fasting-message"') &&
            !html.contains('fasting-message"></div>'));
    final descriptionParts = <String>[
      if (week != null) week,
      if (tone != null) tone,
      if (fastingNote != null && fastingNote.toLowerCase() != 'пост')
        fastingNote,
    ];

    return (
      dateLabel: date?.group(1) ?? '',
      fasting: fasting,
      week: week,
      tone: tone,
      fastingNote: fastingNote,
      description: descriptionParts.isEmpty ? null : descriptionParts.join('. '),
      images: images,
      saints: saints,
    );
  }

  String? _firstHtmlText(String html, List<String> patterns) {
    for (final pattern in patterns) {
      final match =
          RegExp(pattern, caseSensitive: false, dotAll: true).firstMatch(html);
      final value = (match?.group(1) ?? '')
          .replaceAll(RegExp(r'<[^>]+>'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      if (value.isNotEmpty) return value;
    }
    return null;
  }
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
