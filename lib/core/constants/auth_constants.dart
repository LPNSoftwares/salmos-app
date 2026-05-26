class AuthConstants {
  static const email = String.fromEnvironment('ABIBLIA_EMAIL');
  static const password = String.fromEnvironment('ABIBLIA_PASSWORD');

  static bool get hasCredentials => email.isNotEmpty && password.isNotEmpty;
}
