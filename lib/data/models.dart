class AzbykaText {
  const AzbykaText({
    required this.id,
    required this.type,
    required this.title,
    this.body,
    this.url,
  });

  final int id;
  final int type;
  final String title;
  final String? body;
  final String? url;
}

class AzbykaSaint {
  const AzbykaSaint({
    required this.name,
    this.id,
    this.year,
    this.url,
    this.imageUrl,
    this.isGroup = false,
  });

  final int? id;
  final String name;
  final String? year;
  final String? url;
  final String? imageUrl;
  final bool isGroup;

  AzbykaSaint copyWith({
    int? id,
    String? name,
    String? year,
    String? url,
    String? imageUrl,
    bool? isGroup,
  }) {
    return AzbykaSaint(
      id: id ?? this.id,
      name: name ?? this.name,
      year: year ?? this.year,
      url: url ?? this.url,
      imageUrl: imageUrl ?? this.imageUrl,
      isGroup: isGroup ?? this.isGroup,
    );
  }
}

class AzbykaImage {
  const AzbykaImage({required this.title, required this.url, this.href});

  final String title;
  final String url;
  final String? href;
}

class AzbykaHoliday {
  const AzbykaHoliday({
    required this.title,
    this.id,
    this.text,
    this.url,
  });

  final int? id;
  final String title;
  final String? text;
  final String? url;
}

class AzbykaRef {
  const AzbykaRef({required this.id, this.title = '', this.url});

  final int id;
  final String title;
  final String? url;
}

class AzbykaHymn {
  const AzbykaHymn({
    required this.id,
    this.kind = '',
    this.title = '',
    this.text,
    this.voice,
    this.audioUrl,
    this.explanation,
  });

  final int id;
  final String kind;
  final String title;
  final String? text;
  final int? voice;
  final String? audioUrl;
  final String? explanation;
}

class AzbykaCanon {
  const AzbykaCanon({
    required this.id,
    this.kind = '',
    this.subtype,
    this.title = '',
    this.redirectUrl,
    this.text,
  });

  final int id;
  final String kind;
  final int? subtype;
  final String title;
  final String? redirectUrl;
  final String? text;
}

class AzbykaDay {
  const AzbykaDay({
    required this.dateLabel,
    required this.fasting,
    this.week,
    this.tone,
    this.fastingNote,
    this.weekColor,
    this.description,
    required this.images,
    required this.saints,
    required this.holidays,
    required this.texts,
    this.hymnRefs = const [],
    this.canonRefs = const [],
    this.ladyIconRefs = const [],
    this.hymns = const [],
    this.canons = const [],
  });

  final String dateLabel;
  final bool fasting;
  final String? week;
  final int? tone;
  final String? fastingNote;
  final String? weekColor;
  final String? description;
  final List<AzbykaImage> images;
  final List<AzbykaSaint> saints;
  final List<AzbykaHoliday> holidays;
  final List<AzbykaText> texts;
  final List<AzbykaRef> hymnRefs;
  final List<AzbykaRef> canonRefs;
  final List<AzbykaRef> ladyIconRefs;
  final List<AzbykaHymn> hymns;
  final List<AzbykaCanon> canons;
}

class ParishRecord {
  const ParishRecord({
    required this.id,
    required this.name,
    required this.city,
    required this.pid,
  });

  final String id;
  final String name;
  final String city;
  final String pid;
}

class ServiceRecord {
  const ServiceRecord({
    required this.id,
    required this.nameRu,
    required this.nameKr,
    required this.nameEn,
  });

  final String id;
  final String nameRu;
  final String nameKr;
  final String nameEn;

  String localizedName(String languageCode) {
    switch (languageCode) {
      case 'ko':
        return nameKr.isNotEmpty ? nameKr : nameRu;
      case 'en':
        return nameEn.isNotEmpty ? nameEn : nameRu;
      default:
        return nameRu;
    }
  }
}

class ScheduleRecord {
  const ScheduleRecord({
    required this.id,
    required this.name,
    required this.dateTime,
    this.serviceId,
  });

  final String id;
  final String name;
  final DateTime? dateTime;
  final String? serviceId;
}
