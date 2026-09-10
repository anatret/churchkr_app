/// Azbyka.ru API credentials used by the previous FlutterFlow app.
/// Override in CI with --dart-define=AZBYKA_EMAIL=... --dart-define=AZBYKA_PASSWORD=...
class AzbykaAuth {
  static const email = String.fromEnvironment(
    'AZBYKA_EMAIL',
    defaultValue: 'anatret1@gmail.com',
  );
  static const password = String.fromEnvironment(
    'AZBYKA_PASSWORD',
    defaultValue: 'VskwjMKLJ2EejTS',
  );
}
