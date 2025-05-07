import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';

import '../modules/game/yaga_game.dart';

class YagaGameScreen extends StatefulWidget {
  const YagaGameScreen({super.key});

  @override
  State<YagaGameScreen> createState() => _YagaGameScreenState();
}

class _YagaGameScreenState extends State<YagaGameScreen> {
  bool _isGameStarted = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void _exitToMenu() {
    setState(() {
      _isGameStarted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isGameStarted
          ? Stack(
              children: [
                GameWidget(
                  game: YagaGame(onExit: _exitToMenu),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: ElevatedButton(
                    onPressed: _exitToMenu,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black54),
                    child: const Text('Завершити гру'),
                  ),
                ),
              ],
            )
          : _buildMenu(),
    );
  }

  Widget _buildMenu() {
    return Container(
      color: Colors.green[300],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/yaga.png', // Ваше зображення
                  width: 100, // Можна налаштувати розмір
                  height: 100, // Можна налаштувати розмір
                ),
                const SizedBox(width: 10),
                const Text(
                  'Збери сонячних зайчиків',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => setState(() => _isGameStarted = true),
              style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
              child: const Text('Почати гру', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
              child: const Text('На головний екран',
                  style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}
