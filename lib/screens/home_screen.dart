import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:lucide_icons/lucide_icons.dart';
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
    final width = size.width;
    final height = size.height;

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
                SizedBox(height: height * 0.02),
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
                              iconSize: width * 0.13,
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
                SizedBox(height: height * 0.001),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                  child: Text(
                    loc.appTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: width * 0.10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'FairyFont1',
                      shadows: const [
                        Shadow(
                          blurRadius: 8,
                          color: Color.fromARGB(221, 102, 42, 27),
                          offset: Offset(3, 3),
                        )
                      ],
                    ),
                  ),
                ),
                Spacer(flex: 6),
                MagicReadButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BookPageScreen(pageNumber: 1),
                      ),
                    );
                  },
                ),
                Spacer(flex: 3),
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

class MagicReadButton extends StatefulWidget {
  final VoidCallback onPressed;

  const MagicReadButton({super.key, required this.onPressed});

  @override
  State<MagicReadButton> createState() => _MagicReadButtonState();
}

class _MagicReadButtonState extends State<MagicReadButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: widget.onPressed,
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: width * 0.03,
              horizontal: width * 0.08,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(_glowAnimation.value),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.wand,
                  size: width * 0.09,
                  color: Colors.white,
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
                const SizedBox(width: 18),
                Text(
                  AppLocalizations.of(context)!.startReading,
                  style: TextStyle(
                    fontSize: width * 0.08,
                    color: Color.fromARGB(255, 105, 57, 12),
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
              ],
            ),
          ),
        );
      },
    );
  }
}
