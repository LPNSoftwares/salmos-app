import '../domain/psalm.dart';

class FallbackPsalms {
  static List<Psalm> all(String version) {
    final now = DateTime.now();
    return [
      Psalm(
        id: 'local_sl_23_1',
        bookName: 'Salmos',
        bookAbbrev: 'sl',
        version: version,
        chapter: 23,
        number: 1,
        text: 'O Senhor é o meu pastor; nada me faltará.',
        receivedAt: now,
      ),
      Psalm(
        id: 'local_sl_46_1',
        bookName: 'Salmos',
        bookAbbrev: 'sl',
        version: version,
        chapter: 46,
        number: 1,
        text:
            'Deus é o nosso refúgio e fortaleza, socorro bem presente na angústia.',
        receivedAt: now,
      ),
      Psalm(
        id: 'local_sl_91_2',
        bookName: 'Salmos',
        bookAbbrev: 'sl',
        version: version,
        chapter: 91,
        number: 2,
        text:
            'Direi do Senhor: Ele é o meu Deus, o meu refúgio e a minha fortaleza.',
        receivedAt: now,
      ),
      Psalm(
        id: 'local_sl_121_2',
        bookName: 'Salmos',
        bookAbbrev: 'sl',
        version: version,
        chapter: 121,
        number: 2,
        text: 'O meu socorro vem do Senhor, que fez o céu e a terra.',
        receivedAt: now,
      ),
    ];
  }
}
