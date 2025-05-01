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
    final paragraphs = text
        .split('\n\n')
        .map((p) =>
            '    ${p.trim()}') // 4 пробіли = візуальний ефект червоного рядка
        .toList();

    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

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
              color: Color.fromARGB(255, 255, 217, 173).withOpacity(0.0001),
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
                        builder: (context) => Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Color.fromARGB(
                                  255, 77, 47, 20), // колір обводки
                              width: 1, // товщина обводки
                            ),
                            shape:
                                BoxShape.circle, // кругла рамка (опціонально)
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.menu,
                              color: Color.fromARGB(255, 77, 47, 20),
                              size: 32,
                            ),
                            onPressed: () => Scaffold.of(context).openDrawer(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        loc.appTitle,
                        style: TextStyle(
                          fontSize: width * 0.06,
                          color: Color.fromARGB(255, 77, 47, 20),
                          fontFamily: 'FairyFont1',
                          shadows: [
                            Shadow(
                              blurRadius: 4,
                              color: Color.fromARGB(133, 250, 244, 232),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: paragraphs.map((p) {
                        if (p.trim().isEmpty) return SizedBox.shrink();
                        final firstLetter = p.trim().substring(0, 1);
                        final restText = p.trim().substring(1);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text.rich(
                            TextSpan(
                              children: [
                                WidgetSpan(
                                  child: SizedBox(
                                      width:
                                          width * 0.05), // візуальний відступ
                                ),
                                TextSpan(
                                  text: firstLetter,
                                  style: TextStyle(
                                    fontSize: width * 0.1,
                                    fontFamily: 'FairyFont1',
                                    color: Color.fromARGB(255, 104, 73, 61),
                                    height: 1.5,
                                  ),
                                ),
                                TextSpan(
                                  text: restText,
                                  style: TextStyle(
                                    fontSize: width * 0.055,
                                    fontFamily: 'FairyFont',
                                    color: Colors.black,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        );
                      }).toList(),
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
