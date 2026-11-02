import 'package:flutter/material.dart';
import 'package:nts_prep/app.dart';
import 'package:nts_prep/features/exam/exam_notifier.dart';
import 'package:nts_prep/ui/theme.dart';

/// Clock text for a number of seconds, e.g. 1:59:30.
String formatClock(int seconds) {
  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  final rest = seconds % 60;
  String two(int value) => value.toString().padLeft(2, '0');
  return hours > 0 ? '$hours:${two(minutes)}:${two(rest)}' : '${two(minutes)}:${two(rest)}';
}

class TimerLabel extends StatelessWidget {
  const TimerLabel({required this.seconds, super.key});

  final int seconds;

  static const _warnBelowSeconds = 300;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(end: AppSpacing.md),
    child: Semantics(
      label: context.l10n.timeLeft,
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, size: 20),
          const SizedBox(width: AppSpacing.xs),
          Text(
            formatClock(seconds),
            style: TextStyle(
              fontFeatures: const [FontFeature.tabularFigures()],
              fontWeight: FontWeight.w600,
              color: seconds < _warnBelowSeconds ? AppColors.amber : null,
            ),
          ),
        ],
      ),
    ),
  );
}

class ExamBar extends StatelessWidget {
  const ExamBar({
    required this.exam,
    required this.onPrevious,
    required this.onNext,
    required this.onPalette,
    required this.onSubmit,
    super.key,
  });

  final ExamState exam;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onPalette;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final index = exam.attempt.currentIndex;
    final last = index == exam.sitting.questions.length - 1;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.sm),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: index == 0 ? null : onPrevious,
                child: Text(l10n.previous),
              ),
            ),
            IconButton(
              tooltip: l10n.questions,
              onPressed: onPalette,
              icon: const Icon(Icons.grid_view),
            ),
            Expanded(
              child: FilledButton(
                onPressed: last ? onSubmit : onNext,
                child: Text(last ? l10n.submit : l10n.next),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// All question numbers by section, showing answered and flagged ones.
class QuestionPalette extends StatelessWidget {
  const QuestionPalette({
    required this.exam,
    required this.onPick,
    required this.onSubmit,
    super.key,
  });

  final ExamState exam;
  final ValueChanged<int> onPick;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final sitting = exam.sitting;
    final starts = sitting.sectionStarts;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      builder: (context, controller) => ListView(
        controller: controller,
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        children: [
          for (var s = 0; s < sitting.sections.length; s++) ...[
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(vertical: AppSpacing.sm),
              child: Text(
                sitting.sections[s].title,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (var i = 0; i < sitting.sections[s].itemIds.length; i++)
                  _PaletteCell(exam: exam, index: starts[s] + i, onPick: onPick),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          FilledButton(onPressed: onSubmit, child: Text(context.l10n.submit)),
        ],
      ),
    );
  }
}

class _PaletteCell extends StatelessWidget {
  const _PaletteCell({required this.exam, required this.index, required this.onPick});

  final ExamState exam;
  final int index;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final id = exam.sitting.questions[index].id;
    final answered = exam.attempt.answers.containsKey(id);
    final flagged = exam.attempt.flagged.contains(id);
    final current = exam.attempt.currentIndex == index;
    return InkWell(
      onTap: () => onPick(index),
      customBorder: const CircleBorder(),
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: answered ? scheme.primary : null,
          border: Border.all(
            color: flagged ? AppColors.flagged : scheme.outline,
            width: flagged || current ? 3 : 1,
          ),
        ),
        child: Text(
          '${index + 1}',
          style: TextStyle(color: answered ? scheme.onPrimary : scheme.onSurface),
        ),
      ),
    );
  }
}
