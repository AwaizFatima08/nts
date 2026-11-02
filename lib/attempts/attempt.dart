import 'package:nts_prep/content/models.dart';

/// One sitting of a paper. Immutable; every change goes through
/// the repository as a new value.
class Attempt {
  const Attempt({
    required this.id,
    required this.paperId,
    required this.useEthics,
    required this.startedAt,
    required this.remainingSeconds,
    this.answers = const {},
    this.flagged = const {},
    this.currentIndex = 0,
    this.finishedAt,
    this.correct,
    this.total,
  });

  factory Attempt.fromJson(Json json) => Attempt(
    id: json['id']! as String,
    paperId: json['paperId']! as String,
    useEthics: json['useEthics']! as bool,
    startedAt: DateTime.parse(json['startedAt']! as String),
    remainingSeconds: json['remaining']! as int,
    answers: (json['answers']! as Json).cast<String, int>(),
    flagged: (json['flagged']! as List<Object?>).cast<String>().toSet(),
    currentIndex: json['index']! as int,
    finishedAt: switch (json['finishedAt']) {
      final String value => DateTime.parse(value),
      _ => null,
    },
    correct: json['correct'] as int?,
    total: json['total'] as int?,
  );

  final String id;
  final String paperId;
  final bool useEthics;
  final DateTime startedAt;
  final int remainingSeconds;

  /// Question id to chosen option.
  final Map<String, int> answers;
  final Set<String> flagged;
  final int currentIndex;
  final DateTime? finishedAt;
  final int? correct;
  final int? total;

  bool get isFinished => finishedAt != null;

  int get percent => (total ?? 0) == 0 ? 0 : ((correct ?? 0) * 100 / total!).round();

  Attempt copyWith({
    int? remainingSeconds,
    Map<String, int>? answers,
    Set<String>? flagged,
    int? currentIndex,
    DateTime? finishedAt,
    int? correct,
    int? total,
  }) => Attempt(
    id: id,
    paperId: paperId,
    useEthics: useEthics,
    startedAt: startedAt,
    remainingSeconds: remainingSeconds ?? this.remainingSeconds,
    answers: answers ?? this.answers,
    flagged: flagged ?? this.flagged,
    currentIndex: currentIndex ?? this.currentIndex,
    finishedAt: finishedAt ?? this.finishedAt,
    correct: correct ?? this.correct,
    total: total ?? this.total,
  );

  Json toJson() => {
    'id': id,
    'paperId': paperId,
    'useEthics': useEthics,
    'startedAt': startedAt.toIso8601String(),
    'remaining': remainingSeconds,
    'answers': answers,
    'flagged': flagged.toList(),
    'index': currentIndex,
    if (finishedAt case final finished?) 'finishedAt': finished.toIso8601String(),
    'correct': ?correct,
    'total': ?total,
  };
}
