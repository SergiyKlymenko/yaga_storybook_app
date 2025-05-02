import 'dart:ffi';

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
    final paragraphs =
        text.split('\n\n').map((p) => '    ${p.trim()}').toList();

    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    final isIllustrationPage =
        _getIllustrationPages().contains(widget.pageNumber);

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
                if (!isIllustrationPage) ...[
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Builder(
                          builder: (context) => Container(
                            child: IconButton(
                              icon: const Icon(
                                Icons.menu,
                                color: Color.fromARGB(255, 77, 59, 20),
                                size: 32,
                              ),
                              onPressed: () =>
                                  Scaffold.of(context).openDrawer(),
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
                  Container(
                    width: width * 0.08,
                    height: width * 0.08,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Color.fromARGB(255, 77, 47, 20), width: 1),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${widget.pageNumber}',
                      style: TextStyle(
                        fontSize: width * 0.045,
                        fontFamily: 'FairyFont1',
                        color: Color.fromARGB(255, 77, 47, 20),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  // Якщо фон картинка, відображаємо меню як кнопка з рисочками
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color:
                                Color.fromARGB(255, 87, 71, 41), // колір фону
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color.fromARGB(
                                  255, 255, 247, 224), // обводка
                              width: 1,
                            ),
                          ),
                          child: Builder(
                            builder: (BuildContext context) {
                              return IconButton(
                                icon: const Icon(
                                  Icons.menu, // заміни на іконку трьох рисочок
                                  color: Colors.white,
                                  size: 32,
                                ),
                                onPressed: () =>
                                    Scaffold.of(context).openDrawer(),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (!isIllustrationPage) ...[
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                          left: width * 0.05, right: width * 0.05),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ...paragraphs.map((p) {
                            if (p.trim().isEmpty) return SizedBox.shrink();
                            final firstLetter = p.trim().substring(0, 1);
                            final restText = p.trim().substring(1);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    WidgetSpan(
                                      child: SizedBox(width: width * 0.05),
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
                          }),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  SizedBox(height: height * 0.755),
                ],
                if (!isIllustrationPage)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 247, 224),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.brown.withOpacity(0.3),
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          )
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.volume_up,
                            size: 36,
                            color: Color.fromARGB(
                                128, 77, 47, 20), // Напівпрозорий
                          ),
                          SizedBox(
                              width: width *
                                  0.20), // Проміжок між іконкою та контролем
                          AudioControls(audioAssetPath: audioPath),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: widget.pageNumber == 1
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.spaceBetween,
                      children: [
                        if (widget.pageNumber > 1)
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: ElevatedButton(
                                style: _navButtonStyle(width).copyWith(
                                  backgroundColor: MaterialStateProperty.all(
                                      Color.fromARGB(255, 87, 71, 41)),
                                  elevation: MaterialStateProperty.all(6),
                                  side: MaterialStateProperty.all(BorderSide(
                                    color: const Color.fromARGB(
                                        255, 255, 247, 224), // біла обводка
                                    width: 2, // товщина обводки
                                  )),
                                  shadowColor: MaterialStateProperty.all(Colors
                                      .white
                                      .withOpacity(0.5)), // біла тінь
                                ),
                                onPressed: () =>
                                    _navigateToPage(widget.pageNumber - 1),
                                child: Icon(
                                  Icons.arrow_back,
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                        Expanded(
                          child: Padding(
                            padding: widget.pageNumber == 1
                                ? EdgeInsets.symmetric(horizontal: width * 0.25)
                                : EdgeInsets.symmetric(horizontal: 16),
                            child: ElevatedButton(
                              style: _navButtonStyle(width).copyWith(
                                backgroundColor: MaterialStateProperty.all(
                                    Color.fromARGB(255, 87, 71, 41)),
                                elevation: MaterialStateProperty.all(6),
                                side: MaterialStateProperty.all(BorderSide(
                                  color:
                                      const Color.fromARGB(255, 255, 247, 224),
                                  width: 2, // товщина обводки
                                )),
                                shadowColor: MaterialStateProperty.all(
                                    Colors.white.withOpacity(0.5)), // біла тінь
                              ),
                              onPressed: () =>
                                  _navigateToPage(widget.pageNumber + 1),
                              child: Icon(
                                Icons.arrow_forward,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToPage(int page) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => BookPageScreen(pageNumber: page),
      ),
    );
  }

  ButtonStyle _navButtonStyle(double width) {
    return ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      textStyle: TextStyle(
        fontSize: width * 0.05,
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
      return 'assets/images/background_page$pageNumber.png';
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
