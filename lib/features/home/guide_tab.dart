import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nts_prep/content/content_repository.dart';
import 'package:nts_prep/content/models.dart';
import 'package:nts_prep/ui/async_value_view.dart';
import 'package:nts_prep/ui/theme.dart';

class GuideTab extends ConsumerWidget {
  const GuideTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => AsyncBody(
    value: ref.watch(guideProvider),
    data: (articles) {
      final groups = <String, List<GuideArticle>>{};
      for (final article in articles) {
        (groups[article.group] ??= []).add(article);
      }
      return ListView(
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        children: [
          for (final MapEntry(key: group, value: items) in groups.entries) ...[
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(vertical: AppSpacing.sm),
              child: Text(group, style: Theme.of(context).textTheme.titleMedium),
            ),
            for (final article in items)
              Card(
                child: ListTile(
                  title: Text(article.title),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => unawaited(context.push('/guide/${article.id}')),
                ),
              ),
          ],
        ],
      );
    },
  );
}
