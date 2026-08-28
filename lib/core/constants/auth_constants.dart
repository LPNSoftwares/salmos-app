class AuthConstants {
  static const apiKey = String.fromEnvironment('BIBLIA_API_KEY');

  static bool get hasApiKey => apiKey.isNotEmpty;
}
