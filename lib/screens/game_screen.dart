import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:just_audio/just_audio.dart'; // Додаємо імпорт для just_audio
import 'package:yaga_storybook_app/screens/home_screen.dart';
import '../modules/game/yaga_game.dart';
import '../widgets/magic_button.dart';

class YagaGameScreen extends StatefulWidget {
  const YagaGameScreen({super.key});

  @override
  State<YagaGameScreen> createState() => _YagaGameScreenState();
}

class _YagaGameScreenState extends State<YagaGameScreen> {
  bool _isGameStarted = false;
  bool _isGameOver = false;
  bool _showRestartButton = false;
  late final AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _audioPlayer = AudioPlayer();
    _audioPlayer.setAsset('assets/sounds/game_soundtrack.mp3').then((_) {
      _audioPlayer.setLoopMode(LoopMode.one);
      _audioPlayer.play();
    }).catchError((e) {
      debugPrint('❌ Failed to load audio asset: $e');
    });
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void _exitToMenu() {
    setState(() {
      _isGameStarted = false;
      _showRestartButton = false;
    });
  }

  void _gameOver() {
    setState(() {
      _isGameOver = true;
      _showRestartButton = true;
    });
  }

  void _showButton() {
    /*  if (_isGameOver) return;
    setState(() {
      _isGameOver = false;
      _showRestartButton = true;
    }); */
  }

  void _restartGame() {
    setState(() {
      _isGameOver = false; // Скидаємо програш
      _isGameStarted = true; // Починаємо гру знову
      _showRestartButton = false;
    });
    // Логіка для перезапуску гри
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: _isGameStarted
          ? Stack(
              children: [
                GameWidget(
                  game: YagaGame(
                      onExit: _exitToMenu,
                      showRestartButton: _showButton,
                      onGameOver: _gameOver,
                      isGameOver: _isGameOver,
                      context: context),
                ),
                Positioned(
                  top: screenHeight * 0.02,
                  right: screenHeight * 0.08,
                  child: ElevatedButton(
                    onPressed: _exitToMenu,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      side: const BorderSide(
                        color: Color(0xFFFFF59D),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.endGame,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFF59D),
                        shadows: const [
                          Shadow(
                            blurRadius: 6,
                            color: Colors.black26,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Кнопка перезапуску, яка з'являється після програшу
                if (_showRestartButton)
                  Positioned(
                    bottom: screenHeight * 0.1,
                    left: screenWidth * 0.35,
                    child: ElevatedButton(
                      onPressed: _restartGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        side: const BorderSide(
                          color: Color(0xFFFFF59D),
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.tryAgain,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFF59D),
                          shadows: const [
                            Shadow(
                              blurRadius: 6,
                              color: Colors.black26,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SizedBox(),
              ],
            )
          : _buildMenu(),
    );
  }

  Widget _buildMenu() {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/game_menu.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: [
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(top: screenWidth * 0.04),
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.gameTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
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
            ),
          ),
          SizedBox(height: screenWidth * 0.04),
          MagicButton(
            onPressed: () => setState(() {
              _isGameStarted = true;
              _isGameOver = false;
            }),
            label: AppLocalizations.of(context)!.startGame,
            textStyle: TextStyle(
              fontSize: screenWidth * 0.03,
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
            width: screenWidth * 0.28,
            height: screenWidth * 0.07,
            spacing: 0,
          ),
          SizedBox(height: screenWidth * 0.05),
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _audioPlayer.stop();
                _audioPlayer.dispose();
                SystemChrome.setPreferredOrientations(
                    [DeviceOrientation.portraitUp]);
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => HomeScreen()),
                  (route) => false,
                );
              });
            },
            style: OutlinedButton.styleFrom(
              backgroundColor: const Color(0xFF6D4C41),
              foregroundColor: const Color(0xFFFFF9C4),
              side: const BorderSide(color: Color(0xFFFFF59D), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              minimumSize: Size(screenWidth * 0.28, screenWidth * 0.07),
            ),
            child: Text(
              AppLocalizations.of(context)!.home,
              style: TextStyle(
                fontSize: screenWidth * 0.03,
                color: const Color(0xFFFFF9C4),
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
          )
        ],
      ),
    );
  }
}
