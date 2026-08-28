import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salmododia_app/core/constants/api_constants.dart';
import 'package:salmododia_app/features/psalm/data/psalm_repository.dart';
import 'package:salmododia_app/shared/services/api_auth_service.dart';

void main() {
  group('PsalmRepository com Bíblia API v2', () {
    test('busca e converte um Salmo aleatório', () async {
      late RequestOptions capturedRequest;
      final dio = _dioRespondingWith((request) {
        capturedRequest = request;
        return {
          'data': {
            'version': 'NVI',
            'book': {
              'id': 19,
              'name': 'Salmos',
              'abbrev': 'sl',
              'testament': 'VT',
            },
            'reference': 'Salmos 23:1',
            'chapter': 23,
            'verse': 1,
            'text': 'O Senhor é o meu pastor.',
          },
        };
      });
      final repository = PsalmRepository(
        dio,
        ApiAuthService(dio, apiKey: 'bapi_test'),
      );

      final psalm = await repository.fetchRandomPsalm('nvi');

      expect(capturedRequest.path, '/versions/NVI/books/sl/random');
      expect(capturedRequest.headers['X-API-Key'], 'bapi_test');
      expect(psalm.reference, 'Salmos 23:1');
      expect(psalm.version, 'nvi');
      expect(psalm.text, 'O Senhor é o meu pastor.');
    });

    test('busca e combina os versículos de um capítulo', () async {
      late RequestOptions capturedRequest;
      final dio = _dioRespondingWith((request) {
        capturedRequest = request;
        return {
          'data': {
            'version': 'ARA',
            'book': {'id': 19, 'name': 'Salmos', 'abbrev': 'sl'},
            'reference': 'Salmos 23',
            'chapter': {'number': 23, 'verses': 2},
            'verses': [
              {'verse': 1, 'text': 'Primeiro versículo.'},
              {'verse': 2, 'text': 'Segundo versículo.'},
            ],
          },
        };
      });
      final repository = PsalmRepository(
        dio,
        ApiAuthService(dio, apiKey: 'bapi_test'),
      );

      final psalm = await repository.fetchPsalmChapter(
        version: 'aa',
        chapter: 23,
      );

      expect(capturedRequest.path, '/versions/ARA/books/sl/chapters/23');
      expect(psalm.reference, 'Salmos 23');
      expect(psalm.version, 'ara');
      expect(psalm.text, '1. Primeiro versículo.\n\n2. Segundo versículo.');
    });
  });
}

Dio _dioRespondingWith(
  Map<String, dynamic> Function(RequestOptions request) response,
) {
  final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (request, handler) {
        handler.resolve(
          Response<Map<String, dynamic>>(
            requestOptions: request,
            statusCode: 200,
            data: response(request),
          ),
        );
      },
    ),
  );
  return dio;
}
