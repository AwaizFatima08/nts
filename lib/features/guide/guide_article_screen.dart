import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nts_prep/content/content_repository.dart';
import 'package:nts_prep/ui/async_value_view.dart';
import 'package:nts_prep/ui/theme.dart';

class GuideArticleScreen extends ConsumerWidget {
  const GuideArticleScreen({required this.articleId, super.key});

  final String articleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) => AsyncValueView(
    value: ref.watch(guideProvider),
    data: (articles) {
      final article = articles.firstWhere((candidate) => candidate.id == articleId);
      return Scaffold(
        appBar: AppBar(title: Text(article.title)),
        body: ListView(
          padding: const EdgeInsetsDirectional.all(AppSpacing.md),
          children: [for (final line in article.lines) _GuideLine(line)],
        ),
      );
    },
  );
}

class _GuideLine extends StatelessWidget {
  const _GuideLine(this.line);

  final String line;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    if (line.startsWith('## ')) {
      return Padding(
        padding: const EdgeInsetsDirectional.only(top: AppSpacing.md, bottom: AppSpacing.xs),
        child: Text(line.substring(3), style: theme.titleMedium),
      );
    }
    if (line.startsWith('- ')) {
      return Padding(
        padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.xs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('•  '),
            Expanded(child: Text(line.substring(2), style: const TextStyle(height: 1.4))),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
      child: Text(line, style: const TextStyle(height: 1.4)),
    );
  }
}
