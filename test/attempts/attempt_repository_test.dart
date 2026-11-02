import 'package:flutter_test/flutter_test.dart';
import 'package:nts_prep/attempts/attempt.dart';
import 'package:nts_prep/attempts/attempt_repository.dart';
import 'package:nts_prep/core/clock.dart';
import 'package:nts_prep/core/result.dart';

class MemoryStore implements DocumentStore {
  String? contents;

  @override
  Future<String?> read() async => contents;

  @override
  Future<void> write(String value) async => contents = value;
}

class FixedClock implements Clock {
  @override
  DateTime now() => DateTime(2026, 11, 2, 10);
}

void main() {
  test('an attempt survives a reload with its answers, flags and time', () async {
    final store = MemoryStore();
    final repository = AttemptRepository(store, FixedClock());
    final started = await repository.start(paperId: 'gat-01', useEthics: false, minutes: 120);
    final attempt = (started as Ok<Attempt, StorageFailure>).value;
    await repository.update(
      attempt.id,
      (current) => current.copyWith(
        answers: {'q1': 2},
        flagged: {'q2'},
        remainingSeconds: 100,
        currentIndex: 7,
      ),
    );
    final reloaded = await AttemptRepository(store, FixedClock()).byId(attempt.id);
    expect(reloaded!.answers, {'q1': 2});
    expect(reloaded.flagged, {'q2'});
    expect(reloaded.remainingSeconds, 100);
    expect(reloaded.currentIndex, 7);
    expect(reloaded.isFinished, isFalse);
  });

  test('a new attempt gets the paper time in seconds', () async {
    final repository = AttemptRepository(MemoryStore(), FixedClock());
    await repository.start(paperId: 'gat-01', useEthics: true, minutes: 120);
    final all = await repository.watchAll().first;
    expect(all.single.remainingSeconds, 7200);
    expect(all.single.useEthics, isTrue);
  });
}
