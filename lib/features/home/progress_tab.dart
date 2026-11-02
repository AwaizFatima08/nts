import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nts_prep/app.dart';
import 'package:nts_prep/attempts/attempt.dart';
import 'package:nts_prep/attempts/attempt_repository.dart';
import 'package:nts_prep/content/content_repository.dart';
import 'package:nts_prep/content/models.dart';
import 'package:nts_prep/settings/settings_repository.dart';
import 'package:nts_prep/ui/theme.dart';

class ProgressTab extends ConsumerWidget {
  const ProgressTab({super.key});

  static const _minimumAttempted = 5;
  static const _weakShown = 6;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final all = ref.watch(attemptsProvider).value ?? const <Attempt>[];
    final finished = [...all.where((attempt) => attempt.isFinished)];
    final tally = ref.watch(practiceTallyProvider).value ?? const <String, List<int>>{};
    final catalog = ref.watch(catalogProvider).value;
    final papers = ref.watch(papersProvider).value ?? const <Paper>[];
    if (finished.isEmpty && tally.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
          child: Text(l10n.progressEmpty, textAlign: TextAlign.center),
        ),
      );
    }
    final weak = [
      for (final MapEntry(:key, :value) in tally.entries)
        if (value[1] >= _minimumAttempted) (key: key, percent: value[0] * 100 ~/ value[1]),
    ]..sort((a, b) => a.percent.compareTo(b.percent));
    final percents = finished.map((attempt) => attempt.percent).toList();
    final average = percents.isEmpty ? 0 : percents.reduce((a, b) => a + b) ~/ percents.length;
    final best = percents.isEmpty ? 0 : percents.reduce((a, b) => a > b ? a : b);
    return ListView(
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      children: [
        Row(
          children: [
            _Stat(l10n.testsTaken, '${finished.length}'),
            _Stat(l10n.averageScore, l10n.percentLabel(average)),
            _Stat(l10n.bestOverall, l10n.percentLabel(best)),
          ],
        ),
        if (weak.isNotEmpty && catalog != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(l10n.topicMastery, style: Theme.of(context).textTheme.titleMedium),
          for (final topic in weak.take(_weakShown))
            ListTile(
              dense: true,
              title: Text(_title(catalog, topic.key)),
              trailing: Text(l10n.percentLabel(topic.percent)),
              onTap: () => unawaited(context.push('/practice/${topic.key}')),
            ),
        ],
        if (finished.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(l10n.history, style: Theme.of(context).textTheme.titleMedium),
          for (final attempt in finished)
            ListTile(
              title: Text(
                papers.where((p) => p.id == attempt.paperId).firstOrNull?.title ?? attempt.paperId,
              ),
              subtitle: Text(DateFormat.yMMMd().format(attempt.startedAt)),
              trailing: Text(l10n.percentLabel(attempt.percent)),
              onTap: () => unawaited(context.push('/results/${attempt.id}')),
            ),
        ],
      ],
    );
  }

  String _title(Catalog catalog, String key) {
    final [section, topic] = key.split('/');
    return catalog.topicTitle(section, topic);
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        child: Column(
          children: [
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    ),
  );
}
