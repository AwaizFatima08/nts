import 'package:flutter_test/flutter_test.dart';
import 'package:nts_prep/core/scoring.dart';

import '../support.dart';

void main() {
  final sitting = sittingOf([
    (
      'verbal',
      [
        question('v1', section: 'verbal', topic: 'analogy', answer: 1),
        question('v2', section: 'verbal', topic: 'analogy', answer: 2),
      ],
    ),
    ('quant', [question('q1', answer: 3), question('q2', topic: 'algebra')]),
  ]);

  test('counts right, wrong and skipped with no negative marking', () {
    final score = scoreSitting(sitting, {'v1': 1, 'v2': 0, 'q1': 3});
    expect(score.overall.correct, 2);
    expect(score.overall.total, 4);
    expect(score.overall.percent, 50);
    expect(score.skipped, 1);
  });

  test('scores each section separately', () {
    final score = scoreSitting(sitting, {'v1': 1, 'q2': 0});
    expect(score.sections[0].tally.correct, 1);
    expect(score.sections[0].skipped, 1);
    expect(score.sections[1].tally.correct, 1);
  });

  test('lists the weakest topic first', () {
    final score = scoreSitting(sitting, {'q1': 3, 'q2': 0});
    expect(score.topics.first.topic, 'analogy');
    expect(score.topics.first.tally.percent, 0);
  });

  test('an empty tally is zero percent', () {
    expect(const Tally(0, 0).percent, 0);
  });
}
