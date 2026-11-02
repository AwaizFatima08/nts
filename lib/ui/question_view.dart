import 'package:flutter/material.dart';
import 'package:nts_prep/app.dart';
import 'package:nts_prep/content/models.dart';
import 'package:nts_prep/ui/theme.dart';

/// Shared passage or scenario, collapsible so the question stays in view.
class SetPanel extends StatefulWidget {
  const SetPanel({required this.set, this.startOpen = true, super.key});

  final QuestionSet set;
  final bool startOpen;

  @override
  State<SetPanel> createState() => _SetPanelState();
}

class _SetPanelState extends State<SetPanel> {
  late bool _open = widget.startOpen;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.set.title.isNotEmpty)
            Text(widget.set.title, style: Theme.of(context).textTheme.titleSmall),
          if (_open) ...[
            const SizedBox(height: AppSpacing.sm),
            SelectableText(widget.set.text, style: const TextStyle(height: 1.45)),
          ],
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: () => setState(() => _open = !_open),
              child: Text(_open ? context.l10n.hidePassage : context.l10n.readPassage),
            ),
          ),
        ],
      ),
    ),
  );
}

class QuestionTable extends StatelessWidget {
  const QuestionTable({required this.rows, super.key});

  final List<List<String>> rows;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: DataTable(
      headingRowHeight: 36,
      dataRowMinHeight: 32,
      dataRowMaxHeight: 40,
      columns: [for (final cell in rows.first) DataColumn(label: Text(cell))],
      rows: [
        for (final row in rows.skip(1))
          DataRow(cells: [for (final cell in row) DataCell(Text(cell))]),
      ],
    ),
  );
}

/// The passage (if any), table (if any) and stem of a question.
class QuestionHeader extends StatelessWidget {
  const QuestionHeader({required this.question, this.set, this.passageOpen = true, super.key});

  final Question question;
  final QuestionSet? set;

  /// Whether a shared passage starts expanded; collapsed in review, where it repeats.
  final bool passageOpen;

  @override
  Widget build(BuildContext context) {
    final table = question.table;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (set case final panel?)
          SetPanel(key: ValueKey(question.setId), set: panel, startOpen: passageOpen),
        if (table != null) QuestionTable(rows: table),
        const SizedBox(height: AppSpacing.sm),
        Text(question.stem, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}

/// How an option should look once answers are revealed.
enum OptionMark { none, selected, correct, wrong }

/// One answer row with a lettered bubble, like an NTS answer sheet.
class OptionBubble extends StatelessWidget {
  const OptionBubble({
    required this.index,
    required this.text,
    required this.mark,
    this.onTap,
    super.key,
  });

  final int index;
  final String text;
  final OptionMark mark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colour = switch (mark) {
      OptionMark.none => scheme.outline,
      OptionMark.selected => scheme.primary,
      OptionMark.correct => AppColors.correct,
      OptionMark.wrong => AppColors.incorrect,
    };
    final filled = mark != OptionMark.none;
    final letter = String.fromCharCode(65 + index);
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Semantics(
          selected: filled,
          button: onTap != null,
          child: Container(
            constraints: const BoxConstraints(minHeight: 52),
            padding: const EdgeInsetsDirectional.all(AppSpacing.sm),
            decoration: BoxDecoration(
              border: Border.all(color: colour, width: filled ? 2 : 1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: filled ? colour : Colors.transparent,
                  foregroundColor: filled ? Colors.white : scheme.onSurface,
                  child: Text(letter),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(text)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The explanation box shown after an answer is revealed.
class ExplanationBox extends StatelessWidget {
  const ExplanationBox({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.explanation, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(text, style: TextStyle(color: scheme.onSecondaryContainer, height: 1.4)),
        ],
      ),
    );
  }
}
