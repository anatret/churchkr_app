class ParishInfo {
  const ParishInfo({
    required this.pid,
    required this.imageAsset,
    required this.nameKey,
    required this.cityKey,
    required this.addressKey,
    required this.phone,
  });

  final String pid;
  final String imageAsset;
  final String nameKey;
  final String cityKey;
  final String addressKey;
  final String phone;
}

class ClergyInfo {
  const ClergyInfo({
    required this.imageAsset,
    required this.rankKey,
    required this.nameKey,
    required this.roleKey,
    this.wikiUrl,
  });

  final String imageAsset;
  final String rankKey;
  final String nameKey;
  final String roleKey;
  final String? wikiUrl;
}

class ContentCatalog {
  static const parishes = <ParishInfo>[
    ParishInfo(
      pid: 'xEuvldPGXgSJYDo4O0ru',
      imageAsset: 'assets/images/seoul.jpeg',
      nameKey: 'parishSeoul',
      cityKey: 'citySeoul',
      addressKey: 'addressSeoul',
      phone: '+82 32-445-9988',
    ),
    ParishInfo(
      pid: 'uQXVMYzjM3XbaIFCNnGF',
      imageAsset: 'assets/images/pusan.jpeg',
      nameKey: 'parishPusan',
      cityKey: 'cityPusan',
      addressKey: 'addressPusan',
      phone: '+82 32-445-9988',
    ),
    ParishInfo(
      pid: 'jW4Z3avcSq6Jo0xKEYM4',
      imageAsset: 'assets/images/endjon.jpeg',
      nameKey: 'parishYeongjeong',
      cityKey: 'cityYeongjeong',
      addressKey: 'addressYeongjeong',
      phone: '+82 32-445-9988',
    ),
    ParishInfo(
      pid: 'Te0UrsITZzeXH94HuPmx',
      imageAsset: 'assets/images/inchon.jpeg',
      nameKey: 'parishIncheon',
      cityKey: 'cityIncheon',
      addressKey: 'addressIncheon',
      phone: '+82 32-445-9988',
    ),
    ParishInfo(
      pid: 'cLjKDOpNox4Mzp05MWSc',
      imageAsset: 'assets/images/kenju.jpeg',
      nameKey: 'parishGyeongju',
      cityKey: 'cityGyeongju',
      addressKey: 'addressGyeongju',
      phone: '+82 32-445-9988',
    ),
    ParishInfo(
      pid: 'rwswyLpd03o1J1S4bqOA',
      imageAsset: 'assets/images/chonju.jpeg',
      nameKey: 'parishCheongju',
      cityKey: 'cityCheongju',
      addressKey: 'addressCheongju',
      phone: '+82 32-445-9988',
    ),
    ParishInfo(
      pid: 'xEuvldPGXgSJYDo4O0ru',
      imageAsset: 'assets/images/kwangu.jpeg',
      nameKey: 'parishGwangju',
      cityKey: 'cityGwangju',
      addressKey: 'addressGwangju',
      phone: '+82 32-445-9988',
    ),
  ];

  static const clergy = <ClergyInfo>[
    ClergyInfo(
      imageAsset: 'assets/images/feeofan.jpeg',
      rankKey: 'archbishopOfKorea',
      nameKey: 'theophan',
      roleKey: 'theophanRole',
      wikiUrl:
          'https://ru.wikipedia.org/wiki/%D0%A4%D0%B5%D0%BE%D1%84%D0%B0%D0%BD_(%D0%9A%D0%B8%D0%BC)',
    ),
    ClergyInfo(
      imageAsset: 'assets/images/paavel.jpeg',
      rankKey: 'hieromonk',
      nameKey: 'pavelChoi',
      roleKey: 'seoulCleric',
    ),
    ClergyInfo(
      imageAsset: 'assets/images/poojidaev.jpeg',
      rankKey: 'hieromonk',
      nameKey: 'feofanPozhidaev',
      roleKey: 'seoulCleric',
    ),
    ClergyInfo(
      imageAsset: 'assets/images/neektariy.jpeg',
      rankKey: 'hierodeacon',
      nameKey: 'nectariusLim',
      roleKey: 'seoulCleric',
    ),
  ];

  static const textTypes = <int, String>{
    1: 'Чтения Св. Писания',
    2: 'Богослужебные Указания',
    3: 'Цитата дня',
    4: 'Мысли св. Феофана Затворника',
    5: 'Притча дня',
    6: 'Проповедь дня',
    7: 'День в истории христианской Церкви',
    8: 'Книги, статьи, стихи, кроссворды, тесты',
    9: 'Вопрос священнику / Практические советы',
    10: 'Важная информация',
    11: 'Аудиокниги и фильмы',
    12: 'Основы православия',
  };
}
