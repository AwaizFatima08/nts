import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nts_prep/ads/ad_service.dart';
import 'package:nts_prep/app.dart';
import 'package:nts_prep/features/practice/practice_notifier.dart';
import 'package:nts_prep/ui/async_value_view.dart';
import 'package:nts_prep/ui/question_view.dart';
import 'package:nts_prep/ui/theme.dart';

class PracticeScreen extends ConsumerWidget {
  const PracticeScreen({required this.section, required this.topic, super.key});

  final String section;
  final String topic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = PracticeKey(section, topic);
    return AsyncValueView(
      value: ref.watch(practiceProvider(key)),
      data: (practice) => Scaffold(
        appBar: AppBar(title: Text(context.l10n.tabPractice)),
        body: switch (practice) {
          PracticeState(questions: []) => Center(child: Text(context.l10n.practiceEmpty)),
          PracticeState(finished: true) => _Summary(practice: practice, practiceKey: key),
          _ => _QuestionPage(
            practice: practice,
            notifier: ref.read(practiceProvider(key).notifier),
          ),
        },
      ),
    );
  }
}

class _QuestionPage extends StatelessWidget {
  const _QuestionPage({required this.practice, required this.notifier});

  final PracticeState practice;
  final PracticeNotifier notifier;

  OptionMark _mark(int index) {
    final chosen = practice.chosen;
    if (chosen == null) return OptionMark.none;
    if (index == practice.question.answer) return OptionMark.correct;
    return index == chosen ? OptionMark.wrong : OptionMark.none;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final question = practice.question;
    final answered = practice.chosen != null;
    final last = practice.index == practice.questions.length - 1;
    return ListView(
      key: PageStorageKey(question.id),
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      children: [
        Text(
          l10n.questionOf(practice.index + 1, practice.questions.length),
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        QuestionHeader(question: question, set: practice.sets[question.setId]),
        for (var i = 0; i < question.options.length; i++)
          OptionBubble(
            index: i,
            text: question.options[i],
            mark: _mark(i),
            onTap: answered ? null : () => notifier.choose(i),
          ),
        if (answered) ...[
          ExplanationBox(text: question.explanation),
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            onPressed: () => unawaited(notifier.next()),
            child: Text(last ? l10n.finish : l10n.next),
          ),
        ],
      ],
    );
  }
}

class _Summary extends ConsumerWidget {
  const _Summary({required this.practice, required this.practiceKey});

  final PracticeState practice;
  final PracticeKey practiceKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.practiceDone,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.practiceTally(practice.correct, practice.questions.length),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: () => ref.invalidate(practiceProvider(practiceKey)),
              child: Text(l10n.practiceAgain),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton(
              onPressed: () async {
                await ref.read(adServiceProvider).showReportInterstitial();
                if (context.mounted) context.pop();
              },
              child: Text(l10n.backHome),
            ),
          ],
        ),
      ),
    );
  }
}
