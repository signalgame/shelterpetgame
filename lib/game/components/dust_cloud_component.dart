import 'package:flame/components.dart';
import 'package:flame/effects.dart';

class DustCloudComponent extends SpriteComponent with HasGameReference {
  DustCloudComponent({required Vector2 position})
      : super(
          position: position,
          size: Vector2.all(120), // Slightly larger than animal
          anchor: Anchor.center,
          priority: 200, // On top of everything
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await game.loadSprite('effects/dust_cloud.png');

    // Effect: Pop in, then fade out
    add(
      SequenceEffect([
        ScaleEffect.to(
          Vector2.all(1.2),
          EffectController(duration: 0.1),
        ),
        OpacityEffect.fadeOut(
          EffectController(duration: 0.4),
          onComplete: removeFromParent,
        ),
      ]),
    );
  }
}

