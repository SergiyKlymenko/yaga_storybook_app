import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../providers/locale_provider.dart';
import '../screens/coloring_screen.dart';
import '../screens/home_screen.dart';

class StorybookDrawer extends StatelessWidget {
  final Function(Locale) onLanguageChanged;

  const StorybookDrawer({
    super.key,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final verticalPadding = screenHeight * 0.02;
    final horizontalPadding = screenWidth * 0.05;
    final fontSize = screenHeight * 0.022;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(height: screenHeight * 0.08), // верхній відступ

          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Text(
              loc.language,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ),
          SizedBox(height: verticalPadding / 2),
          _languageTile(context, 'Українська', const Locale('uk'), fontSize,
              horizontalPadding),
          _languageTile(context, 'English', const Locale('en'), fontSize,
              horizontalPadding),
          _languageTile(context, 'Polski', const Locale('pl'), fontSize,
              horizontalPadding),
          _languageTile(context, 'Azərbaycan', const Locale('az'), fontSize,
              horizontalPadding),

          Divider(height: screenHeight * 0.04),

          _iconTile(context, Icons.brush, loc.coloring, '/coloring', fontSize),
          _iconTile(context, Icons.person, loc.aboutAuthor, '/about', fontSize),
          _iconTile(context, Icons.help_outline, loc.faq, '/faq', fontSize),

          Divider(height: screenHeight * 0.04),

          ListTile(
            leading: Icon(Icons.home, size: fontSize + 6),
            title: Text(
              loc.home,
              style: TextStyle(fontSize: fontSize),
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
    );
  }

  Widget _languageTile(
    BuildContext context,
    String title,
    Locale locale,
    double fontSize,
    double horizontalPadding,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.only(
          left: horizontalPadding * 2, right: horizontalPadding),
      title: Text(title, style: TextStyle(fontSize: fontSize)),
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
      leading: Icon(icon, size: fontSize + 6),
      title: Text(label, style: TextStyle(fontSize: fontSize)),
      onTap: () {
        Navigator.pushNamed(context, route);
      },
    );
  }
}
