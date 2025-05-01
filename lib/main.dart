import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:yaga_storybook_app/providers/locale_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'screens/about_author_screen.dart';
import 'screens/coloring_screen.dart';
import 'screens/faq_screen.dart';
import 'screens/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // Звичайний портрет
    DeviceOrientation.portraitDown, // Перевернутий портрет
  ]);

  runApp(
    ChangeNotifierProvider(
      create: (_) => LocaleProvider(),
      child: const YagaStorybookApp(),
    ),
  );
}

class YagaStorybookApp extends StatelessWidget {
  const YagaStorybookApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocaleProvider>(context);
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.brown, // Ваш основний колір
        textTheme: TextTheme(
          bodyText1: TextStyle(
              color:
                  Colors.black), // Встановлює чорний колір для основного тексту
          bodyText2: TextStyle(
              color: Colors.black), // Встановлює чорний для другого типу тексту
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.black, // Колір кнопок
        ),
        // Ви можете додати інші стилі для інших елементів тут
      ),
      debugShowCheckedModeBanner: false,
      locale: provider.locale,
      supportedLocales: L10n.all,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const HomeScreen(),
      routes: {
        '/about': (context) => const AboutAuthorScreen(),
        '/faq': (context) => const FaqScreen(),
        '/coloring': (context) => ColoringScreen(),
      },
    );
  }
}
