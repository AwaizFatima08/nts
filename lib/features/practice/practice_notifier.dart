import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nts_prep/content/content_repository.dart';
import 'package:nts_prep/content/models.dart';
import 'package:nts_prep/core/clock.dart';
import 'package:nts_prep/settings/settings_repository.dart';

@immutable
class PracticeKey {
  const PracticeKey(this.section, this.topic);

  final String section;
  final String topic;

  @override
  bool operator ==(Object other) =>
      other is PracticeKey && other.section == section && other.topic == topic;

  @override
  int get hashCode => Object.hash(section, topic);
}

class PracticeState {
  const PracticeState({
    required this.questions,
    required this.sets,
    this.index = 0,
    this.chosen,
    this.correct = 0,
    this.finished = false,
  });

  final List<Question> questions;
  final Map<String, QuestionSet> sets;
  final int index;

  /// The option picked for the current question; null until answered.
  final int? chosen;
  final int correct;
  final bool finished;

  Question get question => questions[index];
}

/// Pure pick of a practice session: whole sets stay together and in order.
List<Question> pickPractice(List<Question> pool, int seed, {int size = 10}) {
  final groups = <String, List<Question>>{};
  for (final question in pool) {
    (groups[question.setId ?? question.id] ??= []).add(question);
  }
  final shuffled = groups.values.toList()..shuffle(Random(seed));
  final picked = <Question>[];
  for (final group in shuffled) {
    if (picked.length >= size) break;
    picked.addAll(group);
  }
  return picked;
}

class PracticeNotifier extends AsyncNotifier<PracticeState> {
  PracticeNotifier(this.key);

  final PracticeKey key;

  @override
  Future<PracticeState> build() async {
    final bank = await ref.watch(contentRepositoryProvider).bank(key.section);
    final pool = [
      for (final question in bank.questions)
        if (question.isPractice && question.topic == key.topic) question,
    ];
    final seed = ref.read(clockProvider).now().millisecondsSinceEpoch;
    return PracticeState(questions: pickPractice(pool, seed), sets: bank.sets);
  }

  void choose(int option) {
    final current = state.value;
    if (current == null || current.chosen != null) return;
    state = AsyncData(
      PracticeState(
        questions: current.questions,
        sets: current.sets,
        index: current.index,
        chosen: option,
        correct: current.correct + (option == current.question.answer ? 1 : 0),
      ),
    );
  }

  Future<void> next() async {
    final current = state.value;
    if (current == null) return;
    final finished = current.index + 1 >= current.questions.length;
    if (finished) {
      await ref
          .read(practiceTallyProvider.notifier)
          .record(
            key.section,
            key.topic,
            correct: current.correct,
            total: current.questions.length,
          );
    }
    state = AsyncData(
      PracticeState(
        questions: current.questions,
        sets: current.sets,
        index: finished ? current.index : current.index + 1,
        correct: current.correct,
        finished: finished,
      ),
    );
  }
}

final practiceProvider = AsyncNotifierProvider.autoDispose
    .family<PracticeNotifier, PracticeState, PracticeKey>(
      PracticeNotifier.new,
    );
