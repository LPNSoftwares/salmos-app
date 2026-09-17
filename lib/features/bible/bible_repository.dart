import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/app_exception.dart';
import '../psalm/domain/psalm.dart';

final psalmRepositoryProvider = Provider<PsalmRepository>(
  (ref) => PsalmRepository(),
);

class BibleBook {
  const BibleBook(this.name, this.abbrev, this.chapters);
  final String name;
  final String abbrev;
  final List<List<String>> chapters;
}

class PsalmRepository {
  PsalmRepository({AssetBundle? bundle, Random? random})
    : _bundle = bundle ?? rootBundle,
      _random = random ?? Random();
  final AssetBundle _bundle;
  final Random _random;
  Future<void>? _loading;
  List<BibleBook> books = const [];
  final List<Psalm> _verses = [];
  final Map<String, List<int>> _bags = {};
  final Map<String, String> _last = {};
  int get verseCount => _verses.length;
  int get chapterCount =>
      books.fold(0, (sum, book) => sum + book.chapters.length);

  Future<void> initialize() => _loading ??= _load().catchError((Object error) {
    _loading = null;
    throw const AppException(
      'Não foi possível abrir a Bíblia salva no aplicativo. Tente novamente.',
    );
  });

  Future<void> _load() async {
    final source = await _bundle.loadString('resources/VFL.json');
    final raw = jsonDecode(source.replaceFirst('\uFEFF', '')) as List<dynamic>;
    final parsed = <BibleBook>[];
    for (final item in raw) {
      final map = item as Map<String, dynamic>;
      final chapters = (map['chapters'] as List)
          .map(
            (chapter) =>
                List<String>.unmodifiable((chapter as List).cast<String>()),
          )
          .toList();
      if (chapters.isEmpty || chapters.any((c) => c.isEmpty)) {
        throw const FormatException('Livro sem capítulos ou versículos');
      }
      parsed.add(
        BibleBook(
          map['name'] as String,
          (map['abbrev'] as String).toLowerCase(),
          List.unmodifiable(chapters),
        ),
      );
    }
    books = List.unmodifiable(parsed);
    _verses.clear();
    for (final book in books) {
      for (var c = 0; c < book.chapters.length; c++) {
        for (var v = 0; v < book.chapters[c].length; v++) {
          if (book.chapters[c][v].trim().isNotEmpty) {
            _verses.add(_passage(book, c + 1, v + 1, book.chapters[c][v]));
          }
        }
      }
    }
    if (_verses.isEmpty) throw const FormatException('Bíblia vazia');
  }

  Psalm _passage(BibleBook book, int chapter, int verse, String text) => Psalm(
    id: 'vfl_${book.abbrev}_${chapter}_${verse == 0 ? 'full' : verse}',
    bookName: book.name,
    bookAbbrev: book.abbrev,
    version: 'vfl',
    chapter: chapter,
    number: verse,
    text: text,
    receivedAt: DateTime.now(),
  );

  Future<Psalm> fetchRandomPsalm(String version) =>
      randomVerse(psalmsOnly: true);

  Future<Psalm> randomVerse({bool psalmsOnly = false}) async {
    await initialize();
    final key = psalmsOnly ? 'sl' : 'all';
    final bag = _bags.putIfAbsent(key, () => []);
    if (bag.isEmpty) {
      bag.addAll(
        Iterable<int>.generate(
          _verses.length,
        ).where((i) => !psalmsOnly || _verses[i].bookAbbrev == 'sl'),
      );
      bag.shuffle(_random);
      if (bag.length > 1 && _verses[bag.last].id == _last[key]) {
        final first = bag.first;
        bag[0] = bag.last;
        bag[bag.length - 1] = first;
      }
    }
    final result = _verses[bag.removeLast()];
    _last[key] = result.id;
    return result.copyWith(receivedAt: DateTime.now());
  }

  Future<Psalm> dailyVerse([DateTime? date]) async {
    await initialize();
    final day = date ?? DateTime.now();
    final seed = day.year * 10000 + day.month * 100 + day.day;
    return _verses[Random(seed).nextInt(_verses.length)];
  }

  Future<Psalm> fetchPsalmChapter({
    required String version,
    required int chapter,
  }) => readChapter('sl', chapter);

  Future<Psalm> readChapter(String abbrev, int number) async {
    await initialize();
    final matches = books.where((b) => b.abbrev == abbrev.toLowerCase());
    if (matches.isEmpty) {
      throw const AppException('Livro não encontrado na edição VFL.');
    }
    final book = matches.first;
    if (number < 1 || number > book.chapters.length) {
      throw AppException(
        'Escolha um capítulo entre 1 e ${book.chapters.length}.',
      );
    }
    final verses = book.chapters[number - 1];
    return _passage(
      book,
      number,
      0,
      List.generate(
        verses.length,
        (i) => '${i + 1}. ${verses[i]}',
      ).join('\n\n'),
    );
  }

  List<Psalm> search(String query, {int limit = 100}) {
    final words = normalize(
      query,
    ).split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return [];
    return _verses
        .where((verse) {
          final text = normalize('${verse.reference} ${verse.text}');
          return words.every(text.contains);
        })
        .take(limit)
        .toList();
  }

  static String normalize(String text) {
    var result = text.toLowerCase();
    const groups = {
      'a': 'áàãâä',
      'e': 'éèêë',
      'i': 'íìîï',
      'o': 'óòõôö',
      'u': 'úùûü',
      'c': 'ç',
    };
    groups.forEach((letter, accents) {
      for (final accent in accents.split('')) {
        result = result.replaceAll(accent, letter);
      }
    });
    return result;
  }
}
