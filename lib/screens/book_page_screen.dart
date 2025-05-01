import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../data/page_texts.dart';
import '../providers/locale_provider.dart';
import '../widgets/audio_cntrols.dart';
import '../widgets/storybook_drawer.dart';

class BookPageScreen extends StatefulWidget {
  final int pageNumber;

  const BookPageScreen({super.key, required this.pageNumber});

  @override
  State<BookPageScreen> createState() => _BookPageScreenState();
}

class _BookPageScreenState extends State<BookPageScreen> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final pageImage = _getBackgroundImage(widget.pageNumber);
    final currentLang =
        Provider.of<LocaleProvider>(context).locale.languageCode;
    final audioPath =
        'assets/audio/$currentLang/audio_page${widget.pageNumber}.mp3';
    final currentLocale = Localizations.localeOf(context).languageCode;
    final text = _getPageText(widget.pageNumber, currentLocale);

    return Scaffold(
      drawer: StorybookDrawer(
        onLanguageChanged: (locale) {
          Provider.of<LocaleProvider>(context, listen: false).setLocale(locale);
        },
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              pageImage,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Builder(
                        builder: (context) => IconButton(
                          icon: const Icon(Icons.menu,
                              color: Color.fromARGB(255, 240, 228, 202),
                              size: 32),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        loc.appTitle,
                        style: const TextStyle(
                          fontSize: 22,
                          color: Color.fromARGB(255, 240, 228, 202),
                          fontFamily: 'FairyFont',
                          shadows: [
                            Shadow(
                              blurRadius: 4,
                              color: Colors.black54,
                              offset: Offset(2, 2),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      text,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontFamily: 'FairyFont',
                        height: 1.4,
                        shadows: [
                          Shadow(
                            blurRadius: 2,
                            color: Colors.black87,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                AudioControls(audioAssetPath: audioPath),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (widget.pageNumber > 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ElevatedButton(
                          style: _navButtonStyle(),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BookPageScreen(
                                    pageNumber: widget.pageNumber - 1),
                              ),
                            );
                          },
                          child: Text(loc.previousPage),
                        ),
                      ),
                    if (widget.pageNumber < 40)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ElevatedButton(
                          style: _navButtonStyle(),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BookPageScreen(
                                    pageNumber: widget.pageNumber + 1),
                              ),
                            );
                          },
                          child: Text(loc.nextPage),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ButtonStyle _navButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      textStyle: const TextStyle(
        fontSize: 16,
        fontFamily: 'FairyFont',
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  String _getPageText(int page, String locale) {
    return pageTexts[locale]?[page] ?? '...';
  }

  String _getBackgroundImage(int pageNumber) {
    final illustrationPages = _getIllustrationPages();
    if (illustrationPages.contains(pageNumber)) {
      return 'assets/images/background_page$pageNumber.jpg';
    } else {
      return 'assets/images/background_text.jpg';
    }
  }

  Set<int> _getIllustrationPages() {
    final raw = dotenv.env['ILLUSTRATION_PAGES'];
    if (raw == null || raw.isEmpty) return {};
    return raw
        .split(',')
        .map((e) => int.tryParse(e.trim()))
        .whereType<int>()
        .toSet();
  }
}
