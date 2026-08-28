class ApiConstants {
  static const baseUrl = 'https://bibliaapi.com.br/api/v2';
  static const defaultVersion = 'nvi';
  static const psalmsAbbrev = 'sl';
  static const supportedVersions = ['nvi', 'acf', 'ara'];
  static const hourlyPublicLimit = 20;
  static const safeHourlyLimit = 16;

  static String normalizeVersion(String? version) {
    final normalized = (version ?? defaultVersion).trim().toLowerCase();
    final migrated = normalized == 'aa' ? 'ara' : normalized;
    return supportedVersions.contains(migrated) ? migrated : defaultVersion;
  }
}
