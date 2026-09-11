import 'package:churchkr/data/azbyka_day_parser.dart';
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
}
