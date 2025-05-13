import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/locale_provider.dart';
import '../widgets/magic_button.dart';
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
  final youtube_link_in = dotenv.env['YOUTUBE_LINK_IN'];
  final youtube_link_out = dotenv.env['YOUTUBE_LINK_OUT'];

  final insta_link_in = dotenv.env['INSTA_LINK_IN'];
  final insta_link_out = dotenv.env['INSTA_LINK_OUT'];

  final fb_link_in = dotenv.env['FB_LINK_IN'];
  final fb_link_out = dotenv.env['FB_LINK_OUT'];

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

        if (mounted) setState(() => _iconScale = 1.2);
        await Future.delayed(const Duration(milliseconds: 400));

        if (mounted) setState(() => _iconScale = 1.0);
        await Future.delayed(const Duration(milliseconds: 600));

        await Future.delayed(const Duration(seconds: 5));
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
    final scrwidth = size.width;
    final scrheight = size.height;

    return Scaffold(
      drawer: StorybookDrawer(
        onLanguageChanged: (locale) {
          Provider.of<LocaleProvider>(context, listen: false).setLocale(locale);
        },
        isHomeScreen: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/cover.png',
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: scrheight * 0.02),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: scrwidth * 0.03),
                    child: Builder(
                      builder: (context) => TweenAnimationBuilder<double>(
                        tween: Tween(begin: 1.0, end: _iconScale),
                        duration: const Duration(milliseconds: 400),
                        builder: (context, scale, child) {
                          return Transform.scale(
                            scale: scale,
                            child: IconButton(
                              iconSize: scrwidth * 0.13,
                              tooltip: 'Menu',
                              onPressed: () =>
                                  Scaffold.of(context).openDrawer(),
                              icon: Icon(
                                Icons.auto_awesome,
                                color: Colors.amber[400],
                                shadows: const [
                                  Shadow(
                                    blurRadius: 16,
                                    color: Colors.yellowAccent,
                                    offset: Offset(0, 0),
                                  ),
                                  Shadow(
                                    blurRadius: 32,
                                    color: Colors.orangeAccent,
                                    offset: Offset(0, 0),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: scrheight * 0.001),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: scrwidth * 0.05),
                  child: Text(
                    loc.appTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: scrwidth * 0.10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'FairyFont1',
                      shadows: const [
                        Shadow(
                          blurRadius: 6,
                          color: Color.fromARGB(221, 102, 42, 27),
                          offset: Offset(6, 5),
                        )
                      ],
                    ),
                  ),
                ),
                Spacer(flex: 4),
                MagicButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BookPageScreen(pageNumber: 1),
                      ),
                    );
                  },
                  label: AppLocalizations.of(context)!.startReading,
                  icon: Icon(
                    LucideIcons.wand,
                    size: scrwidth * 0.09,
                    color: const Color.fromARGB(255, 255, 248, 149),
                    shadows: const [
                      Shadow(
                        blurRadius: 8,
                        color: Colors.orangeAccent,
                        offset: Offset(0, 0),
                      ),
                      Shadow(
                        blurRadius: 16,
                        color: Color.fromARGB(255, 231, 54, 0),
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                  width: scrwidth * 0.8,
                  height: scrwidth * 0.18,
                  spacing: 18,
                  textStyle: TextStyle(
                    fontSize: scrwidth * 0.08,
                    color: const Color.fromARGB(255, 105, 57, 12),
                    fontFamily: 'FairyFont',
                    fontWeight: FontWeight.bold,
                    shadows: const [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.black26,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
                Spacer(flex: 3),
                Padding(
                  padding: EdgeInsets.only(bottom: scrheight * 0.02),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _socialIcon(
                        'assets/icons/youtube.png',
                        () => _launchSocialUrl(
                          youtube_link_in!,
                          youtube_link_out!,
                        ),
                        scrwidth,
                      ),
                      _socialIcon(
                        'assets/icons/instagram.png',
                        () => _launchSocialUrl(
                          insta_link_in!,
                          insta_link_out!,
                        ),
                        scrwidth,
                      ),
                      _socialIcon(
                        'assets/icons/facebook.png',
                        () => _launchSocialUrl(
                          fb_link_in!,
                          fb_link_out!,
                        ),
                        scrwidth,
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
