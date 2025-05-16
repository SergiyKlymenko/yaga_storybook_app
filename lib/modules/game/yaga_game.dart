import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/text.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class YagaGame extends FlameGame with TapDetector, HasCollisionDetection {
  late SpriteComponent yaga;
  late double gravity;
  late double velocity;
  late Timer bunnySpawnTimer;
  late Timer treeSpawnTimer;
  late Timer gTreeSpawnTimer;
  late SpriteComponent background1;
  late SpriteComponent background2;

  final double jumpForce = -450;

  final List<SunnyBunny> bunnies = [];
  final List<Tree> trees = [];
  final List<GTree> gTrees = [];
  final Random random = Random();

  //final backgroundWidth = 1400.0;
  late double backgroundWidth;
  late double backgroundHeight;

  late TextComponent scoreText;
  int score = 0;
  bool isGameOver = false;

  TextComponent? gameOverText;
  TextComponent? scoreDisplayText;

  final VoidCallback onExit;
  final VoidCallback onGameOver;
  final VoidCallback showRestartButton;
  final BuildContext context;
  final VoidCallback onStopMusic; // нове
  final VoidCallback onStartMusic; // нове// Додаємо контекст

  YagaGame({
    required this.onExit,
    required this.onGameOver,
    required this.onStopMusic,
    required this.onStartMusic,
    required this.showRestartButton,
    required this.isGameOver,
    required this.context,
  });

  void updateScoreText() {
    scoreText.text = AppLocalizations.of(context)!.points + ': $score';
  }

  @override
  Future<void> onLoad() async {
    gravity = 700;
    velocity = 0;

    //camera.viewport = FixedResolutionViewport(resolution: Vector2(800, 480));
    final backgroundSprite = await Sprite.load('game_back.png');

    final screenWidth = size.x;
    final screenHeight = size.y;

    // Масштабуємо спрайт до повної висоти екрану
    final scale = size.y / backgroundSprite.srcSize.y;
    final bgWidth = backgroundSprite.srcSize.x * scale;
    final bgHeight = size.y;

    backgroundWidth = bgWidth;
    backgroundHeight = bgHeight;

    background1 = SpriteComponent(
      sprite: backgroundSprite,
      size: Vector2(bgWidth, bgHeight),
      position: Vector2(0, 0),
      priority: -10,
    );

    background2 = SpriteComponent(
      sprite: backgroundSprite,
      size: Vector2(bgWidth, bgHeight),
      position: Vector2(bgWidth, 0),
      priority: -10,
    );

    add(background1);
    add(background2);

    if (isGameOver) return;

    bunnySpawnTimer = Timer(
      1 + random.nextDouble() * 2,
      onTick: spawnBunnies,
      repeat: true,
    );

    treeSpawnTimer = Timer(
      5 + random.nextDouble() * 2,
      onTick: spawnTrees,
      repeat: true,
    )..start();

    gTreeSpawnTimer = Timer(
      5 + random.nextDouble() * 3 + 50,
      onTick: spawnGTrees,
      repeat: true,
    )..start();

    final yagaWidth = size.x * 0.2; // 10% ширини
    final yagaHeight = yagaWidth * 0.8125; // збереження пропорцій (130 / 160)
    yaga = SpriteComponent()
      ..sprite = await Sprite.load('yaga.png')
      ..size = Vector2(yagaWidth, yagaHeight)
      ..position =
          Vector2(size.x * 0.08, size.y * 0.2); // 8% справа, 20% зверху
    yaga.add(RectangleHitbox());
    add(yaga);

    scoreText = TextComponent(
      text: AppLocalizations.of(context)!.points + ': 0',
      position: Vector2(size.x * 0.02, size.y * 0.05),
      anchor: Anchor.topLeft,
      priority: 10,
    );

    add(scoreText);

    /* spawnBunnies();
    spawnTrees();
    spawnGTrees(); */
  }

  void spawnBunnies() {
    final bunnySizeRatio = 0.06 + random.nextDouble() * 0.06; // 3–7% від ширини
    final bunnySize = size.x * bunnySizeRatio;
    final maxY = size.y - bunnySize;
    final bunnyY = random.nextDouble() * maxY;
    final points = (bunnySizeRatio * 100).round();

    final sunnyBunny = SunnyBunny(
        position: Vector2(size.x, bunnyY),
        size: Vector2.all(bunnySize),
        points: points //(bunnySizeRatio * 100).ceil().clamp(1, 5),
        );

    bunnies.add(sunnyBunny);
    add(sunnyBunny);
  }

  void spawnTrees() {
    final treeSizeRatio = 0.06 + random.nextDouble() * 0.06;
    final treeSize = size.x * treeSizeRatio;
    final treeY = random.nextDouble() * (size.y - treeSize);
    final points = (treeSizeRatio * 100).round();

    final tree = Tree(
        position: Vector2(size.x, treeY),
        size: Vector2.all(treeSize),
        points: points //(treeSizeRatio * 100).ceil().clamp(1, 5),
        );

    trees.add(tree);
    add(tree);
  }

  void spawnGTrees() async {
    /*  final gTreeSize = 250.0;

    final gTree = GTree(
      position: Vector2(size.x, size.y - gTreeSize),
      size: Vector2(gTreeSize - 50, gTreeSize),
    ); */

    final sprite = await Sprite.load('tree2.png');
    final scale = size.x * 0.2 / sprite.srcSize.x; // 20% ширини
    final treeSize = Vector2(
      sprite.srcSize.x * scale,
      sprite.srcSize.y * scale,
    );

    final treePosition = Vector2(size.x, size.y - treeSize.y);

    final gTree = GTree(
      position: treePosition,
      size: treeSize,
      sprite: sprite,
    );
    gTrees.add(gTree);
    add(gTree);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver) return;

    velocity += gravity * dt;
    yaga.y += velocity * dt;

    if (yaga.y < 0) yaga.y = 0;
    if (yaga.y > size.y - yaga.height) {
      yaga.y = size.y - yaga.height;
      gameOver();
    } else {
      // Циклічний фон
      const scrollSpeed = 20.0;
      background1.x -= scrollSpeed * dt;
      background2.x -= scrollSpeed * dt;

      if (background1.x + backgroundWidth <= 0) {
        background1.x = background2.x + backgroundWidth;
      }
      if (background2.x + backgroundWidth <= 0) {
        background2.x = background1.x + backgroundWidth;
      }

      for (final bunny in bunnies) {
        bunny.x -= 200 * dt;
      }

      for (final tree in trees) {
        tree.x -= 150 * dt;
      }

      for (final gTree in gTrees) {
        gTree.x -= 100 * dt;
      }

      bunnies.removeWhere((bunny) {
        if (bunny.x + bunny.width < 0) {
          bunny.removeFromParent();
          return true;
        }
        return false;
      });

      trees.removeWhere((tree) {
        if (tree.x + tree.width < 0) {
          tree.removeFromParent();
          return true;
        }
        return false;
      });

      gTrees.removeWhere((gTree) {
        if (gTree.x + gTree.width < 0) {
          gTree.removeFromParent();
          return true;
        }
        return false;
      });

      bunnySpawnTimer.update(dt);
      treeSpawnTimer.update(dt);
      gTreeSpawnTimer.update(dt);
    }
  }

  @override
  void onTapDown(TapDownInfo info) {
    if (isGameOver) {
      // resetGame();
      return;
    } else {
      velocity = jumpForce;
    }
  }

  void gameOver() {
    if (isGameOver) return;

    isGameOver = true;

    // Зупиняємо таймери
    bunnySpawnTimer.stop();
    treeSpawnTimer.stop();
    gTreeSpawnTimer.stop();

    // Центруємо текст кінця гри
    if (gameOverText == null) {
      gameOverText = TextComponent(
        text: AppLocalizations.of(context)!.gameOver,
        textRenderer: TextPaint(
          style: TextStyle(
            fontSize: size.x * 0.05, // адаптивний шрифт
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      add(gameOverText!);
    }

    if (scoreDisplayText == null) {
      scoreDisplayText = TextComponent(
        text: AppLocalizations.of(context)!.points + ': $score',
        textRenderer: TextPaint(
          style: TextStyle(
            fontSize: size.x * 0.03,
            color: Color(0xFFFFF59D),
          ),
        ),
        priority: 20,
      )
        ..anchor = Anchor.center
        ..position = Vector2(size.x * 0.5 + 60, size.y * 0.35);

      add(scoreDisplayText!);
    }

    onStopMusic();

    scoreText.removeFromParent();

    FlameAudio.play('game_over.mp3');

    onGameOver();
  }

  void resetGame() {
    isGameOver = false;
    yaga.position = Vector2(120, size.y / 5);
    velocity = 0;
    score = 0;
    updateScoreText();

    for (final bunny in bunnies) {
      bunny.removeFromParent();
    }
    bunnies.clear();

    for (final tree in trees) {
      tree.removeFromParent();
    }
    trees.clear();

    for (final gTree in gTrees) {
      gTree.removeFromParent();
    }
    gTrees.clear();

    gameOverText?.removeFromParent();
    scoreDisplayText?.removeFromParent();
    gameOverText = null;
    scoreDisplayText = null;

    bunnySpawnTimer.start();
    treeSpawnTimer.start();
    gTreeSpawnTimer.start();

    add(scoreText);

    spawnBunnies();
    spawnTrees();
    spawnGTrees();

    onStartMusic();
  }
}

class SunnyBunny extends PositionComponent with CollisionCallbacks {
  final int points;
  late SpriteComponent sprite;

  SunnyBunny({
    required Vector2 position,
    required Vector2 size,
    required this.points,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    sprite = SpriteComponent()
      ..sprite = await Sprite.load('sunny_bunny.png')
      ..size = size;
    add(sprite);
    add(RectangleHitbox());
  }

  @override
  // ignore: must_call_super
  void onCollision(Set<Vector2> points, PositionComponent other) {
    if (other is SpriteComponent) {
      final game = findGame() as YagaGame;
      game.score += this.points;
      game.updateScoreText();

      final scoreDisplay = ScoreTextEffectComponent(
        text: '+${this.points}',
        position: this.position - Vector2(0, size.y / 2),
        color: const Color(0xFF00FF00),
      );
      game.add(scoreDisplay);

      FlameAudio.play('magic.mp3');

      game.remove(this);
    }
  }
}

class Tree extends PositionComponent with CollisionCallbacks {
  final int points;
  late SpriteComponent sprite;

  Tree({
    required Vector2 position,
    required Vector2 size,
    required this.points,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    sprite = SpriteComponent()
      ..sprite = await Sprite.load('tree1.png')
      ..size = size;
    add(sprite);
    add(RectangleHitbox());
  }

  @override
  void onCollision(Set<Vector2> points, PositionComponent other) {
    if (other is SpriteComponent) {
      final game = findGame() as YagaGame;
      game.score -= this.points;
      if (game.score < 0) game.score = 0;
      game.updateScoreText();

      final scoreDisplay = ScoreTextEffectComponent(
        text: '-${this.points}',
        position: this.position - Vector2(0, size.y / 2),
        color: const Color(0xFFFF0000),
      );
      game.add(scoreDisplay);

      FlameAudio.play('umph.mp3');

      game.remove(this);
    }
  }
}

class GTree extends PositionComponent with CollisionCallbacks {
  late SpriteComponent spriteComponent;

  GTree({
    required Vector2 position,
    required Vector2 size,
    required Sprite sprite,
  }) : super(position: position, size: size) {
    spriteComponent =
        SpriteComponent(sprite: sprite, size: size, position: Vector2.zero());
  }

  @override
  Future<void> onLoad() async {
    spriteComponent = SpriteComponent()
      ..sprite = await Sprite.load('tree2.png')
      ..size = size;
    add(spriteComponent);
    add(RectangleHitbox());
  }

  @override
  void onCollision(Set<Vector2> points, PositionComponent other) {
    if (other is SpriteComponent) {
      final game = findGame() as YagaGame;
      game.gameOver();
    }
  }
}

class ScoreTextEffectComponent extends TextComponent with HasPaint {
  ScoreTextEffectComponent({
    required String text,
    required Vector2 position,
    required Color color,
  }) : super(
          text: text,
          position: position,
          anchor: Anchor.center,
          priority: 20,
          textRenderer: TextPaint(
            style: TextStyle(
              fontSize: 24,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        );

  @override
  Future<void> onLoad() async {
    add(MoveByEffect(Vector2(0, -30), EffectController(duration: 0.5)));
    add(
      OpacityEffect.to(
        0.0,
        EffectController(duration: 0.5),
        onComplete: () => removeFromParent(),
      ),
    );
  }
}
