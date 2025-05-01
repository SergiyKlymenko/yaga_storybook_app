import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/locale_provider.dart';
import '../widgets/storybook_drawer.dart';
import 'book_page_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  double _iconScale = 1.0;

  @override
  void initState() {
    super.initState();
    _startPulsing();
  }

  void _startPulsing() {
    Future.delayed(const Duration(milliseconds: 300), () async {
      while (mounted) {
        if (mounted) setState(() => _iconScale = 1.2);
        await Future.delayed(const Duration(milliseconds: 400));
        if (mounted) setState(() => _iconScale = 1.0);
        await Future.delayed(const Duration(milliseconds: 600));
      }
    });
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
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
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/cover.jpg',
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: height * 0.02),

                // Пульсуюча іконка меню
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: width * 0.03),
                    child: Builder(
                      builder: (context) => TweenAnimationBuilder<double>(
                        tween: Tween(begin: 1.0, end: _iconScale),
                        duration: const Duration(milliseconds: 400),
                        builder: (context, scale, child) {
                          return Transform.scale(
                            scale: scale,
                            child: IconButton(
                              icon: const Icon(Icons.auto_awesome),
                              iconSize: width * 0.13,
                              color: Colors.white,
                              onPressed: () =>
                                  Scaffold.of(context).openDrawer(),
                              tooltip: 'Menu',
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                SizedBox(height: height * 0.03),

                // Заголовок
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                  child: Text(
                    loc.appTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: width * 0.13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'FairyFont',
                      shadows: const [
                        Shadow(
                          blurRadius: 8,
                          color: Colors.black87,
                          offset: Offset(3, 3),
                        )
                      ],
                    ),
                  ),
                ),

                Spacer(flex: 4),

                // Яскрава кнопка "Читати"
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC857), // теплий жовтий
                    foregroundColor: Colors.brown[900],
                    shadowColor: Colors.orangeAccent,
                    elevation: 12,
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.18,
                      vertical: height * 0.025,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    textStyle: TextStyle(
                      fontSize: width * 0.06,
                      fontFamily: 'FairyFont',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BookPageScreen(pageNumber: 1),
                      ),
                    );
                  },
                  child: Text(
                    loc.startReading,
                    style: TextStyle(
                      fontSize: width * 0.085,
                      fontFamily: 'FairyFont',
                      fontWeight: FontWeight.bold,
                      shadows: const [
                        Shadow(
                          blurRadius: 6,
                          color: Colors.black45,
                          offset: Offset(1, 3),
                        )
                      ],
                    ),
                  ),
                ),

                Spacer(flex: 3),

                // Іконки соцмереж
                Padding(
                  padding: EdgeInsets.only(bottom: height * 0.02),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _socialIcon(
                        'assets/icons/youtube.png',
                        () => _launchSocialUrl(
                          'youtube://www.youtube.com/@Veseloped_ua',
                          'https://www.youtube.com/@Veseloped_ua',
                        ),
                        width,
                      ),
                      _socialIcon(
                        'assets/icons/instagram.png',
                        () => _launchSocialUrl(
                          'instagram://user?username=veseloped.ua',
                          'https://www.instagram.com/veseloped.ua/',
                        ),
                        width,
                      ),
                      _socialIcon(
                        'assets/icons/facebook.png',
                        () => _launchSocialUrl(
                          'fb://profile/100076567779795',
                          'https://www.facebook.com/profile.php?id=100076567779795',
                        ),
                        width,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialIcon(String assetPath, VoidCallback onTap, double screenWidth) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
        width: screenWidth * 0.12,
        height: screenWidth * 0.12,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Image.asset(assetPath, fit: BoxFit.contain),
        ),
      ),
    );
  }

  void _launchSocialUrl(String nativeUrl, String webUrl) async {
    final nativeUri = Uri.parse(nativeUrl);
    final webUri = Uri.parse(webUrl);

    if (await canLaunchUrl(nativeUri)) {
      await launchUrl(nativeUri, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }
}
