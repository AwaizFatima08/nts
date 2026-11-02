import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nts_prep/content/models.dart';
import 'package:nts_prep/core/result.dart';

/// Reads a bundled text asset. Swapped in tests.
typedef AssetReader = Future<String> Function(String path);

class SectionBank {
  const SectionBank({required this.questions, required this.sets});

  final List<Question> questions;
  final Map<String, QuestionSet> sets;
}

SectionBank _parseBank((String, String) input) {
  final (raw, section) = input;
  final json = jsonDecode(raw) as Json;
  return SectionBank(
    questions: [
      for (final item in json['questions']! as List<Object?>)
        Question.fromJson(item! as Json, section),
    ],
    sets: {
      for (final entry in (json['sets']! as Json).entries)
        entry.key: QuestionSet.fromJson(entry.value! as Json),
    },
  );
}

/// Bundled content. Banks load on demand and stay cached for the session.
class ContentRepository {
  ContentRepository(this._read);

  final AssetReader _read;
  final _banks = <String, Future<SectionBank>>{};

  Future<Json> _json(String name) async => jsonDecode(await _read('assets/data/$name')) as Json;

  Future<Catalog> catalog() async => Catalog.fromJson(await _json('catalog.json'));

  Future<List<Paper>> papers() async {
    final raw = jsonDecode(await _read('assets/data/forms.json')) as List<Object?>;
    return [for (final item in raw) Paper.fromJson(item! as Json)];
  }

  Future<List<GuideArticle>> guide() async {
    final raw = await _json('guide.json');
    return [
      for (final item in raw['articles']! as List<Object?>) GuideArticle.fromJson(item! as Json),
    ];
  }

  Future<SectionBank> bank(String section) => _banks[section] ??= () async {
    final raw = await _read('assets/data/bank_$section.json');
    return compute(_parseBank, (raw, section));
  }();

  /// Questions of a sitting in paper order, with the sets they use.
  Future<Result<Sitting, ContentFailure>> sitting(Paper paper, {required bool useEthics}) async {
    try {
      final sections = paper.sectionsFor(useEthics: useEthics);
      final questions = <Question>[];
      final sets = <String, QuestionSet>{};
      for (final section in sections) {
        final bank = await this.bank(section.key);
        final byId = {for (final question in bank.questions) question.id: question};
        for (final id in section.itemIds) {
          final question = byId[id];
          if (question == null) return Err(ContentFailure('missing-question:$id'));
          questions.add(question);
        }
        sets.addAll(bank.sets);
      }
      return Ok(Sitting(paper: paper, sections: sections, questions: questions, sets: sets));
    } on FormatException catch (error) {
      return Err(ContentFailure('bad-bank', cause: error));
    } on Exception catch (error) {
      return Err(ContentFailure('missing-bank', cause: error));
    }
  }
}

/// Everything needed to run or review one paper.
class Sitting {
  const Sitting({
    required this.paper,
    required this.sections,
    required this.questions,
    required this.sets,
  });

  final Paper paper;
  final List<PaperSection> sections;
  final List<Question> questions;
  final Map<String, QuestionSet> sets;

  /// Index of the first question of each section.
  List<int> get sectionStarts {
    final starts = <int>[];
    var next = 0;
    for (final section in sections) {
      starts.add(next);
      next += section.itemIds.length;
    }
    return starts;
  }

  /// Index in [sections] of the section holding question [index].
  int sectionOf(int index) {
    final starts = sectionStarts;
    for (var i = starts.length - 1; i >= 0; i--) {
      if (index >= starts[i]) return i;
    }
    return 0;
  }
}

final assetReaderProvider = Provider<AssetReader>((ref) => rootBundle.loadString);

final contentRepositoryProvider = Provider<ContentRepository>(
  (ref) => ContentRepository(ref.watch(assetReaderProvider)),
);

final catalogProvider = FutureProvider<Catalog>(
  (ref) => ref.watch(contentRepositoryProvider).catalog(),
);

final papersProvider = FutureProvider<List<Paper>>(
  (ref) => ref.watch(contentRepositoryProvider).papers(),
);

final guideProvider = FutureProvider<List<GuideArticle>>(
  (ref) => ref.watch(contentRepositoryProvider).guide(),
);
