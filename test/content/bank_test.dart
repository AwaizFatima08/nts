import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nts_prep/content/models.dart';

/// Checks the built assets: every paper resolves to real questions in the right pool.
void main() {
  final forms = jsonDecode(File('assets/data/forms.json').readAsStringSync()) as List<Object?>;
  final papers = [for (final form in forms) Paper.fromJson(form! as Json)];
  final questions = <String, Question>{};
  for (final file in Directory('assets/data').listSync().whereType<File>()) {
    final name = file.uri.pathSegments.last;
    if (!name.startsWith('bank_')) continue;
    final section = name.substring(5, name.length - 5);
    final json = jsonDecode(file.readAsStringSync()) as Json;
    for (final raw in json['questions']! as List<Object?>) {
      final question = Question.fromJson(raw! as Json, section);
      questions[question.id] = question;
    }
  }

  test('every paper uses test-pool questions only, each once', () {
    for (final paper in papers) {
      for (final useEthics in [false, true]) {
        final ids = [
          for (final section in paper.sectionsFor(useEthics: useEthics)) ...section.itemIds,
        ];
        expect(ids.toSet(), hasLength(ids.length), reason: paper.id);
        for (final id in ids) {
          expect(questions[id]?.isPractice, isFalse, reason: '${paper.id} $id');
        }
      }
    }
  });

  test('every answer key points at an option', () {
    for (final question in questions.values) {
      expect(
        question.answer,
        inInclusiveRange(0, question.options.length - 1),
        reason: question.id,
      );
    }
  });
}
