import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../../shared/services/api_auth_service.dart';
import '../domain/psalm.dart';

final psalmRepositoryProvider = Provider<PsalmRepository>((ref) {
  return PsalmRepository(
    ref.watch(dioProvider),
    ref.watch(apiAuthServiceProvider),
  );
});

class PsalmRepository {
  PsalmRepository(this._dio, this._authService);

  final Dio _dio;
  final ApiAuthService _authService;

  Future<Psalm> fetchRandomPsalm(String version) async {
    try {
      await _authService.ensureAuthenticated();
      final normalizedVersion = ApiConstants.normalizeVersion(version);
      final response = await _dio.get<Map<String, dynamic>>(
        '/versions/${normalizedVersion.toUpperCase()}/books/'
        '${ApiConstants.psalmsAbbrev}/random',
      );
      final data = _unwrapData(response.data);
      if (data == null) {
        throw const AppException('Resposta vazia da API.');
      }
      return Psalm.fromApi(data, fallbackVersion: normalizedVersion);
    } on DioException catch (error) {
      throw _mapDioError(error, chapterRequest: false);
    }
  }

  Future<Psalm> fetchPsalmChapter({
    required String version,
    required int chapter,
  }) async {
    if (chapter < 1 || chapter > 150) {
      throw const AppException('Informe um Salmo entre 1 e 150.');
    }
    try {
      await _authService.ensureAuthenticated();
      final normalizedVersion = ApiConstants.normalizeVersion(version);
      final response = await _dio.get<dynamic>(
        '/versions/${normalizedVersion.toUpperCase()}/books/'
        '${ApiConstants.psalmsAbbrev}/chapters/$chapter',
      );
      return _chapterFromApi(response.data, normalizedVersion, chapter);
    } on DioException catch (error) {
      throw _mapDioError(error, chapterRequest: true);
    }
  }

  Psalm _chapterFromApi(dynamic data, String version, int chapter) {
    if (data is Map<String, dynamic> && data['data'] != null) {
      return _chapterFromApi(data['data'], version, chapter);
    }
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

  Map<String, dynamic>? _unwrapData(Map<String, dynamic>? response) {
    if (response == null) {
      return null;
    }
    final data = response['data'];
    return data is Map<String, dynamic> ? data : response;
  }

  AppException _mapDioError(
    DioException error, {
    required bool chapterRequest,
  }) {
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return const AppException('Não foi possível conectar à Bíblia API.');
    }

    return switch (error.response?.statusCode) {
      401 || 403 => const AppException(
        'A chave da Bíblia API está ausente, inválida ou revogada.',
      ),
      404 => const AppException(
        'Versão, livro ou Salmo não encontrado na Bíblia API.',
      ),
      429 => const AppException(
        'Limite mensal de requisições da Bíblia API atingido.',
      ),
      final status when status != null && status >= 500 => const AppException(
        'A Bíblia API está indisponível agora. Tente novamente em instantes.',
      ),
      _ => AppException(
        chapterRequest
            ? 'Não foi possível buscar este Salmo. Verifique o número e tente novamente.'
            : 'Falha ao buscar Salmo. Verifique sua conexão e tente novamente.',
      ),
    };
  }
}
