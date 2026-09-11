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
  const AzbykaSaint({required this.name, this.year});

  final String name;
  final String? year;
}

class AzbykaImage {
  const AzbykaImage({required this.title, required this.url});

  final String title;
  final String url;
}

class AzbykaHoliday {
  const AzbykaHoliday({
    required this.title,
    this.text,
    this.url,
  });

  final String title;
  final String? text;
  final String? url;
}

class AzbykaDay {
  const AzbykaDay({
    required this.dateLabel,
    required this.fasting,
    this.week,
    this.tone,
    this.fastingNote,
    this.description,
    required this.images,
    required this.saints,
    required this.holidays,
    required this.texts,
  });

  final String dateLabel;
  final bool fasting;
  final String? week;
  final String? tone;
  final String? fastingNote;
  final String? description;
  final List<AzbykaImage> images;
  final List<AzbykaSaint> saints;
  final List<AzbykaHoliday> holidays;
  final List<AzbykaText> texts;
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
