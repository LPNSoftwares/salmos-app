import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../../shared/services/api_auth_service.dart';
import '../../../shared/services/local_storage_service.dart';
import '../../../shared/services/request_limiter.dart';
import '../domain/psalm.dart';

final psalmRepositoryProvider = Provider<PsalmRepository>((ref) {
  return PsalmRepository(
    ref.watch(dioProvider),
    RequestLimiter(ref.watch(localStorageProvider)),
    ref.watch(apiAuthServiceProvider),
  );
});

class PsalmRepository {
  PsalmRepository(this._dio, this._limiter, this._authService);

  final Dio _dio;
  final RequestLimiter _limiter;
  final ApiAuthService _authService;

  Future<Psalm> fetchRandomPsalm(String version) async {
    if (!_authService.isConfigured && !await _limiter.canRequest()) {
      throw const AppException('Limite seguro de requisições atingido.');
    }

    try {
      await _authService.ensureAuthenticated();
      if (!_authService.isConfigured) {
        await _limiter.registerRequest();
      }
      final response = await _dio.get<Map<String, dynamic>>(
        '/verses/${version.toLowerCase()}/${ApiConstants.psalmsAbbrev}/random',
      );
      final data = response.data;
      if (data == null) {
        throw const AppException('Resposta vazia da API.');
      }
      return Psalm.fromApi(data);
    } on DioException catch (error) {
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        throw const AppException('Não foi possível conectar à API.');
      }
      final status = error.response?.statusCode;
      if (status != null && status >= 500) {
        throw const AppException(
          'A API pública está indisponível agora. Tente novamente em instantes.',
        );
      }
      throw AppException(
        'Falha ao buscar Salmo. Verifique sua conexão e tente novamente.',
      );
    }
  }

  Future<Psalm> fetchPsalmChapter({
    required String version,
    required int chapter,
  }) async {
    if (chapter < 1 || chapter > 150) {
      throw const AppException('Informe um Salmo entre 1 e 150.');
    }
    if (!_authService.isConfigured && !await _limiter.canRequest()) {
      throw const AppException('Limite seguro de requisições atingido.');
    }

    try {
      await _authService.ensureAuthenticated();
      if (!_authService.isConfigured) {
        await _limiter.registerRequest();
      }
      final response = await _dio.get<dynamic>(
        '/verses/${version.toLowerCase()}/${ApiConstants.psalmsAbbrev}/$chapter',
      );
      return _chapterFromApi(response.data, version, chapter);
    } on DioException catch (error) {
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        throw const AppException('Não foi possível conectar à API.');
      }
      final status = error.response?.statusCode;
      if (status != null && status >= 500) {
        throw const AppException(
          'A API pública está indisponível agora. Tente novamente em instantes.',
        );
      }
      throw const AppException(
        'Não foi possível buscar este Salmo. Verifique o número e tente novamente.',
      );
    }
  }

  Psalm _chapterFromApi(dynamic data, String version, int chapter) {
    if (data is List<dynamic>) {
      final verses = data.whereType<Map<String, dynamic>>().toList();
      return _chapterFromVerses(verses, version, chapter);
    }
    if (data is Map<String, dynamic>) {
      final rawVerses = data['verses'];
      if (rawVerses is List<dynamic>) {
        return _chapterFromVerses(
          rawVerses.whereType<Map<String, dynamic>>().toList(),
          version,
          chapter,
        );
      }
      final rawText = data['text'] as String?;
      if (rawText != null && rawText.trim().isNotEmpty) {
        return Psalm(
          id: '${version}_sl_${chapter}_full',
          bookName: 'Salmos',
          bookAbbrev: ApiConstants.psalmsAbbrev,
          version: version,
          chapter: chapter,
          number: 0,
          text: rawText.trim(),
          receivedAt: DateTime.now(),
        );
      }
    }
    throw const AppException('Resposta inesperada ao buscar o Salmo completo.');
  }

  Psalm _chapterFromVerses(
    List<Map<String, dynamic>> verses,
    String version,
    int chapter,
  ) {
    if (verses.isEmpty) {
      throw const AppException('A API retornou este Salmo sem versículos.');
    }
    final text = verses
        .map((verse) {
          final number = verse['number'] ?? verse['verse'] ?? '';
          final verseText = (verse['text'] as String? ?? '').trim();
          return number.toString().isEmpty ? verseText : '$number. $verseText';
        })
        .join('\n\n');

    return Psalm(
      id: '${version}_sl_${chapter}_full',
      bookName: 'Salmos',
      bookAbbrev: ApiConstants.psalmsAbbrev,
      version: version,
      chapter: chapter,
      number: 0,
      text: text,
      receivedAt: DateTime.now(),
    );
  }
}
