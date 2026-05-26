import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/auth_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/network/dio_client.dart';

final apiAuthServiceProvider = Provider<ApiAuthService>((ref) {
  return ApiAuthService(ref.watch(dioProvider));
});

class ApiAuthService {
  ApiAuthService(this._dio);

  final Dio _dio;
  String? _token;

  bool get isConfigured => AuthConstants.hasCredentials;

  Future<void> ensureAuthenticated() async {
    if (!isConfigured || _token != null) {
      return;
    }

    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/users/token',
        data: {
          'email': AuthConstants.email,
          'password': AuthConstants.password,
        },
        options: Options(
          headers: const {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );
      final token = response.data?['token'] as String?;
      if (token == null || token.isEmpty) {
        throw const AppException('Login na API não retornou token.');
      }
      _token = token;
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      if (status == 401 || status == 403) {
        throw const AppException('Credenciais da API recusadas.');
      }
      throw const AppException(
        'Não foi possível autenticar na API A Bíblia Digital.',
      );
    }
  }
}
