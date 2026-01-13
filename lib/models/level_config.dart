import 'game_enums.dart';

class LevelConfig {
  final int levelNumber;
  final double duration; // In seconds
  final double initialSpawnRate;
  final List<AnimalType> availableAnimals;
  final int maxAnimalsOnScreen; // How many animals can be on screen at once
  final double animalTimeout; // Seconds before animal disappears

  const LevelConfig({
    required this.levelNumber,
    required this.duration,
    required this.initialSpawnRate,
    required this.availableAnimals,
    this.maxAnimalsOnScreen = 1,
    this.animalTimeout = 5.0,
  });

  // Factory for Endless Mode
  factory LevelConfig.endless() {
    return const LevelConfig(
      levelNumber: -1, // Indicates Endless Mode
      duration: 0, // Infinite
      initialSpawnRate: 1.2,
      availableAnimals: AnimalType.values,
      maxAnimalsOnScreen: 2,
      animalTimeout: 4.0,
    );
  }

  static const List<LevelConfig> levels = [
    // Day 1 - Tutorial: Dogs & Cats only, slow pace, generous timeout
    LevelConfig(
      levelNumber: 1,
      duration: 45,
      initialSpawnRate: 2.0,
      availableAnimals: [AnimalType.dog, AnimalType.cat],
      maxAnimalsOnScreen: 1,
      animalTimeout: 6.0,
    ),
    // Day 2 - Getting faster
    LevelConfig(
      levelNumber: 2,
      duration: 50,
      initialSpawnRate: 1.8,
      availableAnimals: [AnimalType.dog, AnimalType.cat],
      maxAnimalsOnScreen: 1,
      animalTimeout: 5.5,
    ),
    // Day 3 - Fast pace with 2 animals
    LevelConfig(
      levelNumber: 3,
      duration: 55,
      initialSpawnRate: 1.5,
      availableAnimals: [AnimalType.dog, AnimalType.cat],
      maxAnimalsOnScreen: 1,
      animalTimeout: 5.0,
    ),
    // Day 4 - Raccoons introduced!
    LevelConfig(
      levelNumber: 4,
      duration: 50,
      initialSpawnRate: 1.6,
      availableAnimals: [AnimalType.dog, AnimalType.cat, AnimalType.raccoon],
      maxAnimalsOnScreen: 1,
      animalTimeout: 5.0,
    ),
    // Day 5 - Two animals on screen!
    LevelConfig(
      levelNumber: 5,
      duration: 55,
      initialSpawnRate: 1.4,
      availableAnimals: [AnimalType.dog, AnimalType.cat, AnimalType.raccoon],
      maxAnimalsOnScreen: 2,
      animalTimeout: 4.5,
    ),
    // Day 6 - Getting intense
    LevelConfig(
      levelNumber: 6,
      duration: 60,
      initialSpawnRate: 1.3,
      availableAnimals: [AnimalType.dog, AnimalType.cat, AnimalType.raccoon],
      maxAnimalsOnScreen: 2,
      animalTimeout: 4.5,
    ),
    // Day 7 - Very fast with 2 animals
    LevelConfig(
      levelNumber: 7,
      duration: 65,
      initialSpawnRate: 1.1,
      availableAnimals: [AnimalType.dog, AnimalType.cat, AnimalType.raccoon],
      maxAnimalsOnScreen: 2,
      animalTimeout: 4.0,
    ),
    // Day 8 - Skunks introduced!
    LevelConfig(
      levelNumber: 8,
      duration: 60,
      initialSpawnRate: 1.3,
      availableAnimals: [AnimalType.dog, AnimalType.cat, AnimalType.raccoon, AnimalType.skunk],
      maxAnimalsOnScreen: 2,
      animalTimeout: 4.0,
    ),
    // Day 9 - Three animals on screen!
    LevelConfig(
      levelNumber: 9,
      duration: 70,
      initialSpawnRate: 1.1,
      availableAnimals: [AnimalType.dog, AnimalType.cat, AnimalType.raccoon, AnimalType.skunk],
      maxAnimalsOnScreen: 3,
      animalTimeout: 3.5,
    ),
    // Day 10 - High intensity
    LevelConfig(
      levelNumber: 10,
      duration: 75,
      initialSpawnRate: 1.0,
      availableAnimals: [AnimalType.dog, AnimalType.cat, AnimalType.raccoon, AnimalType.skunk],
      maxAnimalsOnScreen: 3,
      animalTimeout: 3.5,
    ),
    // Day 11 - Expert level
    LevelConfig(
      levelNumber: 11,
      duration: 80,
      initialSpawnRate: 0.9,
      availableAnimals: [AnimalType.dog, AnimalType.cat, AnimalType.raccoon, AnimalType.skunk],
      maxAnimalsOnScreen: 3,
      animalTimeout: 3.0,
    ),
    // Day 12 - Final Challenge: Long and brutal
    LevelConfig(
      levelNumber: 12,
      duration: 90,
      initialSpawnRate: 0.8,
      availableAnimals: [AnimalType.dog, AnimalType.cat, AnimalType.raccoon, AnimalType.skunk],
      maxAnimalsOnScreen: 3,
      animalTimeout: 2.5,
    ),
  ];
}
