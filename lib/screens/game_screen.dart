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
    final size = MediaQuery.of(context).size;
    final scrwidth = size.width;
    final scrheight = size.height;
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/game_menu.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: scrheight * 0.1), // Заголовок вище
          const Text(
            'Збери сонячних зайчиків',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          //const Spacer(), // Піднімає блок з кнопками трохи вгору
          SizedBox(height: scrheight * 0.25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => setState(() => _isGameStarted = true),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        horizontal: scrheight * 0.2, vertical: 16),
                  ),
                  child:
                      const Text('Почати гру', style: TextStyle(fontSize: 20)),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        horizontal: scrheight * 0.2, vertical: 16),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('На головний екран',
                      style: TextStyle(fontSize: 20)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}
