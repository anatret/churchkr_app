# Churchkr (clean)

Новый Flutter-проект Корейской православной церкви. Старое приложение из FlutterFlow лежит рядом в `../churchkr` и больше не является исходником UI.

## Что перенесено со старого проекта

- Bundle ID / applicationId: `com.anatret.churchkr` (тот же листинг в Play и App Store)
- Имя на устройстве: **Church**
- Firebase-проект `churchk` (`google-services.json`, `GoogleService-Info.plist`)
- Иконки, splash, фото приходов и духовенства
- Коллекции Firestore: `parishes`, `schedules`, `services`, `users`, `tokens`
- API календаря Azbyka
- Языки: корейский, русский, английский

Версия для следующего релиза: `1.0.8+8` (в сторах сейчас `1.0.7+7`).

## Запуск

```bash
cd churchkr_app
flutter pub get
flutter run
```

## Публикация в сторы

Одной кнопки как во FlutterFlow здесь нет. Сборки делаются локально, загрузка — в консоли Google/Apple (или через Fastlane, если дадите API-ключи).

1. Положите upload-keystore в `android/` и заполните `android/key.properties` по образцу `android/key.properties.example` (тот же ключ, которым уже подписано приложение в Play).
2. Android: `flutter build appbundle`
3. iOS: откройте `ios/Runner.xcworkspace` в Xcode, выберите Team / сертификаты, затем `flutter build ipa`
4. Загрузите AAB в Play Console и IPA в App Store Connect / Transporter

Пока keystore не лежит в этом репозитории — его FlutterFlow не выгружает. Нужен файл, которым вы подписывали прошлые релизы.

## Что ещё не перенесено

Админка расписания и часть детальных экранов старого FlutterFlow (новости, отдельная calendar page). Их можно добавить в этот проект по мере необходимости.
