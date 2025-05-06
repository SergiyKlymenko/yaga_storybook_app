import 'dart:ffi';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:turn_page_transition/turn_page_transition.dart';

import '../data/page_texts.dart';
import '../providers/locale_provider.dart';
import '../widgets/audio_cntrols.dart';
import '../widgets/page_flip_wrapper.dart';
import '../widgets/storybook_drawer.dart';

class BookPageScreen extends StatefulWidget {
  final int pageNumber;
  final bool isEmbedded;

  const BookPageScreen({
    Key? key,
    required this.pageNumber,
    this.isEmbedded = false,
  }) : super(key: key);

  @override
  State<BookPageScreen> createState() => _BookPageScreenState();
}

class _BookPageScreenState extends State<BookPageScreen> {
  late AudioPlayer _pageFlipPlayer;

  @override
  void initState() {
    super.initState();
    _pageFlipPlayer = AudioPlayer();
    _pageFlipPlayer.setAsset('assets/sounds/page_flip1.mp3');
  }

  @override
  void dispose() {
    _pageFlipPlayer.dispose();
    super.dispose();
  }

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
    final scrwidth = size.width;
    final scrheight = size.height;

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
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                    child: Row(
                      children: [
                        Builder(
                          builder: (context) => Container(
                            child: IconButton(
                              icon: Icon(
                                Icons.menu,
                                color: Color.fromARGB(255, 77, 59, 20),
                                size: scrheight * 0.05,
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
                            fontSize: scrwidth * 0.06,
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
                    width: scrwidth * 0.08,
                    height: scrwidth * 0.08,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Color.fromARGB(255, 77, 47, 20), width: 1),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${widget.pageNumber}',
                      style: TextStyle(
                        fontSize: scrwidth * 0.045,
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
                                icon: Icon(
                                  Icons.menu, // заміни на іконку трьох рисочок
                                  color: Colors.white,
                                  size: scrheight * 0.04,
                                ),
                                onPressed: () =>
                                    Scaffold.of(context).openDrawer(),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        /* Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 87, 71, 41),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          /*  child: Text(
                            loc.continueOnNextPage,
                            style: TextStyle(
                              fontSize: width * 0.04,
                              color: Colors.white,
                              fontFamily: 'FairyFont',
                              shadows: const [
                                Shadow(
                                  blurRadius: 4,
                                  color: Color.fromARGB(133, 0, 0, 0),
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                          ), */
                        ) */
                      ],
                    ),
                  ),
                ],
                if (!isIllustrationPage) ...[
                  Expanded(
                    child: Scrollbar(
                      thumbVisibility: true,
                      thickness: 8,
                      radius: Radius.circular(12),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(
                            left: scrwidth * 0.05, right: scrwidth * 0.05),
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
                                        child: SizedBox(width: scrwidth * 0.05),
                                      ),
                                      TextSpan(
                                        text: firstLetter,
                                        style: TextStyle(
                                          fontSize: scrwidth * 0.1,
                                          fontFamily: 'FairyFont1',
                                          color:
                                              Color.fromARGB(255, 104, 73, 61),
                                          height: 1.5,
                                        ),
                                      ),
                                      TextSpan(
                                        text: restText,
                                        style: TextStyle(
                                          fontSize: scrwidth * 0.055,
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
                  ),
                ] else ...[
                  //SizedBox(height: scrheight * 0.76),
                  Spacer(),
                ],
                if (!isIllustrationPage)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Container(
                      height: scrheight * 0.05,
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
                      //padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Stack(
                        children: [
                          // Центрований аудіоконтрол
                          Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: EdgeInsets.all(0),
                              child: AudioControls(audioAssetPath: audioPath),
                            ),
                          ),

                          // Іконка зліва
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.all(6), // Відступ
                              child: Icon(
                                Icons.volume_up,
                                size: 30,
                                color: Color.fromARGB(128, 77, 47, 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                SizedBox(height: scrheight * 0.01),
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
                              padding: EdgeInsets.symmetric(
                                  horizontal: scrwidth * 0.15),
                              child: ElevatedButton(
                                style: _navButtonStyle(scrwidth).copyWith(
                                  backgroundColor: MaterialStateProperty.all(
                                      Color.fromARGB(255, 77, 59, 20)),
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
                                  Icons.arrow_back_ios_new,
                                  size: 30,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        Expanded(
                          child: Padding(
                            padding: widget.pageNumber == 1
                                ? EdgeInsets.symmetric(
                                    horizontal: scrwidth * 0.30)
                                : EdgeInsets.symmetric(
                                    horizontal: scrwidth * 0.15),
                            child: ElevatedButton(
                              style: _navButtonStyle(scrwidth).copyWith(
                                backgroundColor: MaterialStateProperty.all(
                                    Color.fromARGB(255, 77, 59, 20)),
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
                                Icons.arrow_forward_ios,
                                color: Colors.white,
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

  void _navigateToPage(int page) async {
    bool isBack = page < widget.pageNumber;

    Future.delayed(const Duration(milliseconds: 100), () async {
      await _pageFlipPlayer.seek(Duration.zero);
      await _pageFlipPlayer.play();
    });

    Navigator.push(
      context,
      TurnPageRoute(
        builder: (_) => BookPageScreen(pageNumber: page),
        transitionDuration: const Duration(milliseconds: 1000),
        overleafColor: Colors.brown.shade100,
        direction:
            isBack ? TurnDirection.leftToRight : TurnDirection.rightToLeft,
      ),
    );

    /* Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => BookPageScreen(pageNumber: page),
      ),
    ); */

    //final totalPages = int.tryParse(dotenv.env['TOTAL_PAGES'] ?? '') ?? 0;

    //if (widget.isEmbedded) return;

    /* Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PageFlipScreen(
          initialPage: page,
          totalPages: totalPages,
        ),
      ),
    ); */

    // трохи зачекати, щоб звук встиг програтись
    //await Future.delayed(Duration(milliseconds: 150));
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
