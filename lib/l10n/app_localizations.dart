import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Korean Orthodox Church'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @parishes.
  ///
  /// In en, this message translates to:
  /// **'Parishes'**
  String get parishes;

  /// No description provided for @clergy.
  ///
  /// In en, this message translates to:
  /// **'Clergy'**
  String get clergy;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @saints.
  ///
  /// In en, this message translates to:
  /// **'Saints'**
  String get saints;

  /// No description provided for @textsOfTheDay.
  ///
  /// In en, this message translates to:
  /// **'Readings of the day'**
  String get textsOfTheDay;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @todayEvents.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayEvents;

  /// No description provided for @icons.
  ///
  /// In en, this message translates to:
  /// **'Icons'**
  String get icons;

  /// No description provided for @dayDescription.
  ///
  /// In en, this message translates to:
  /// **'The day'**
  String get dayDescription;

  /// No description provided for @noEventsToday.
  ///
  /// In en, this message translates to:
  /// **'No commemorations for this day'**
  String get noEventsToday;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @fasting.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get fasting;

  /// No description provided for @connectionError.
  ///
  /// In en, this message translates to:
  /// **'Could not connect. Check your internet or contact the developer.'**
  String get connectionError;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @emptySchedule.
  ///
  /// In en, this message translates to:
  /// **'No services scheduled'**
  String get emptySchedule;

  /// No description provided for @koreanDiocese.
  ///
  /// In en, this message translates to:
  /// **'Korean Diocese'**
  String get koreanDiocese;

  /// No description provided for @moscowPatriarchate.
  ///
  /// In en, this message translates to:
  /// **'Moscow Patriarchate'**
  String get moscowPatriarchate;

  /// No description provided for @archbishopOfKorea.
  ///
  /// In en, this message translates to:
  /// **'Archbishop of Korea'**
  String get archbishopOfKorea;

  /// No description provided for @theophan.
  ///
  /// In en, this message translates to:
  /// **'Theophan'**
  String get theophan;

  /// No description provided for @theophanRole.
  ///
  /// In en, this message translates to:
  /// **'Bishop of the Russian Orthodox Church'**
  String get theophanRole;

  /// No description provided for @hieromonk.
  ///
  /// In en, this message translates to:
  /// **'Hieromonk'**
  String get hieromonk;

  /// No description provided for @pavelChoi.
  ///
  /// In en, this message translates to:
  /// **'Pavel (Choi)'**
  String get pavelChoi;

  /// No description provided for @seoulCleric.
  ///
  /// In en, this message translates to:
  /// **'Cleric of the Church of the Resurrection of Christ in Seoul (South Korea)'**
  String get seoulCleric;

  /// No description provided for @feofanPozhidaev.
  ///
  /// In en, this message translates to:
  /// **'Feofan (Pozhidaev)'**
  String get feofanPozhidaev;

  /// No description provided for @hierodeacon.
  ///
  /// In en, this message translates to:
  /// **'Hierodeacon'**
  String get hierodeacon;

  /// No description provided for @nectariusLim.
  ///
  /// In en, this message translates to:
  /// **'Nectarius (Lim)'**
  String get nectariusLim;

  /// No description provided for @parishSeoul.
  ///
  /// In en, this message translates to:
  /// **'Church of the Resurrection of Christ'**
  String get parishSeoul;

  /// No description provided for @citySeoul.
  ///
  /// In en, this message translates to:
  /// **'Seoul'**
  String get citySeoul;

  /// No description provided for @addressSeoul.
  ///
  /// In en, this message translates to:
  /// **'한강대로 62 길 45-11,서울특별시,대한민국'**
  String get addressSeoul;

  /// No description provided for @parishPusan.
  ///
  /// In en, this message translates to:
  /// **'Church of the Nativity of the Blessed Virgin Mary'**
  String get parishPusan;

  /// No description provided for @cityPusan.
  ///
  /// In en, this message translates to:
  /// **'Pusan'**
  String get cityPusan;

  /// No description provided for @addressPusan.
  ///
  /// In en, this message translates to:
  /// **'동구 초량동 1163-5번지 3층 서향 1칸'**
  String get addressPusan;

  /// No description provided for @parishYeongjeong.
  ///
  /// In en, this message translates to:
  /// **'House Church of St. Anthony the Great'**
  String get parishYeongjeong;

  /// No description provided for @cityYeongjeong.
  ///
  /// In en, this message translates to:
  /// **'Yeongjeong'**
  String get cityYeongjeong;

  /// No description provided for @addressYeongjeong.
  ///
  /// In en, this message translates to:
  /// **'인천 중구 운북동 1257-50'**
  String get addressYeongjeong;

  /// No description provided for @parishIncheon.
  ///
  /// In en, this message translates to:
  /// **'All Saints\' Church'**
  String get parishIncheon;

  /// No description provided for @cityIncheon.
  ///
  /// In en, this message translates to:
  /// **'Incheon'**
  String get cityIncheon;

  /// No description provided for @addressIncheon.
  ///
  /// In en, this message translates to:
  /// **'인천 연수구 함박뫼로50번길 101, 광용빌딩, 6층'**
  String get addressIncheon;

  /// No description provided for @parishGyeongju.
  ///
  /// In en, this message translates to:
  /// **'Church of the Royal Passion-Bearers'**
  String get parishGyeongju;

  /// No description provided for @cityGyeongju.
  ///
  /// In en, this message translates to:
  /// **'Gyeongju'**
  String get cityGyeongju;

  /// No description provided for @addressGyeongju.
  ///
  /// In en, this message translates to:
  /// **'경북 경주시 금성로372번길 52'**
  String get addressGyeongju;

  /// No description provided for @parishCheongju.
  ///
  /// In en, this message translates to:
  /// **'Parish of the Archistrategos Michael of God'**
  String get parishCheongju;

  /// No description provided for @cityCheongju.
  ///
  /// In en, this message translates to:
  /// **'Cheongju'**
  String get cityCheongju;

  /// No description provided for @addressCheongju.
  ///
  /// In en, this message translates to:
  /// **'충북 청주시 흥덕구 봉명로 136 2층'**
  String get addressCheongju;

  /// No description provided for @parishGwangju.
  ///
  /// In en, this message translates to:
  /// **'Parish of the Exaltation of the Holy and Life-Giving Cross of the Lord'**
  String get parishGwangju;

  /// No description provided for @cityGwangju.
  ///
  /// In en, this message translates to:
  /// **'Gwangju'**
  String get cityGwangju;

  /// No description provided for @addressGwangju.
  ///
  /// In en, this message translates to:
  /// **'광주 월곡동 680-6 3층 302-1호'**
  String get addressGwangju;

  /// No description provided for @phoneShared.
  ///
  /// In en, this message translates to:
  /// **'+82 32-445-9988'**
  String get phoneShared;

  /// No description provided for @legalNameKo.
  ///
  /// In en, this message translates to:
  /// **'사단법인 대한정교회'**
  String get legalNameKo;

  /// No description provided for @legalName.
  ///
  /// In en, this message translates to:
  /// **'Korean Orthodox Church'**
  String get legalName;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressLabel;

  /// No description provided for @hqAddress.
  ///
  /// In en, this message translates to:
  /// **'대한민국 서울 한강로동 한강대로 62길 45-11, 2층'**
  String get hqAddress;

  /// No description provided for @donation.
  ///
  /// In en, this message translates to:
  /// **'Donation'**
  String get donation;

  /// No description provided for @bankName.
  ///
  /// In en, this message translates to:
  /// **'KB국민은행 (Kookmin Bank)'**
  String get bankName;

  /// No description provided for @bankAccount.
  ///
  /// In en, this message translates to:
  /// **'102701-04-491446'**
  String get bankAccount;

  /// No description provided for @bankHolder.
  ///
  /// In en, this message translates to:
  /// **'(대한정교회)'**
  String get bankHolder;

  /// No description provided for @officialName.
  ///
  /// In en, this message translates to:
  /// **'Official name'**
  String get officialName;

  /// No description provided for @officialNameValue.
  ///
  /// In en, this message translates to:
  /// **'Religious organization “Korean Orthodox Church”'**
  String get officialNameValue;

  /// No description provided for @contactInfo.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInfo;

  /// No description provided for @communitySupport.
  ///
  /// In en, this message translates to:
  /// **'Orthodox Community Support'**
  String get communitySupport;

  /// No description provided for @phoneKo.
  ///
  /// In en, this message translates to:
  /// **'+82 10 7381 3217'**
  String get phoneKo;

  /// No description provided for @supportKo.
  ///
  /// In en, this message translates to:
  /// **'한국어 지원 (Korean)'**
  String get supportKo;

  /// No description provided for @phoneRu.
  ///
  /// In en, this message translates to:
  /// **'+82 10 2783 8771'**
  String get phoneRu;

  /// No description provided for @supportRu.
  ///
  /// In en, this message translates to:
  /// **'Русский язык (Russian)'**
  String get supportRu;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'korthodox19@gmail.com'**
  String get email;

  /// No description provided for @emailInquiry.
  ///
  /// In en, this message translates to:
  /// **'Email Inquiry'**
  String get emailInquiry;

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'© Churchkr'**
  String get copyright;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ko', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
