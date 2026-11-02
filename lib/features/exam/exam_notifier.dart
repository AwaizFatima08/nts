import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nts_prep/attempts/attempt.dart';
import 'package:nts_prep/attempts/attempt_repository.dart';
import 'package:nts_prep/content/content_repository.dart';
import 'package:nts_prep/content/models.dart';
import 'package:nts_prep/core/clock.dart';
import 'package:nts_prep/core/result.dart';
import 'package:nts_prep/core/scoring.dart';
import 'package:nts_prep/settings/settings_repository.dart';

class ExamState {
  const ExamState({required this.sitting, required this.attempt});

  final Sitting sitting;
  final Attempt attempt;

  Question get question => sitting.questions[attempt.currentIndex];

  ExamState withAttempt(Attempt attempt) => ExamState(sitting: sitting, attempt: attempt);
}

/// Loads an attempt with its paper; used by the exam, results and review screens.
Future<ExamState> loadExamState(Ref ref, String attemptId) async {
  final attempt = await ref.read(attemptRepositoryProvider).byId(attemptId);
  if (attempt == null) throw StorageFailure('not-found:$attemptId');
  final papers = await ref.read(contentRepositoryProvider).papers();
  final paper = papers.where((p) => p.id == attempt.paperId).firstOrNull;
  if (paper == null) throw ContentFailure('missing-paper:${attempt.paperId}');
  final loaded = await ref
      .read(contentRepositoryProvider)
      .sitting(paper, useEthics: attempt.useEthics);
  return switch (loaded) {
    Ok(:final value) => ExamState(sitting: value, attempt: attempt),
    Err(:final failure) => throw failure,
  };
}

final reviewProvider = FutureProvider.autoDispose.family<ExamState, String>(loadExamState);

/// Runs one sitting: the countdown, answers, flags and submission.
class ExamNotifier extends AsyncNotifier<ExamState> {
  ExamNotifier(this.attemptId);

  final String attemptId;

  static const _saveEverySeconds = 15;
  Timer? _timer;

  AttemptRepository get _repository => ref.read(attemptRepositoryProvider);

  @override
  Future<ExamState> build() async {
    ref.onDispose(() => _timer?.cancel());
    final loaded = await loadExamState(ref, attemptId);
    if (!loaded.attempt.isFinished) resumeTimer();
    return loaded;
  }

  void resumeTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => unawaited(_tick()));
  }

  /// Stops the clock and saves the time left, when the candidate leaves the test.
  Future<void> pauseTimer() async {
    _timer?.cancel();
    final current = state.value;
    if (current == null || current.attempt.isFinished) return;
    await _persist(current.attempt);
  }

  Future<void> _tick() async {
    final current = state.value;
    if (current == null) return;
    final remaining = current.attempt.remainingSeconds - 1;
    if (remaining <= 0) {
      await submit();
      return;
    }
    final next = current.attempt.copyWith(remainingSeconds: remaining);
    state = AsyncData(current.withAttempt(next));
    if (remaining % _saveEverySeconds == 0) await _persist(next);
  }

  Future<void> _persist(Attempt attempt) async {
    await _repository.update(attemptId, (_) => attempt);
  }

  Future<void> _apply(Attempt Function(Attempt) change) async {
    final current = state.value;
    if (current == null || current.attempt.isFinished) return;
    final next = change(current.attempt);
    await _persist(next);
    state = AsyncData(current.withAttempt(next));
  }

  Future<void> choose(int option) => _apply((attempt) {
    final id = state.value!.question.id;
    return attempt.copyWith(answers: {...attempt.answers, id: option});
  });

  Future<void> clearAnswer() => _apply((attempt) {
    final id = state.value!.question.id;
    return attempt.copyWith(answers: {...attempt.answers}..remove(id));
  });

  Future<void> toggleFlag() => _apply((attempt) {
    final id = state.value!.question.id;
    final flagged = {...attempt.flagged};
    if (!flagged.remove(id)) flagged.add(id);
    return attempt.copyWith(flagged: flagged);
  });

  Future<void> goTo(int index) => _apply((attempt) => attempt.copyWith(currentIndex: index));

  /// Marks the paper, saves the result and feeds the topic tallies.
  Future<void> submit() async {
    _timer?.cancel();
    final current = state.value;
    if (current == null || current.attempt.isFinished) return;
    final score = scoreSitting(current.sitting, current.attempt.answers);
    final next = current.attempt.copyWith(
      finishedAt: ref.read(clockProvider).now(),
      correct: score.overall.correct,
      total: score.overall.total,
    );
    await _persist(next);
    await ref.read(practiceTallyProvider.notifier).recordAll(score.topics);
    state = AsyncData(current.withAttempt(next));
  }
}

final examProvider = AsyncNotifierProvider.autoDispose.family<ExamNotifier, ExamState, String>(
  ExamNotifier.new,
);
