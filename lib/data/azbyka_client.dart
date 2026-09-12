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
    final saints = mergeSaints(
      fromPresentations: parsedHtml.saints,
      fromCache: parseSaintGroupsJson(abstractDate['saintsGroupAbstractDate']),
      images: images,
    );
    final hymnRefs = parseIdRefs(abstractDate['tropariaOrKontakia']);
    final canonRefs = parseIdRefs(abstractDate['canonsOrAkathists']);
    final ladyIconRefs = parseIdRefs(
      abstractDate['iconsOfOurLadyAbstractDates'],
      urlPrefix: '$azbykaOrigin/days/ikona-',
    );

    final week = dayType?.week;
    final fasting = dayType?.fasting ?? parsedHtml.fasting;
    final fastingNote = dayType?.fastingNote ?? parsedHtml.fastingNote;
    final tone = dayType?.tone;

    if (cache == null && presentationsJson == null && dayTypeJson == null) {
      throw AzbykaException('Could not load calendar day');
    }

    final extras = await Future.wait([
      _enrichSaints(saints),
      _loadHymns(hymnRefs),
      _loadCanons(canonRefs),
      _loadReadings(texts),
    ]);
    final enrichedSaints = extras[0] as List<AzbykaSaint>;
    final hymns = extras[1] as List<AzbykaHymn>;
    final canons = extras[2] as List<AzbykaCanon>;
    final readings = extras[3] as List<AzbykaText>;

    return AzbykaDay(
      dateLabel: dateKey,
      fasting: fasting,
      week: week,
      tone: tone,
      fastingNote: fastingNote,
      weekColor: dayType?.weekColor,
      images: images,
      saints: enrichedSaints,
      holidays: holidays,
      texts: [
        ...readings,
        ...texts.where((item) => item.type != 1),
      ],
      hymnRefs: hymnRefs,
      canonRefs: canonRefs,
      ladyIconRefs: ladyIconRefs,
      hymns: hymns,
      canons: canons,
    );
  }

  Future<Map<String, dynamic>?> loadSaintEntity({
    required int id,
    required bool isGroup,
  }) async {
    await ensureToken();
    final path = isGroup ? 'saints_groups/$id' : 'saints/$id';
    return _tryFetchJson(Uri.parse('$_base/$path'), auth: true);
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

  Future<List<AzbykaSaint>> _enrichSaints(List<AzbykaSaint> saints) async {
    final pending = saints
        .where(
          (saint) =>
              saint.id != null &&
              saint.id! > 0 &&
              (saint.imageUrl == null || saint.imageUrl!.isEmpty),
        )
        .take(20)
        .toList();
    if (pending.isEmpty) return saints;

    final fetched = await Future.wait(
      pending.map((saint) async {
        final json = await loadSaintEntity(
          id: saint.id!,
          isGroup: saint.isGroup,
        );
        if (json == null) return saint;
        return applySaintJson(saint, json);
      }),
    );
    final byId = {
      for (final saint in fetched)
        if (saint.id != null) saint.id!: saint,
    };
    return [
      for (final saint in saints) byId[saint.id] ?? saint,
    ];
  }

  Future<List<AzbykaHymn>> _loadHymns(List<AzbykaRef> refs) async {
    return _loadByRefs(
      refs,
      'troparia_or_kontakias',
      parseHymnJson,
      limit: 30,
    );
  }

  Future<List<AzbykaCanon>> _loadCanons(List<AzbykaRef> refs) async {
    return _loadByRefs(
      refs,
      'canons_or_akathists',
      parseCanonJson,
      limit: 25,
    );
  }

  Future<List<AzbykaText>> _loadReadings(List<AzbykaText> texts) async {
    final readings = texts.where((item) => item.type == 1 && item.id > 0).toList();
    if (readings.isEmpty) return const [];
    final loaded = await Future.wait(
      readings.map((item) async {
        try {
          return await loadText(item.id);
        } catch (_) {
          return item;
        }
      }),
    );
    return loaded;
  }

  Future<List<T>> _loadByRefs<T>(
    List<AzbykaRef> refs,
    String collection,
    T Function(Map<String, dynamic>) parse, {
    required int limit,
  }) async {
    final slice = refs.where((ref) => ref.id > 0).take(limit).toList();
    if (slice.isEmpty) return const [];
    final loaded = await Future.wait(
      slice.map((ref) async {
        final json = await _tryFetchJson(
          Uri.parse('$_base/$collection/${ref.id}'),
          auth: true,
        );
        if (json == null) return null;
        return parse(json);
      }),
    );
    return loaded.whereType<T>().toList();
  }
}
