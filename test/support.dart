import 'package:nts_prep/content/content_repository.dart';
import 'package:nts_prep/content/models.dart';

Question question(
  String id, {
  String section = 'quant',
  String topic = 'ratio',
  int answer = 0,
  String? setId,
}) => Question(
  id: id,
  section: section,
  topic: topic,
  isPractice: false,
  level: 1,
  stem: 'Stem $id',
  options: const ['a', 'b', 'c', 'd'],
  answer: answer,
  explanation: 'Because.',
  setId: setId,
);

Sitting sittingOf(List<(String, List<Question>)> sections) {
  final parts = [
    for (final (key, questions) in sections)
      PaperSection(key: key, title: key, itemIds: [for (final q in questions) q.id]),
  ];
  return Sitting(
    paper: Paper(
      id: 'nat-ie-01',
      mode: 'nat',
      stream: 'ie',
      number: 1,
      title: 'Test 1',
      minutes: 120,
      sections: parts,
    ),
    sections: parts,
    questions: [for (final (_, questions) in sections) ...questions],
    sets: const {},
  );
}
