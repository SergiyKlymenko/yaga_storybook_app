import 'dart:ui';
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/collisions.dart';
import 'dart:math';

class YagaGame extends FlameGame with TapDetector, HasCollisionDetection {
  late SpriteComponent yaga;
  late double gravity;
  late double velocity;

  final double jumpForce = -300;

  final List<SunnyBunny> bunnies = [];
  final Random random = Random();

  late TextComponent scoreText;
  int score = 0;
  bool isGameOver = false;

  final VoidCallback onExit;
  YagaGame({required this.onExit});

  @override
  Future<void> onLoad() async {
    gravity = 600;
    velocity = 0;

    // Додаємо фоновий колір або спрайт
    camera.viewport = FixedResolutionViewport(resolution: Vector2(800, 480));

    yaga = SpriteComponent()
      ..sprite = await loadSprite(
          'yaga.png') // Переконайтеся, що це правильний шлях до спрайту
      ..size = Vector2(64, 64)
      ..position = Vector2(100, size.y / 2);

    yaga.add(RectangleHitbox());

    add(yaga);

    // Додаємо текст рахунку
    scoreText = TextComponent(
      text: 'Очки: 0',
      position: Vector2(10, 10),
      anchor: Anchor.topLeft,
      priority: 10,
    );
    add(scoreText);

    spawnBunnies();
  }

  void spawnBunnies() {
    final bunnySize = 40.0;
    final bunnyY = random.nextDouble() * (size.y - bunnySize);

    final sunnyBunny = SunnyBunny(
      position: Vector2(size.x, bunnyY),
      size: Vector2(bunnySize, bunnySize),
    );

    bunnies.add(sunnyBunny);
    add(sunnyBunny);
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
      bunny.x -= 150 * dt; // Швидкість руху зайчиків
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

    if (bunnies.length < 3) {
      spawnBunnies();
    }
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
    yaga.position = Vector2(100, size.y / 2);
    velocity = 0;
    score = 0;
    scoreText.text = 'Очки: 0';

    // Видаляємо всіх зайчиків, перевіряючи, чи належать вони до сцени
    for (final bunny in bunnies) {
      if (bunny.parent != null) {
        // Перевірка на наявність батьківського компонента
        remove(bunny);
      }
    }
    bunnies.clear();

    spawnBunnies();
  }
}

class SunnyBunny extends PositionComponent with CollisionCallbacks {
  late SpriteComponent sprite;

  SunnyBunny({
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    // Використовуємо Sprite.load для завантаження зображення зайчика
    sprite = SpriteComponent()
      ..sprite = await Sprite.load(
          'sunny_bunny.png') // Замість loadSprite використовуйте Sprite.load
      ..size = size;

    add(sprite);
    add(RectangleHitbox());
  }

  @override
  void onCollision(Set<Vector2> points, PositionComponent other) {
    if (other is SpriteComponent) {
      final parent = findGame() as YagaGame;
      parent.score += 1;
      parent.scoreText.text = 'Очки: ${parent.score}';
      parent.remove(this);
    }
  }
}
