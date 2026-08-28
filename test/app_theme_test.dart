import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salmododia_app/core/theme/app_theme.dart';

void main() {
  test('edge-to-edge não define cores descontinuadas das barras', () {
    final style = AppTheme.systemOverlayStyle(Brightness.light);

    expect(style.statusBarColor, isNull);
    expect(style.systemNavigationBarColor, isNull);
    expect(style.systemNavigationBarDividerColor, isNull);
    expect(style.statusBarIconBrightness, Brightness.dark);
    expect(style.systemNavigationBarIconBrightness, Brightness.dark);
  });
}
