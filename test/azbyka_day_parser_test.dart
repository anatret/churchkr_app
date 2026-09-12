import 'package:churchkr/data/azbyka_day_parser.dart';
import 'package:churchkr/data/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses daytype for a fasting Friday', () {
    final day = parseDayType({
      'feed': 'Седмица 15-я по Пятидесятнице',
      'round_week': 'Седмица 15-я по Пятидесятнице',
      'weeks': '',
      'color': '#FF4500',
      'type': 'fasting',
      'description': null,
      'fasting': '',
      'voice': 5,
    });
    expect(day.week, 'Седмица 15-я по Пятидесятнице');
    expect(day.fasting, isTrue);
    expect(day.tone, 5);
    expect(day.weekColor, '#FF4500');
  });

  test('julian date is 13 days behind in 2026', () {
    expect(
      julianDateOf(DateTime(2026, 9, 11)),
      DateTime(2026, 8, 29),
    );
  });

  test('parses presentation icons and the main feast', () {
    final images = parsePresentationImages([
      '<a title="Усекновение главы Иоанна" href="/days/prazdnik-useknovenie-glavy-proroka-predtechi-i-krestitelja-gospodnja-ioanna"><img src="/days/cache/icon.jpg"></a>',
    ]);
    expect(images, hasLength(1));
    expect(images.first.url, 'https://azbyka.ru/days/cache/icon.jpg');
    expect(images.first.href, contains('prazdnik-useknovenie'));

    const html = '''
<div class="azbyka-days"><div class="fasting-message"></div>
<ul class="paragraph-0"><li class="ideograph-1">
<a href="https://azbyka.ru/days/p-znaki-prazdnikov#table"><img src="1.svg"/></a>
<a href="https://azbyka.ru/days/prazdnik-useknovenie-glavy-proroka-predtechi-i-krestitelja-gospodnja-ioanna">Усекновение главы пророка, Предтечи и Крестителя Господня Иоанна</a>
</li></ul></div>
''';
    final parsed = parsePresentationsHtml(html);
    expect(parsed.holidays, hasLength(1));
    expect(parsed.holidays.first.title, contains('Усекновение главы'));
    expect(parsed.saints, isEmpty);
  });

  test('parses saint groups and individual saints from presentations', () {
    const html = '''
<li class="ideograph-7">
<a href="https://azbyka.ru/days/svv-aleksandr-konstantinopolskij-ioann-postnik-pavel-novyj">Свтт. Александра (340), Иоанна Постника (595)</a>
</li>
<li class="ideograph-4">
<a href="https://azbyka.ru/days/sv-aleksandr-svirskij">прп. Александра Свирского, игумена (1533)</a>
</li>
''';
    final parsed = parsePresentationsHtml(html);
    expect(parsed.saints, hasLength(2));
    expect(parsed.saints.first.isGroup, isTrue);
    expect(parsed.saints.first.name, contains('Александра'));
    expect(parsed.saints.last.isGroup, isFalse);
    expect(parsed.saints.last.year, '1533');
  });

  test('merges cache groups with presentation saints and icons', () {
    final merged = mergeSaints(
      fromPresentations: const [
        AzbykaSaint(
          name: 'прп. Александра Свирского',
          url: 'https://azbyka.ru/days/sv-aleksandr-svirskij',
        ),
      ],
      fromCache: const [
        AzbykaSaint(
          id: 42,
          name: 'Александр Свирский',
          url: 'https://azbyka.ru/days/sv-sobor-aleksandr-svirskij',
          isGroup: true,
        ),
      ],
      images: const [
        AzbykaImage(
          title: 'Александр Свирский',
          url: 'https://azbyka.ru/icon.png',
          href: 'https://azbyka.ru/days/sv-aleksandr-svirskij',
        ),
      ],
    );
    expect(merged.length, greaterThanOrEqualTo(1));
    expect(
      merged.any((item) => item.imageUrl == 'https://azbyka.ru/icon.png'),
      isTrue,
    );
  });

  test('parses hymn and canon payloads', () {
    final hymn = parseHymnJson({
      'id': 10,
      'type': 'Тропарь',
      'title': 'Предтече',
      'text': '<p>Память праведника</p>',
      'voice': 2,
      'audioSource': '/days/audio/t.mp3',
    });
    expect(hymn.kind, 'Тропарь');
    expect(hymn.voice, 2);
    expect(hymn.audioUrl, 'https://azbyka.ru/days/audio/t.mp3');

    final canon = parseCanonJson({
      'id': 3,
      'type': 'Канон',
      'title': 'Александру Невскому',
      'redirectUrl': '/days/kanon-aleksandru',
    });
    expect(canon.title, 'Александру Невскому');
    expect(canon.redirectUrl, 'https://azbyka.ru/days/kanon-aleksandru');
  });
}
