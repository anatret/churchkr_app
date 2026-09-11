import 'dart:convert';

import 'package:churchkr/config/azbyka_auth.dart';
import 'package:churchkr/data/azbyka_day_parser.dart';
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
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    final results = await Future.wait([
      _tryFetchCacheDate(dateKey),
      _tryFetchJson(
        Uri.parse('https://azbyka.ru/days/widgets/presentations.json').replace(
          queryParameters: {'date': dateKey, 'image': '1'},
        ),
        auth: false,
      ),
      _tryFetchJson(
        Uri.parse('$_base/daytype/$dateKey.json'),
        auth: false,
      ),
    ]);

    final cache = results[0];
    final presentationsJson = results[1];
    final dayTypeJson = results[2];

    Map<String, dynamic> abstractDate = const {};
    if (cache is List && cache.isNotEmpty && cache.first is Map) {
      final first = (cache.first as Map).cast<String, dynamic>();
      abstractDate =
          (first['abstractDate'] as Map<String, dynamic>?) ?? first;
    } else if (cache is Map<String, dynamic>) {
      abstractDate =
          (cache['abstractDate'] as Map<String, dynamic>?) ?? cache;
    }

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

    final presentationsHtml = (presentationsJson?['presentations'] as String?) ??
        (abstractDate['presentations'] as String?) ??
        '';
    final imgTags = presentationsJson?['imgs'] ?? abstractDate['imgs'];
    final parsedHtml = parsePresentationsHtml(presentationsHtml);
    final dayType = dayTypeJson == null
        ? null
        : parseDayType(dayTypeJson);

    final holidays = mergeHolidays(
      parseHolidaysJson(abstractDate['holidays']),
      parsedHtml.holidays,
    );
    final images = parsePresentationImages(imgTags);
    final saints = parsedHtml.saints;

    final week = dayType?.week;
    final fasting = dayType?.fasting ?? parsedHtml.fasting;
    final fastingNote = dayType?.fastingNote ?? parsedHtml.fastingNote;
    final tone = dayType?.tone;

    if (cache == null && presentationsJson == null && dayTypeJson == null) {
      throw AzbykaException('Could not load calendar day');
    }

    return AzbykaDay(
      dateLabel: dateKey,
      fasting: fasting,
      week: week,
      tone: tone,
      fastingNote: fastingNote,
      weekColor: dayType?.weekColor,
      images: images,
      saints: saints,
      holidays: holidays,
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

  Future<dynamic> _tryFetchCacheDate(String dateKey) async {
    try {
      await ensureToken();
      final uri = Uri.parse('$_base/cache_dates').replace(
        queryParameters: {'date[exact]': dateKey},
      );
      final response = await _http.get(uri, headers: _headers);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }
      return jsonDecode(utf8.decode(response.bodyBytes));
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _tryFetchJson(
    Uri uri, {
    required bool auth,
  }) async {
    try {
      if (auth) await ensureToken();
      final response = await _http.get(
        uri,
        headers: auth
            ? _headers
            : const {'accept': 'application/json'},
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }
}
