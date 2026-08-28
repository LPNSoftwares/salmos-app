import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/auth_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/network/dio_client.dart';

final apiAuthServiceProvider = Provider<ApiAuthService>((ref) {
  return ApiAuthService(ref.watch(dioProvider));
});

class ApiAuthService {
  ApiAuthService(this._dio, {String? apiKey})
    : _apiKey = apiKey ?? AuthConstants.apiKey;

  final Dio _dio;
  final String _apiKey;
  bool _configured = false;

  bool get isConfigured => _apiKey.isNotEmpty;

  Future<void> ensureAuthenticated() async {
    if (_configured) {
      return;
    }
    if (!isConfigured) {
      throw const AppException(
        'Chave da Bíblia API não configurada. Informe BIBLIA_API_KEY no build.',
      );
    }

    _dio.options.headers['X-API-Key'] = _apiKey;
    _configured = true;
  }
}
