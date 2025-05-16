import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:just_audio/just_audio.dart';
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

  late final AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _startPulsing();
    _playBackgroundMusic();
  }

  void _playBackgroundMusic() async {
    try {
      await _audioPlayer.setAsset('assets/sounds/book_cover.mp3');
      _audioPlayer.setLoopMode(LoopMode.one);
      await _audioPlayer.setVolume(0.0); // Початкова гучність 0
      _audioPlayer.play();

      _fadeInAudio(targetVolume: 0.5, duration: Duration(seconds: 3));
    } catch (e) {
      debugPrint("Error playing audio: $e");
    }
  }

  void _fadeInAudio(
      {double targetVolume = 1.0,
      Duration duration = const Duration(seconds: 2)}) {
    const int steps = 20;
    final double stepVolume = targetVolume / steps;
    final int stepDurationMs = (duration.inMilliseconds / steps).round();
    double currentVolume = 0.0;

    Timer.periodic(Duration(milliseconds: stepDurationMs), (timer) {
      currentVolume += stepVolume;
      if (currentVolume >= targetVolume) {
        _audioPlayer.setVolume(targetVolume);
        timer.cancel();
      } else {
        _audioPlayer.setVolume(currentVolume);
      }
    });
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
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
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
                  onPressed: () async {
                    await _audioPlayer
                        .stop(); // Зупиняємо аудіо перед переходом
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
