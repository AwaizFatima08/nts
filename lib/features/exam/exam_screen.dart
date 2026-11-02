import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nts_prep/app.dart';
import 'package:nts_prep/features/exam/exam_notifier.dart';
import 'package:nts_prep/features/exam/exam_widgets.dart';
import 'package:nts_prep/ui/async_value_view.dart';
import 'package:nts_prep/ui/question_view.dart';
import 'package:nts_prep/ui/theme.dart';

class ExamScreen extends ConsumerStatefulWidget {
  const ExamScreen({required this.attemptId, super.key});

  final String attemptId;

  @override
  ConsumerState<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends ConsumerState<ExamScreen> with WidgetsBindingObserver {
  ExamNotifier get _notifier => ref.read(examProvider(widget.attemptId).notifier);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    if (lifecycle == AppLifecycleState.paused) unawaited(_notifier.pauseTimer());
    if (lifecycle == AppLifecycleState.resumed) _notifier.resumeTimer();
  }

  Future<void> _confirmLeave() async {
    final l10n = context.l10n;
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.leaveTitle),
        content: Text(l10n.leaveBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.stay)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.leave)),
        ],
      ),
    );
    if (leave != true) return;
    await _notifier.pauseTimer();
    if (mounted) context.pop();
  }

  Future<void> _confirmSubmit(ExamState exam) async {
    final l10n = context.l10n;
    final submit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.submitTitle),
        content: Text(
          l10n.submitBody(
            exam.attempt.answers.length,
            exam.sitting.questions.length,
            exam.attempt.flagged.length,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.keepWorking),
          ),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.submit)),
        ],
      ),
    );
    if (submit == true) await _notifier.submit();
  }

  Future<void> _openPalette(ExamState exam) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => QuestionPalette(
      exam: exam,
      onPick: (index) {
        Navigator.pop(context);
        unawaited(_notifier.goTo(index));
      },
      onSubmit: () {
        Navigator.pop(context);
        unawaited(_confirmSubmit(exam));
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    final provider = examProvider(widget.attemptId);
    ref.listen(provider, (previous, next) {
      if (next.value?.attempt.isFinished ?? false) {
        context.pushReplacement('/results/${widget.attemptId}');
      }
    });
    return AsyncValueView(
      value: ref.watch(provider),
      data: (exam) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) unawaited(_confirmLeave());
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              exam.sitting.sections[exam.sitting.sectionOf(exam.attempt.currentIndex)].title,
            ),
            actions: [TimerLabel(seconds: exam.attempt.remainingSeconds)],
          ),
          body: _ExamBody(exam: exam, notifier: _notifier),
          bottomNavigationBar: ExamBar(
            exam: exam,
            onPrevious: () => unawaited(_notifier.goTo(exam.attempt.currentIndex - 1)),
            onNext: () => unawaited(_notifier.goTo(exam.attempt.currentIndex + 1)),
            onPalette: () => unawaited(_openPalette(exam)),
            onSubmit: () => unawaited(_confirmSubmit(exam)),
          ),
        ),
      ),
    );
  }
}

class _ExamBody extends StatelessWidget {
  const _ExamBody({required this.exam, required this.notifier});

  final ExamState exam;
  final ExamNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final question = exam.question;
    final chosen = exam.attempt.answers[question.id];
    final flagged = exam.attempt.flagged.contains(question.id);
    final l10n = context.l10n;
    return ListView(
      key: PageStorageKey(question.id),
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      children: [
        Text(
          l10n.questionOf(exam.attempt.currentIndex + 1, exam.sitting.questions.length),
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        QuestionHeader(question: question, set: exam.sitting.sets[question.setId]),
        for (var i = 0; i < question.options.length; i++)
          OptionBubble(
            index: i,
            text: question.options[i],
            mark: chosen == i ? OptionMark.selected : OptionMark.none,
            onTap: () => unawaited(notifier.choose(i)),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: () => unawaited(notifier.toggleFlag()),
              icon: Icon(flagged ? Icons.flag : Icons.outlined_flag, color: AppColors.flagged),
              label: Text(flagged ? l10n.unflag : l10n.flag),
            ),
            if (chosen != null)
              TextButton(
                onPressed: () => unawaited(notifier.clearAnswer()),
                child: Text(l10n.clearAnswer),
              ),
          ],
        ),
      ],
    );
  }
}
