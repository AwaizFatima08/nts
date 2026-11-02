import 'package:nts_prep/content/content_repository.dart';

/// Correct answers out of a total.
class Tally {
  const Tally(this.correct, this.total);

  final int correct;
  final int total;

  /// Whole percent; 0 for an empty tally.
  int get percent => total == 0 ? 0 : (correct * 100 / total).round();
}

class TopicScore {
  const TopicScore({required this.section, required this.topic, required this.tally});

  final String section;
  final String topic;
  final Tally tally;
}

class SectionScore {
  const SectionScore({required this.title, required this.tally, required this.skipped});

  final String title;
  final Tally tally;
  final int skipped;
}

/// The outcome of a finished paper. NTS admission papers carry no negative
/// marking, so a skipped question simply earns nothing.
class TestScore {
  const TestScore({
    required this.overall,
    required this.skipped,
    required this.sections,
    required this.topics,
  });

  final Tally overall;
  final int skipped;
  final List<SectionScore> sections;

  /// Weakest first.
  final List<TopicScore> topics;
}

TestScore scoreSitting(Sitting sitting, Map<String, int> answers) {
  var correct = 0;
  var skipped = 0;
  final sections = <SectionScore>[];
  final topics = <(String, String), (int, int)>{};
  var index = 0;
  for (final section in sitting.sections) {
    var sectionCorrect = 0;
    var sectionSkipped = 0;
    for (var i = 0; i < section.itemIds.length; i++, index++) {
      final question = sitting.questions[index];
      final chosen = answers[question.id];
      final right = chosen == question.answer;
      if (chosen == null) sectionSkipped++;
      if (right) sectionCorrect++;
      final key = (question.section, question.topic);
      final (topicCorrect, topicTotal) = topics[key] ?? (0, 0);
      topics[key] = (topicCorrect + (right ? 1 : 0), topicTotal + 1);
    }
    correct += sectionCorrect;
    skipped += sectionSkipped;
    sections.add(
      SectionScore(
        title: section.title,
        tally: Tally(sectionCorrect, section.itemIds.length),
        skipped: sectionSkipped,
      ),
    );
  }
  final topicScores = [
    for (final MapEntry(:key, :value) in topics.entries)
      TopicScore(section: key.$1, topic: key.$2, tally: Tally(value.$1, value.$2)),
  ]..sort((a, b) => a.tally.percent.compareTo(b.tally.percent));
  return TestScore(
    overall: Tally(correct, sitting.questions.length),
    skipped: skipped,
    sections: sections,
    topics: topicScores,
  );
}
