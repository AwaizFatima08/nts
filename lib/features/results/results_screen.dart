import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nts_prep/ads/ad_service.dart';
import 'package:nts_prep/app.dart';
import 'package:nts_prep/content/content_repository.dart';
import 'package:nts_prep/core/scoring.dart';
import 'package:nts_prep/features/exam/exam_notifier.dart';
import 'package:nts_prep/ui/async_value_view.dart';
import 'package:nts_prep/ui/theme.dart';

class ResultsScreen extends ConsumerStatefulWidget {
  const ResultsScreen({required this.attemptId, super.key});

  final String attemptId;

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen> {
  Future<void> _home() async {
    await ref.read(adServiceProvider).showReportInterstitial();
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AsyncValueView(
      value: ref.watch(reviewProvider(widget.attemptId)),
      data: (exam) {
        final score = scoreSitting(exam.sitting, exam.attempt.answers);
        return Scaffold(
          appBar: AppBar(title: Text(exam.sitting.paper.title)),
          body: ListView(
            padding: const EdgeInsetsDirectional.all(AppSpacing.md),
            children: [
              _ScoreCard(score: score),
              const SizedBox(height: AppSpacing.md),
              FilledButton.icon(
                onPressed: () => unawaited(context.push('/review/${widget.attemptId}')),
                icon: const Icon(Icons.menu_book_outlined),
                label: Text(l10n.reviewAnswers),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(l10n.bySection, style: Theme.of(context).textTheme.titleMedium),
              for (final section in score.sections) _ScoreRow(section.title, section.tally),
              const SizedBox(height: AppSpacing.lg),
              Text(l10n.weakTopics, style: Theme.of(context).textTheme.titleMedium),
              _WeakTopics(score: score),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton(onPressed: () => unawaited(_home()), child: Text(l10n.backHome)),
            ],
          ),
        );
      },
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.score});

  final TestScore score;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final overall = score.overall;
    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
        child: Column(
          children: [
            Text(l10n.results, style: Theme.of(context).textTheme.titleMedium),
            Text(
              l10n.percentLabel(overall.percent),
              style: Theme.of(context).textTheme.displayMedium,
            ),
            Text(l10n.scoreOutOf(overall.correct, overall.total)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.scoreNote(overall.total - score.skipped, score.skipped),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow(this.title, this.tally);

  final String title;
  final Tally tally;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(top: AppSpacing.sm),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: Text(title)),
            Text(context.l10n.scoreOutOf(tally.correct, tally.total)),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        LinearProgressIndicator(value: tally.percent / 100),
      ],
    ),
  );
}

class _WeakTopics extends ConsumerWidget {
  const _WeakTopics({required this.score});

  final TestScore score;

  static const _shown = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) => AsyncBody(
    value: ref.watch(catalogProvider),
    data: (catalog) => Column(
      children: [
        for (final topic in score.topics.take(_shown))
          _ScoreRow(catalog.topicTitle(topic.section, topic.topic), topic.tally),
      ],
    ),
  );
}
