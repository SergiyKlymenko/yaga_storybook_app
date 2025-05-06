import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../providers/locale_provider.dart';
import '../screens/coloring_screen.dart';
import '../screens/home_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StorybookDrawer extends StatelessWidget {
  final Function(Locale) onLanguageChanged;
  final bool isHomeScreen;

  const StorybookDrawer({
    super.key,
    required this.onLanguageChanged,
    this.isHomeScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final verticalPadding = screenHeight * 0.02;
    final horizontalPadding = screenWidth * 0.05;
    final fontSize = screenHeight * 0.025;

    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 243, 225, 205),
              Color.fromARGB(255, 219, 186, 123)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(height: screenHeight * 0.08),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Text(
                loc.language,
                style: TextStyle(
                  fontSize: fontSize * 1.1,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6D3900),
                  fontFamily: 'FairyFont',
                  shadows: const [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black26,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: verticalPadding / 2),
            _languageTile(context, 'Українська', 'assets/icons/flags/ua.svg',
                const Locale('uk'), fontSize, horizontalPadding),
            _languageTile(context, 'Polski', 'assets/icons/flags/pl.svg',
                const Locale('pl'), fontSize, horizontalPadding),
            _languageTile(context, 'Azərbaycan', 'assets/icons/flags/az.svg',
                const Locale('az'), fontSize, horizontalPadding),
            _languageTile(context, 'English', 'assets/icons/flags/gb.svg',
                const Locale('en'), fontSize, horizontalPadding),
            Divider(height: screenHeight * 0.04, color: Colors.brown.shade200),
            _iconTile(
                context, Icons.brush, loc.coloring, '/coloring', fontSize),
            _iconTile(
                context, Icons.person, loc.aboutAuthor, '/about', fontSize),
            _iconTile(context, Icons.help_outline, loc.faq, '/faq', fontSize),
            Divider(height: screenHeight * 0.04, color: Colors.brown.shade200),
            if (!isHomeScreen)
              ListTile(
                leading: Icon(Icons.home,
                    size: fontSize + 6, color: Colors.brown[700]),
                title: Text(
                  loc.home,
                  style: TextStyle(
                    fontSize: fontSize,
                    color: Colors.brown[800],
                    fontFamily: 'FairyFont',
                  ),
                ),
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _languageTile(
    BuildContext context,
    String title,
    String flagAsset,
    Locale locale,
    double fontSize,
    double horizontalPadding,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.only(
          left: horizontalPadding * 2, right: horizontalPadding),
      leading: ClipOval(
        child: SvgPicture.asset(
          flagAsset,
          width: fontSize + 10,
          height: fontSize + 10,
          fit: BoxFit.cover,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: fontSize,
          fontFamily: 'FairyFont2',
          color: Colors.brown[800],
        ),
      ),
      onTap: () {
        onLanguageChanged(locale);
        Navigator.pop(context);
      },
    );
  }

  Widget _iconTile(
    BuildContext context,
    IconData icon,
    String label,
    String route,
    double fontSize,
  ) {
    return ListTile(
      leading: Icon(icon, size: fontSize + 6, color: Colors.brown[700]),
      title: Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          color: Colors.brown[800],
          fontFamily: 'FairyFont',
        ),
      ),
      onTap: () {
        Navigator.pushNamed(context, route);
      },
    );
  }
}
