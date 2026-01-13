import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import '../models/game_enums.dart';
import '../models/level_config.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'components/animal_component.dart';
import 'components/dust_cloud_component.dart';

/// Main game class for Pet Shelter Rush.
class PetShelterRushGame extends FlameGame
    with HasKeyboardHandlerComponents, TapCallbacks {
  
  final LevelConfig levelConfig;

  PetShelterRushGame({required this.levelConfig});

  // Game State Notifiers
  final ValueNotifier<int> scoreNotifier = ValueNotifier(0);
  final ValueNotifier<int> livesNotifier = ValueNotifier(3);
  final ValueNotifier<double> timeNotifier = ValueNotifier(60.0);
  
  // Internal State
  int score = 0;
  int lives = 3;
  double levelTimeLeft = 60.0; // Seconds (or elapsed time for endless)
  double elapsedTime = 0.0; // Total time played in level
  bool isLevelActive = false;
  bool isGameOver = false;

  // Session Stats (accumulated in memory to reduce disk writes)
  int _sessionAnimals = 0;
  int _sessionDogs = 0;
  int _sessionCats = 0;
  int _sessionWild = 0;

  // Spawning Logic
  double spawnTimer = 0.0;
  double currentSpawnRate = 2.0; // Initial spawn rate
  double timeSinceLastDifficultyIncrease = 0.0;
  bool waitingForSpawn = false;
  int activeAnimalCount = 0; // Track how many animals are currently on screen
  
  // Chain Reaction State
  double spawnRateMultiplier = 1.0; // 1.0 = normal, 0.5 = double speed
  double spawnRateBoostTimer = 0.0; // How long the boost lasts
  int reducedTimeoutCount = 0; // Next N animals have reduced timeout
  double currentTimeoutOverride = 0.0; // Override timeout for chain reaction

  final Random _rng = Random();

  // Zone Indicators
  late RectangleComponent leftZone;
  late RectangleComponent rightZone;
  late RectangleComponent bottomZone;
  
  // Zone Icons
  late SpriteComponent leftIcon;
  late SpriteComponent rightIcon;
  late SpriteComponent bottomIcon;

  bool get isEndless => levelConfig.levelNumber == -1;

  @override
  Color backgroundColor() => AppTheme.creamWhite;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Add Background
    add(SpriteComponent(
      sprite: await loadSprite('backgrounds/bg_gameplay.png'),
      size: size,
      priority: -1, // Behind everything
    ));

    // Add Zone Indicators
    await _addZoneIndicators();

    // Start Level
    _startLevel();
  }

  Future<void> _addZoneIndicators() async {
    // Left Zone (Dogs)
    leftZone = RectangleComponent(
      position: Vector2(0, 0),
      size: Vector2(80, size.y), // Fixed width strip
      paint: Paint()..color = AppTheme.dogRoomColor.withValues(alpha: 0),
    );
    add(leftZone);
    
    leftIcon = SpriteComponent(
      sprite: await loadSprite('ui/icon_dog_room.png'),
      size: Vector2(40, 40),
      anchor: Anchor.center,
      position: Vector2(40, size.y / 2),
    );
    leftIcon.setColor(Colors.white.withValues(alpha: 0.5));
    add(leftIcon);

    // Right Zone (Cats)
    rightZone = RectangleComponent(
      position: Vector2(size.x - 80, 0),
      size: Vector2(80, size.y),
      paint: Paint()..color = AppTheme.catRoomColor.withValues(alpha: 0),
    );
    add(rightZone);
    
    rightIcon = SpriteComponent(
      sprite: await loadSprite('ui/icon_cat_room.png'),
      size: Vector2(40, 40),
      anchor: Anchor.center,
      position: Vector2(size.x - 40, size.y / 2),
    );
    rightIcon.setColor(Colors.white.withValues(alpha: 0.5));
    add(rightIcon);

    // Bottom Zone (Wild)
    bottomZone = RectangleComponent(
      position: Vector2(0, size.y - 80),
      size: Vector2(size.x, 80),
      paint: Paint()..color = AppTheme.exitColor.withValues(alpha: 0),
    );
    add(bottomZone);
    
    bottomIcon = SpriteComponent(
      sprite: await loadSprite('ui/icon_exit.png'),
      size: Vector2(40, 40),
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y - 40),
    );
    bottomIcon.setColor(Colors.white.withValues(alpha: 0.5));
    add(bottomIcon);
  }
  
  void highlightZone(SortDirection direction) {
    // Reset all
    leftZone.paint.color = AppTheme.dogRoomColor.withValues(alpha: 0);
    rightZone.paint.color = AppTheme.catRoomColor.withValues(alpha: 0);
    bottomZone.paint.color = AppTheme.exitColor.withValues(alpha: 0);

    // Highlight specific
    switch (direction) {
      case SortDirection.left:
        leftZone.paint.color = AppTheme.dogRoomColor.withValues(alpha: 0.3);
        break;
      case SortDirection.right:
        rightZone.paint.color = AppTheme.catRoomColor.withValues(alpha: 0.3);
        break;
      case SortDirection.down:
        bottomZone.paint.color = AppTheme.exitColor.withValues(alpha: 0.3);
        break;
      case SortDirection.none:
        break;
    }
  }

  void _startLevel() {
    score = 0;
    lives = 3;
    
    // Reset session stats
    _sessionAnimals = 0;
    _sessionDogs = 0;
    _sessionCats = 0;
    _sessionWild = 0;
    
    if (isEndless) {
      levelTimeLeft = 0.0; // Counts up
    } else {
      levelTimeLeft = levelConfig.duration; // Counts down
    }
    
    elapsedTime = 0.0;
    currentSpawnRate = levelConfig.initialSpawnRate;
    isLevelActive = true;
    isGameOver = false;
    activeAnimalCount = 0;
    waitingForSpawn = true;
    spawnTimer = 0.5; // Small delay before first spawn
    timeSinceLastDifficultyIncrease = 0.0;
    
    // Reset chain reaction state
    spawnRateMultiplier = 1.0;
    spawnRateBoostTimer = 0.0;
    reducedTimeoutCount = 0;
    currentTimeoutOverride = 0.0;

    scoreNotifier.value = score;
    livesNotifier.value = lives;
    timeNotifier.value = levelTimeLeft;

    overlays.add('HUD');
    
    // Start Music
    if (StorageService.instance.getSoundEnabled()) {
      FlameAudio.bgm.play('music_gameplay.mp3', volume: 0.5);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!isLevelActive || isGameOver) return;

    elapsedTime += dt;

    // Update Timer
    if (isEndless) {
      levelTimeLeft += dt;
      timeNotifier.value = levelTimeLeft;
    } else {
      levelTimeLeft -= dt;
      timeNotifier.value = levelTimeLeft;
      
      if (levelTimeLeft <= 0) {
        _levelComplete();
        return;
      }
    }
    
    // Update chain reaction spawn boost timer
    if (spawnRateBoostTimer > 0) {
      spawnRateBoostTimer -= dt;
      if (spawnRateBoostTimer <= 0) {
        spawnRateMultiplier = 1.0; // Reset to normal
      }
    }

    // Update Difficulty - gets harder as level progresses
    timeSinceLastDifficultyIncrease += dt;
    
    double difficultyInterval = isEndless ? 20.0 : 8.0;
    double spawnDecrease = isEndless ? 0.88 : 0.92; // 12% vs 8% decrease
    double minSpawnRate = isEndless ? 0.4 : 0.5;

    if (timeSinceLastDifficultyIncrease >= difficultyInterval) {
      currentSpawnRate = max(minSpawnRate, currentSpawnRate * spawnDecrease);
      timeSinceLastDifficultyIncrease = 0.0;
    }

    // Handle Spawning - spawn if we have room for more animals
    if (waitingForSpawn && activeAnimalCount < levelConfig.maxAnimalsOnScreen) {
      spawnTimer -= dt;
      if (spawnTimer <= 0) {
        _spawnAnimal();
        // Set next spawn timer with chain reaction multiplier applied
        spawnTimer = currentSpawnRate * spawnRateMultiplier;
      }
    }
  }
  
  void _spawnAnimal() {
    if (activeAnimalCount >= levelConfig.maxAnimalsOnScreen) return;

    final types = levelConfig.availableAnimals;
    final type = types[_rng.nextInt(types.length)];
    
    // Calculate spawn position - offset from center if multiple animals allowed
    Vector2 spawnPosition;
    if (levelConfig.maxAnimalsOnScreen == 1) {
      spawnPosition = size / 2;
    } else {
      // Randomize position within the center area
      final centerX = size.x / 2;
      final centerY = size.y / 2;
      final offsetX = (_rng.nextDouble() - 0.5) * 120; // -60 to +60
      final offsetY = (_rng.nextDouble() - 0.5) * 80;  // -40 to +40
      spawnPosition = Vector2(centerX + offsetX, centerY + offsetY);
    }
    
    // Determine timeout (may be reduced by chain reaction)
    double timeout = levelConfig.animalTimeout;
    if (reducedTimeoutCount > 0) {
      timeout = timeout * 0.5; // 50% timeout for chain reaction penalty
      reducedTimeoutCount--;
    }

    final animal = AnimalComponent(
      type: type,
      position: spawnPosition,
      size: Vector2(100, 100),
      onSort: _handleSort,
      onTimeout: _handleTimeout,
      timeoutDuration: timeout,
    );

    add(animal);
    activeAnimalCount++;
  }
  
  /// Handle when an animal times out (wasn't sorted in time)
  void _handleTimeout(AnimalComponent animal) {
    if (!isLevelActive || isGameOver) return;
    
    // Remove the animal
    animal.removeFromParent();
    activeAnimalCount--;
    
    // Count as a wrong sort - lose a life
    _onWrongSort();
    
    // Play timeout sound (reuse wrong sound)
    if (StorageService.instance.getSoundEnabled()) {
      FlameAudio.play('sfx_wrong.mp3');
    }
    
    // Spawn dust cloud at animal position
    add(DustCloudComponent(position: animal.position));
  }

  void _handleSort(AnimalType type, SortDirection direction) {
    bool correct = false;
    bool isWild = type == AnimalType.raccoon || type == AnimalType.skunk;

    switch (type) {
      case AnimalType.dog:
        correct = direction == SortDirection.left;
        break;
      case AnimalType.cat:
        correct = direction == SortDirection.right;
        break;
      case AnimalType.raccoon:
      case AnimalType.skunk:
        correct = direction == SortDirection.down;
        break;
    }

    // Find and remove the specific animal that was sorted
    final animals = children.whereType<AnimalComponent>().toList();
    for (final c in animals) {
       if (c.type == type) {
         c.removeFromParent();
         if (!correct) {
            // Spawn dust cloud at its position
            add(DustCloudComponent(position: c.position));
         }
         break; // Only remove ONE animal of this type
       }
    }
    
    activeAnimalCount--;
    
    if (correct) {
      _onCorrectSort(type);
    } else {
      // Determine chain reaction penalty based on the type of mistake
      _triggerChainReaction(type, direction, isWild);
      _onWrongSort();
    }
    
    // Reset zone highlight
    highlightZone(SortDirection.none);

    // Keep spawning if we have room
    if (!isGameOver && isLevelActive) {
      waitingForSpawn = true;
      // Don't reset timer here - let update() handle continuous spawning
    }
  }
  
  /// Trigger chain reaction penalty based on wrong sort type
  void _triggerChainReaction(AnimalType type, SortDirection direction, bool isWild) {
    if (isWild) {
      // Wild animal sent to a pet room
      if (direction == SortDirection.left || direction == SortDirection.right) {
        // Wild animal scares pets - next 3 animals have 50% timeout
        reducedTimeoutCount = 3;
      }
    } else {
      // Pet (dog or cat) sent wrong
      if (direction == SortDirection.down) {
        // Pet escaped through exit - spawn rate doubles for 5 seconds
        spawnRateMultiplier = 0.5; // Lower = faster spawning
        spawnRateBoostTimer = 5.0;
      } else {
        // Pet sent to wrong room (dog to cat room or vice versa)
        // Animals fight - spawn 2 extra animals immediately
        _spawnBonusAnimals(2);
      }
    }
  }
  
  /// Spawn extra animals as chain reaction penalty
  void _spawnBonusAnimals(int count) {
    for (int i = 0; i < count; i++) {
      // Small delay between bonus spawns
      Future.delayed(Duration(milliseconds: 200 * i), () {
        if (isLevelActive && !isGameOver) {
          // Force spawn even if at max - this is a penalty!
          final types = levelConfig.availableAnimals;
          final type = types[_rng.nextInt(types.length)];
          
          final centerX = size.x / 2;
          final centerY = size.y / 2;
          final offsetX = (_rng.nextDouble() - 0.5) * 150;
          final offsetY = (_rng.nextDouble() - 0.5) * 100;
          
          final animal = AnimalComponent(
            type: type,
            position: Vector2(centerX + offsetX, centerY + offsetY),
            size: Vector2(100, 100),
            onSort: _handleSort,
            onTimeout: _handleTimeout,
            timeoutDuration: levelConfig.animalTimeout,
          );
          
          add(animal);
          activeAnimalCount++;
        }
      });
    }
  }

  void _onCorrectSort(AnimalType type) {
    bool isWild = type == AnimalType.raccoon || type == AnimalType.skunk;
    score += isWild ? 15 : 10;
    scoreNotifier.value = score;
    
    // Accumulate Stats
    _sessionAnimals++;
    if (type == AnimalType.dog) {
      _sessionDogs++;
    } else if (type == AnimalType.cat) {
      _sessionCats++;
    } else {
      _sessionWild++;
    }
    
    // Play Sound
    if (StorageService.instance.getSoundEnabled()) {
      if (type == AnimalType.dog) {
        FlameAudio.play('sfx_bark.mp3');
      } else if (type == AnimalType.cat) {
         FlameAudio.play('sfx_meow.mp3');
      } else {
         FlameAudio.play('sfx_wild_exit.mp3');
      }
    }
  }

  void _onWrongSort() {
    lives--;
    livesNotifier.value = lives;
    if (StorageService.instance.getSoundEnabled()) {
      FlameAudio.play('sfx_wrong.mp3');
    }
    
    if (lives <= 0) {
      _gameOver();
    }
  }
  
  Future<void> _saveSessionStats() async {
    if (_sessionAnimals > 0) {
      await StorageService.instance.incrementStats(
        animals: _sessionAnimals,
        dogs: _sessionDogs,
        cats: _sessionCats,
        wild: _sessionWild,
      );
      // Reset after saving to avoid double counting if called multiple times (though shouldn't happen)
      _sessionAnimals = 0;
      _sessionDogs = 0;
      _sessionCats = 0;
      _sessionWild = 0;
    }
  }

  void _gameOver() async {
    isGameOver = true;
    isLevelActive = false;
    FlameAudio.bgm.stop();
    if (StorageService.instance.getSoundEnabled()) {
      FlameAudio.play('sfx_game_over.mp3');
    }

    // Save Stats
    await _saveSessionStats();

    // Save Endless Stats
    if (isEndless) {
      await StorageService.instance.saveEndlessBestScore(score);
      await StorageService.instance.saveEndlessBestTime(elapsedTime);
    }

    overlays.add('GameOver');
  }

  void _levelComplete() async {
    isLevelActive = false;
    FlameAudio.bgm.stop();
    if (StorageService.instance.getSoundEnabled()) {
      FlameAudio.play('sfx_level_complete.mp3');
    }

    // Save Stats
    await _saveSessionStats();

    // Save Level Stats
    if (!isEndless) {
      await StorageService.instance.saveBestScoreForLevel(levelConfig.levelNumber, score);
      
      // Unlock next level if this was the highest unlocked
      await StorageService.instance.saveHighestLevelUnlocked(levelConfig.levelNumber + 1);
    }

    overlays.add('LevelComplete');
  }

  /// Pause the game and show pause menu.
  void pauseGame() {
    pauseEngine();
    FlameAudio.bgm.pause();
    overlays.add('PauseMenu');
  }
  
  void restartLevel() {
    // If restarting without completing/game over, we might want to discard session stats or save them.
    // Usually restarting a level means "scrap this run".
    // So we just reset session stats in _startLevel without saving.
    
    children.whereType<AnimalComponent>().forEach((c) => c.removeFromParent());
    children.whereType<DustCloudComponent>().forEach((c) => c.removeFromParent());
    activeAnimalCount = 0;
    overlays.remove('GameOver');
    overlays.remove('LevelComplete');
    overlays.remove('PauseMenu');
    
    highlightZone(SortDirection.none);
    
    resumeEngine();
    _startLevel();
  }

  @override
  void onDetach() {
    // Try to save stats if detaching mid-game (e.g. back button pressed)
    // Note: async methods in onDetach might not complete if the app is closing, 
    // but navigating away works.
    if (isLevelActive && !isGameOver) {
      _saveSessionStats();
    }
    
    FlameAudio.bgm.stop();
    super.onDetach();
  }
}
