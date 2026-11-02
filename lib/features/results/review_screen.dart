import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nts_prep/app.dart';
import 'package:nts_prep/content/models.dart';
import 'package:nts_prep/features/exam/exam_notifier.dart';
import 'package:nts_prep/ui/async_value_view.dart';
import 'package:nts_prep/ui/question_view.dart';
import 'package:nts_prep/ui/theme.dart';

enum ReviewFilter { all, wrong, skipped }

class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({required this.attemptId, super.key});

  final String attemptId;

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  ReviewFilter _filter = ReviewFilter.all;

  bool _matches(Question question, Map<String, int> answers) {
    final chosen = answers[question.id];
    return switch (_filter) {
      ReviewFilter.all => true,
      ReviewFilter.wrong => chosen != null && chosen != question.answer,
      ReviewFilter.skipped => chosen == null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AsyncValueView(
      value: ref.watch(reviewProvider(widget.attemptId)),
      data: (exam) {
        final questions = exam.sitting.questions;
        final shown = [
          for (var i = 0; i < questions.length; i++)
            if (_matches(questions[i], exam.attempt.answers)) i,
        ];
        return Scaffold(
          appBar: AppBar(title: Text(l10n.reviewAnswers)),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.all(AppSpacing.sm),
                child: SegmentedButton<ReviewFilter>(
                  segments: [
                    ButtonSegment(value: ReviewFilter.all, label: Text(l10n.filterAll)),
                    ButtonSegment(value: ReviewFilter.wrong, label: Text(l10n.filterWrong)),
                    ButtonSegment(value: ReviewFilter.skipped, label: Text(l10n.filterSkipped)),
                  ],
                  selected: {_filter},
                  onSelectionChanged: (value) => setState(() => _filter = value.first),
                ),
              ),
              Expanded(
                child: shown.isEmpty
                    ? Center(child: Text(l10n.filterEmpty))
                    : ListView.builder(
                        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                        itemCount: shown.length,
                        itemBuilder: (_, position) => _ReviewItem(
                          number: shown[position] + 1,
                          exam: exam,
                          question: questions[shown[position]],
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ReviewItem extends StatelessWidget {
  const _ReviewItem({required this.number, required this.exam, required this.question});

  final int number;
  final ExamState exam;
  final Question question;

  OptionMark _mark(int index, int? chosen) {
    if (index == question.answer) return OptionMark.correct;
    return index == chosen ? OptionMark.wrong : OptionMark.none;
  }

  @override
  Widget build(BuildContext context) {
    final chosen = exam.attempt.answers[question.id];
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            chosen == null ? '$number · ${context.l10n.notAnswered}' : '$number',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          QuestionHeader(question: question, set: exam.sitting.sets[question.setId]),
          for (var i = 0; i < question.options.length; i++)
            OptionBubble(index: i, text: question.options[i], mark: _mark(i, chosen)),
          ExplanationBox(text: question.explanation),
        ],
      ),
    );
  }
}
