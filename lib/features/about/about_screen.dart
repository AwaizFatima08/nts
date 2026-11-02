import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nts_prep/app.dart';
import 'package:nts_prep/ui/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _site = 'https://nts.homilabs.org';

  void _open(String url) => unawaited(launchUrl(Uri.parse(url)));

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.about)),
      body: ListView(
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        children: [
          Text(l10n.appTitle, style: Theme.of(context).textTheme.titleLarge),
          Text(l10n.version),
          const SizedBox(height: AppSpacing.md),
          Text(l10n.aboutBody),
          const SizedBox(height: AppSpacing.md),
          ListTile(title: Text(l10n.website), onTap: () => _open(_site)),
          ListTile(title: Text(l10n.privacy), onTap: () => _open('$_site/privacy.html')),
          ListTile(title: Text(l10n.terms), onTap: () => _open('$_site/terms.html')),
          ListTile(title: Text(l10n.contact)),
        ],
      ),
    );
  }
}
