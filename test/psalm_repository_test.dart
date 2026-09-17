import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salmododia_app/features/bible/bible_repository.dart';

class FileBibleBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final bytes = await File(key).readAsBytes();
    return ByteData.sublistView(bytes);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late PsalmRepository repository;
  setUp(() {
    repository = PsalmRepository(bundle: FileBibleBundle(), random: Random(42));
  });

  test(
    'carrega integralmente os 66 livros e 1189 capítulos do JSON local',
    () async {
      await repository.initialize();
      expect(repository.books.length, 66);
      expect(repository.chapterCount, 1189);
      expect(repository.verseCount, greaterThan(30000));
      expect(repository.books.first.name, 'Gênesis');
      expect(repository.books.last.name, 'Apocalipse');
      final psalms = repository.books.firstWhere((b) => b.abbrev == 'sl');
      expect(psalms.chapters.length, 150);
      for (final book in repository.books) {
        for (var chapter = 1; chapter <= book.chapters.length; chapter++) {
          final passage = await repository.readChapter(book.abbrev, chapter);
          expect(passage.version, 'vfl');
          expect(
            passage.text,
            List.generate(
              book.chapters[chapter - 1].length,
              (v) => '${v + 1}. ${book.chapters[chapter - 1][v]}',
            ).join('\n\n'),
          );
        }
      }
    },
  );

  test(
    'sorteio de Salmos não repete versos no ciclo e respeita o livro',
    () async {
      final ids = <String>{};
      for (var i = 0; i < 300; i++) {
        final passage = await repository.randomVerse(psalmsOnly: true);
        expect(passage.bookAbbrev, 'sl');
        expect(ids.add(passage.id), isTrue);
      }
    },
  );

  test(
    'sorteio geral inclui vários livros e a palavra do dia é estável',
    () async {
      final books = <String>{};
      for (var i = 0; i < 100; i++) {
        books.add((await repository.randomVerse()).bookAbbrev);
      }
      expect(books.length, greaterThan(15));
      final date = DateTime(2026, 9, 17);
      final first = await repository.dailyVerse(date);
      final second = await repository.dailyVerse(date);
      expect(first.id, second.id);
    },
  );

  test('busca ignora acentos e capítulos inválidos são rejeitados', () async {
    await repository.initialize();
    expect(
      repository.search('principio').any((p) => p.reference == 'Gênesis 1:1'),
      isTrue,
    );
    expect(repository.search('zzzzsemresultado'), isEmpty);
    expect(repository.readChapter('sl', 151), throwsException);
    expect(repository.readChapter('gn', 0), throwsException);
    expect(repository.readChapter('inexistente', 1), throwsException);
  });
}
