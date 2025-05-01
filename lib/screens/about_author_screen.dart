import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AboutAuthorScreen extends StatelessWidget {
  const AboutAuthorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.aboutAuthor),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          loc.aboutAuthorText,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
