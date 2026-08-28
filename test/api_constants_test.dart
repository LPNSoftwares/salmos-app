import 'package:flutter_test/flutter_test.dart';
import 'package:salmododia_app/core/constants/api_constants.dart';

void main() {
  group('ApiConstants.normalizeVersion', () {
    test('migra a versão legada AA para ARA', () {
      expect(ApiConstants.normalizeVersion('AA'), 'ara');
    });

    test('usa NVI para uma versão não suportada', () {
      expect(ApiConstants.normalizeVersion('inexistente'), 'nvi');
    });
  });
}
