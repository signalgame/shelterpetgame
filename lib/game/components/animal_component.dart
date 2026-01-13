import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../../models/game_enums.dart';
import '../pet_shelter_rush_game.dart';

class AnimalComponent extends PositionComponent 
    with DragCallbacks, HasGameReference<PetShelterRushGame> {
  final AnimalType type;
  final Function(AnimalType, SortDirection) onSort;
  final Function(AnimalComponent) onTimeout;
  final double timeoutDuration;
  
  late final Vector2 _originalPosition;
  
  // Visual
  late SpriteComponent _sprite;
  
  // Timeout timer
  double _timeRemaining = 0;
  bool _hasTimedOut = false;
  bool _isDragging = false;
  double _shakeTime = 0; // For smooth shake animation

  AnimalComponent({
    required this.type,
    required this.onSort,
    required this.onTimeout,
    required this.timeoutDuration,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size, anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _originalPosition = position.clone();
    _timeRemaining = timeoutDuration;
    
    // Load sprite based on type
    String spritePath;
    switch (type) {
      case AnimalType.dog:
        spritePath = 'characters/dog.png';
        break;
      case AnimalType.cat:
        spritePath = 'characters/cat.png';
        break;
      case AnimalType.raccoon:
        spritePath = 'characters/raccoon.png';
        break;
      case AnimalType.skunk:
        spritePath = 'characters/skunk.png';
        break;
    }

    _sprite = SpriteComponent(
      sprite: await game.loadSprite(spritePath),
      size: size,
      anchor: Anchor.center,
      position: size / 2,
    );
    
    add(_sprite);

    // Spawn Animation: Scale up with bounce
    scale = Vector2.zero();
    add(
      ScaleEffect.to(
        Vector2.all(1.0),
        EffectController(
          duration: 0.6,
          curve: Curves.elasticOut,
        ),
      ),
    );
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Only count down if not being dragged and game is active
    if (!_isDragging && !_hasTimedOut && game.isLevelActive && !game.isGameOver) {
      _timeRemaining -= dt;
      _shakeTime += dt;
      
      // Shake effect when time is low (under 25%)
      if (_timeRemaining < timeoutDuration * 0.25) {
        // Smooth shake using accumulated time
        final shakeOffset = sin(_shakeTime * 20) * 3;
        _sprite.position = Vector2(size.x / 2 + shakeOffset, size.y / 2);
      } else {
        // Ensure sprite is centered when not shaking
        _sprite.position = size / 2;
      }
      
      if (_timeRemaining <= 0) {
        _hasTimedOut = true;
        onTimeout(this);
      }
    }
  }
  
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Draw timeout ring around the animal
    if (timeoutDuration > 0) {
      final progress = (_timeRemaining / timeoutDuration).clamp(0.0, 1.0);
      final center = Offset(size.x / 2, size.y / 2);
      final radius = size.x / 2 + 8; // Slightly larger than the animal
      
      // Determine color based on time remaining
      Color ringColor;
      if (progress > 0.5) {
        ringColor = Colors.green;
      } else if (progress > 0.25) {
        ringColor = Colors.orange;
      } else {
        ringColor = Colors.red;
      }
      
      // Background ring (gray)
      final bgPaint = Paint()
        ..color = Colors.grey.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6;
      canvas.drawCircle(center, radius, bgPaint);
      
      // Progress ring
      final progressPaint = Paint()
        ..color = ringColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round;
      
      // Draw arc from top, going clockwise
      final rect = Rect.fromCircle(center: center, radius: radius);
      final sweepAngle = 2 * pi * progress;
      canvas.drawArc(rect, -pi / 2, sweepAngle, false, progressPaint);
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    priority = 100; // Bring to front when dragging
    _isDragging = true;
    // Reset sprite position in case it was shaking
    _sprite.position = size / 2;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    // Move the component by the delta
    position += event.localDelta;
    
    // Check direction for highlight
    _updateHighlight();
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    priority = 0; // Reset priority
    _isDragging = false;
    
    _checkSort();
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    priority = 0;
    _isDragging = false;
    _returnToCenter();
  }
  
  void _updateHighlight() {
    final dx = position.x - _originalPosition.x;
    final dy = position.y - _originalPosition.y;
    final threshold = 50.0; // Lower threshold for visual feedback

    SortDirection direction = SortDirection.none;

    if (dx.abs() > dy.abs()) {
      // Horizontal movement dominant
      if (dx < -threshold) {
        direction = SortDirection.left;
      } else if (dx > threshold) {
        direction = SortDirection.right;
      }
    } else {
      // Vertical movement dominant
      if (dy > threshold) {
        direction = SortDirection.down;
      }
    }
    
    game.highlightZone(direction);
  }

  void _checkSort() {
    final dx = position.x - _originalPosition.x;
    final dy = position.y - _originalPosition.y;
    final threshold = 100.0;

    SortDirection direction = SortDirection.none;

    if (dx.abs() > dy.abs()) {
      // Horizontal movement dominant
      if (dx < -threshold) {
        direction = SortDirection.left;
      } else if (dx > threshold) {
        direction = SortDirection.right;
      }
    } else {
      // Vertical movement dominant
      if (dy > threshold) {
        direction = SortDirection.down;
      }
    }

    if (direction != SortDirection.none) {
      onSort(type, direction);
    } else {
      _returnToCenter();
    }
  }

  void _returnToCenter() {
    // Spring back effect
    add(
      MoveEffect.to(
        _originalPosition,
        EffectController(
          duration: 0.3,
          curve: Curves.easeOutBack,
        ),
      ),
    );
    
    // Clear highlight
    game.highlightZone(SortDirection.none);
  }
}
