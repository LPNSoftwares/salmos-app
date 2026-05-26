import 'dart:convert';

class Psalm {
  const Psalm({
    required this.id,
    required this.bookName,
    required this.bookAbbrev,
    required this.version,
    required this.chapter,
    required this.number,
    required this.text,
    required this.receivedAt,
  });

  factory Psalm.fromApi(Map<String, dynamic> json) {
    final book = json['book'] as Map<String, dynamic>? ?? {};
    final abbrev = book['abbrev'] as Map<String, dynamic>? ?? {};
    final chapter = json['chapter'] as int? ?? 0;
    final number = json['number'] as int? ?? 0;
    final version = (book['version'] as String? ?? '').toLowerCase();
    final text = json['text'] as String? ?? '';

    return Psalm(
      id: '${version}_${abbrev['pt'] ?? 'sl'}_${chapter}_$number',
      bookName: book['name'] as String? ?? 'Salmos',
      bookAbbrev: abbrev['pt'] as String? ?? 'sl',
      version: version.isEmpty ? 'nvi' : version,
      chapter: chapter,
      number: number,
      text: text,
      receivedAt: DateTime.now(),
    );
  }

  factory Psalm.fromJson(Map<String, dynamic> json) {
    return Psalm(
      id: json['id'] as String,
      bookName: json['bookName'] as String,
      bookAbbrev: json['bookAbbrev'] as String,
      version: json['version'] as String,
      chapter: json['chapter'] as int,
      number: json['number'] as int,
      text: json['text'] as String,
      receivedAt: DateTime.parse(json['receivedAt'] as String),
    );
  }

  final String id;
  final String bookName;
  final String bookAbbrev;
  final String version;
  final int chapter;
  final int number;
  final String text;
  final DateTime receivedAt;

  bool get isFullChapter => number <= 0;

  String get reference =>
      isFullChapter ? '$bookName $chapter' : '$bookName $chapter:$number';

  String get shareText => '"$text"\n\n$reference (${version.toUpperCase()})';

  Psalm copyWith({DateTime? receivedAt}) {
    return Psalm(
      id: id,
      bookName: bookName,
      bookAbbrev: bookAbbrev,
      version: version,
      chapter: chapter,
      number: number,
      text: text,
      receivedAt: receivedAt ?? this.receivedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookName': bookName,
      'bookAbbrev': bookAbbrev,
      'version': version,
      'chapter': chapter,
      'number': number,
      'text': text,
      'receivedAt': receivedAt.toIso8601String(),
    };
  }

  String encode() => jsonEncode(toJson());
}
