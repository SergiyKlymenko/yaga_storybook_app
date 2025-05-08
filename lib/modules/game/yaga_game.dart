import 'dart:ui';
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/collisions.dart';
import 'package:flame/text.dart';
import 'dart:math';

class YagaGame extends FlameGame with TapDetector, HasCollisionDetection {
  late SpriteComponent yaga;
  late double gravity;
  late double velocity;
  late Timer bunnySpawnTimer;
  late Timer treeSpawnTimer;
  late Timer gTreeSpawnTimer;

  final double jumpForce = -400; // Збільшили силу стрибка

  final List<SunnyBunny> bunnies = [];
  final List<Tree> trees = [];
  final List<GTree> gTrees = [];
  final Random random = Random();

  late TextComponent scoreText;
  int score = 0;
  bool isGameOver = false;

  final VoidCallback onExit;
  YagaGame({required this.onExit});

  @override
  Future<void> onLoad() async {
    gravity = 870;
    velocity = 0;

    bunnySpawnTimer = Timer(
      1 + random.nextDouble() * 2, // Випадковий інтервал 1–3 сек
      onTick: spawnBunnies,
      repeat: true,
    );

    treeSpawnTimer = Timer(
      5 + random.nextDouble() * 2,
      onTick: spawnTrees,
      repeat: true,
    );
    treeSpawnTimer.start();

    gTreeSpawnTimer = Timer(
      5 + random.nextDouble() * 3 + 5,
      onTick: spawnGTrees,
      repeat: true,
    );
    gTreeSpawnTimer.start();

    camera.viewport = FixedResolutionViewport(resolution: Vector2(800, 480));

    yaga = SpriteComponent()
      ..sprite = await Sprite.load('yaga.png') // Завантажуємо спрайт
      ..size = Vector2(140, 110)
      ..position = Vector2(80, size.y / 5);

    yaga.add(RectangleHitbox());

    add(yaga);

    scoreText = TextComponent(
      text: 'Очки: 0',
      position: Vector2(10, 10),
      anchor: Anchor.topLeft,
      priority: 10,
    );
    add(scoreText);

    spawnBunnies();
    spawnTrees();
    spawnGTrees();
  }

  void spawnBunnies() {
    final bunnySize = 35.0 + random.nextDouble() * 50;
    final maxY = size.y - bunnySize;
    final double minY = 0;
    final bunnyY = random.nextDouble() * (maxY - minY) + minY;

    // Чим більший розмір – тим більше очок (1 до 5)
    final int points = ((bunnySize - 30) / 6).ceil().clamp(1, 5);

    final sunnyBunny = SunnyBunny(
      position: Vector2(size.x, bunnyY),
      size: Vector2(bunnySize, bunnySize),
      points: points,
    );

    bunnies.add(sunnyBunny);
    add(sunnyBunny);
  }

  void spawnTrees() {
    final treeSize = 35.0 + random.nextDouble() * 50;
    final maxY = size.y - treeSize;
    final treeY = random.nextDouble() * maxY;

    // Чим більший розмір – тим більше очок (1 до 5)
    final int points = ((treeSize - 30) / 6).ceil().clamp(1, 5);

    final tree = Tree(
      position: Vector2(size.x, treeY),
      size: Vector2(treeSize, treeSize),
      points: points,
    );

    trees.add(tree);
    add(tree);
  }

  void spawnGTrees() {
    final gTreeSize = 200.0;

    final gTree = GTree(
        position: Vector2(size.x, size.y - 220),
        size: Vector2(gTreeSize, gTreeSize));

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
    }

    // Рух зайчиків вліво
    for (final bunny in bunnies) {
      bunny.x -= 200 * dt; // Швидкість руху зайчиків
    }

    // Рух tree вліво
    for (final tree in trees) {
      tree.x -= 150 * dt;
    }

    // Рух g tree вліво
    for (final gTree in gTrees) {
      gTree.x -= 100 * dt;
    }

    // Видалення зайчиків за межами екрану + нові зайчики
    bunnies.removeWhere((bunny) {
      if (bunny.x + bunny.width < 0) {
        if (bunny.parent != null) {
          remove(bunny);
        }
        return true;
      }
      return false;
    });

    trees.removeWhere((tree) {
      if (tree.x + tree.width < 0) {
        if (tree.parent != null) {
          remove(tree);
        }
        return true;
      }
      return false;
    });

    gTrees.removeWhere((gTree) {
      if (gTree.x + gTree.width < 0) {
        if (gTree.parent != null) {
          remove(gTree);
        }
        return true;
      }
      return false;
    });

    bunnySpawnTimer.update(dt);

    treeSpawnTimer.update(dt);

    gTreeSpawnTimer.update(dt);
  }

  @override
  void onTap() {
    if (isGameOver) {
      resetGame();
    } else {
      velocity = jumpForce;
    }
  }

  void gameOver() {
    isGameOver = true;
    scoreText.text = 'Кінець гри! Очки: $score\nТоркнись, щоб почати знову.';
  }

  void resetGame() {
    isGameOver = false;
    yaga.position = Vector2(120, size.y / 5);
    velocity = 0;
    score = 0;
    scoreText.text = 'Очки: 0';

    for (final bunny in bunnies) {
      if (bunny.parent != null) {
        remove(bunny);
      }
    }
    bunnies.clear();

    for (final tree in trees) {
      if (tree.parent != null) {
        remove(tree);
      }
    }
    trees.clear();

    for (final gTree in gTrees) {
      if (gTree.parent != null) {
        remove(gTree);
      }
    }
    gTrees.clear();

    spawnBunnies();
    spawnTrees();
    spawnGTrees();
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
  void onCollision(Set<Vector2> points, PositionComponent other) {
    if (other is SpriteComponent) {
      final game = findGame() as YagaGame;
      game.score += this.points;
      game.scoreText.text = 'Очки: ${game.score}';

      // Додаємо ефект очок над зайчиком
      final scoreDisplay = ScoreTextEffectComponent(
        text: '+${this.points}',
        position: this.position - Vector2(0, size.y / 2),
        color: const Color(0xFF00FF00), // зелений
      );
      game.add(scoreDisplay);

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
      if (game.score < 0) {
        game.score = 0;
      }
      game.scoreText.text = 'Очки: ${game.score}';

      // Додаємо ефект очок над деревом
      final scoreDisplay = ScoreTextEffectComponent(
        text: '-${this.points}',
        position: this.position - Vector2(0, size.y / 2),
        color: const Color(0xFFFF0000), // червоний
      );
      game.add(scoreDisplay);

      game.remove(this);
    }
  }
}

class GTree extends PositionComponent with CollisionCallbacks {
  late SpriteComponent sprite;

  GTree({
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    sprite = SpriteComponent()
      ..sprite = await Sprite.load('tree2.png')
      ..size = size;
    add(sprite);
    add(RectangleHitbox());
  }

  @override
  void onCollision(Set<Vector2> points, PositionComponent other) {
    if (other is SpriteComponent) {
      final game = findGame() as YagaGame;
      game.gameOver(); // Викликаємо метод gameOver через гру
    }
  }
}

class ScoreTextEffectComponent extends TextComponent with HasPaint {
  ScoreTextEffectComponent({
    required String text,
    required Vector2 position,
    required Color color, // новий параметр
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
    add(
      MoveByEffect(
        Vector2(0, -30),
        EffectController(duration: 0.5),
      ),
    );

    add(
      OpacityEffect.to(
        0.0,
        EffectController(duration: 0.5),
        onComplete: () => removeFromParent(),
      ),
    );
  }
}
