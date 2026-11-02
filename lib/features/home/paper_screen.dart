import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nts_prep/app.dart';
import 'package:nts_prep/attempts/attempt.dart';
import 'package:nts_prep/attempts/attempt_repository.dart';
import 'package:nts_prep/content/content_repository.dart';
import 'package:nts_prep/content/models.dart';
import 'package:nts_prep/core/result.dart';
import 'package:nts_prep/settings/settings_repository.dart';
import 'package:nts_prep/ui/async_value_view.dart';
import 'package:nts_prep/ui/theme.dart';

/// Pattern of one paper, the start or resume button, and past attempts.
class PaperScreen extends ConsumerWidget {
  const PaperScreen({required this.paperId, super.key});

  final String paperId;

  @override
  Widget build(BuildContext context, WidgetRef ref) => AsyncValueView(
    value: ref.watch(papersProvider),
    data: (papers) {
      final paper = papers.firstWhere((candidate) => candidate.id == paperId);
      return Scaffold(
        appBar: AppBar(title: Text(paper.title)),
        body: AsyncBody(
          value: ref.watch(choiceProvider),
          data: (choice) => AsyncBody(
            value: ref.watch(attemptsProvider),
            data: (attempts) => _PaperBody(
              paper: paper,
              choice: choice,
              attempts: [
                for (final attempt in attempts)
                  if (attempt.paperId == paper.id) attempt,
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _PaperBody extends ConsumerWidget {
  const _PaperBody({required this.paper, required this.choice, required this.attempts});

  final Paper paper;
  final TestChoice choice;
  final List<Attempt> attempts;

  Future<void> _start(BuildContext context, WidgetRef ref) async {
    final started = await ref
        .read(attemptRepositoryProvider)
        .start(paperId: paper.id, useEthics: choice.useEthics, minutes: paper.minutes);
    if (started case Ok(:final value) when context.mounted) {
      unawaited(context.push('/exam/${value.id}'));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final open = attempts.where((attempt) => !attempt.isFinished).firstOrNull;
    final finished = [...attempts.where((attempt) => attempt.isFinished)];
    final sections = paper.sectionsFor(useEthics: choice.useEthics);
    final hasEthics = paper.sections.any((section) => section.alt != null);
    return ListView(
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      children: [
        Text(l10n.minutesLabel(paper.minutes), style: Theme.of(context).textTheme.titleMedium),
        for (final section in sections)
          ListTile(
            dense: true,
            title: Text(section.title),
            trailing: Text(l10n.sectionCount(section.itemIds.length)),
          ),
        if (hasEthics)
          SwitchListTile(
            title: Text(l10n.useEthics),
            subtitle: Text(l10n.useEthicsHelp),
            value: choice.useEthics,
            onChanged: open != null
                ? null
                : (value) => unawaited(
                    ref.read(choiceProvider.notifier).choose(choice.copyWith(useEthics: value)),
                  ),
          ),
        const SizedBox(height: AppSpacing.sm),
        Text(l10n.paperRules),
        const SizedBox(height: AppSpacing.xs),
        Text(l10n.unofficialNote, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: AppSpacing.md),
        if (open != null) ...[
          FilledButton(
            onPressed: () => unawaited(context.push('/exam/${open.id}')),
            child: Text(l10n.resumeTest),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            onPressed: () async {
              await ref.read(attemptRepositoryProvider).delete(open.id);
              if (context.mounted) await _start(context, ref);
            },
            child: Text(l10n.restartTest),
          ),
        ] else
          FilledButton(
            onPressed: () => unawaited(_start(context, ref)),
            child: Text(l10n.startTest),
          ),
        if (finished.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(l10n.previousAttempts, style: Theme.of(context).textTheme.titleMedium),
          for (final attempt in finished)
            ListTile(
              title: Text(l10n.percentLabel(attempt.percent)),
              subtitle: Text(l10n.scoreOutOf(attempt.correct ?? 0, attempt.total ?? 0)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => unawaited(context.push('/results/${attempt.id}')),
            ),
        ],
      ],
    );
  }
}
