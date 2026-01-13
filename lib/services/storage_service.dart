import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyHighestLevelUnlocked = 'highest_level_unlocked';
  static const String _keyBestScoreLevelPrefix = 'best_score_level_';
  static const String _keyEndlessBestScore = 'endless_best_score';
  static const String _keyEndlessBestTime = 'endless_best_time';
  
  static const String _keyTotalAnimalsSorted = 'total_animals_sorted';
  static const String _keyTotalDogsSorted = 'total_dogs_sorted';
  static const String _keyTotalCatsSorted = 'total_cats_sorted';
  static const String _keyTotalWildSorted = 'total_wild_sorted';

  static const String _keySoundEnabled = 'sound_enabled';

  static final StorageService _instance = StorageService._internal();
  static StorageService get instance => _instance;

  StorageService._internal();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Levels
  int getHighestLevelUnlocked() {
    return _prefs.getInt(_keyHighestLevelUnlocked) ?? 1;
  }

  Future<void> saveHighestLevelUnlocked(int level) async {
    int current = getHighestLevelUnlocked();
    if (level > current) {
      await _prefs.setInt(_keyHighestLevelUnlocked, level);
    }
  }

  int getBestScoreForLevel(int level) {
    return _prefs.getInt('$_keyBestScoreLevelPrefix$level') ?? 0;
  }

  Future<void> saveBestScoreForLevel(int level, int score) async {
    int current = getBestScoreForLevel(level);
    if (score > current) {
      await _prefs.setInt('$_keyBestScoreLevelPrefix$level', score);
    }
  }

  // Endless Mode
  bool isEndlessModeUnlocked() {
    // Endless mode is unlocked after completing all 12 levels
    // When level 12 is completed, level 13 is saved as "unlocked"
    return getHighestLevelUnlocked() > 12;
  }
  
  int getEndlessBestScore() {
    return _prefs.getInt(_keyEndlessBestScore) ?? 0;
  }

  Future<void> saveEndlessBestScore(int score) async {
    int current = getEndlessBestScore();
    if (score > current) {
      await _prefs.setInt(_keyEndlessBestScore, score);
    }
  }

  double getEndlessBestTime() {
    return _prefs.getDouble(_keyEndlessBestTime) ?? 0.0;
  }

  Future<void> saveEndlessBestTime(double time) async {
    double current = getEndlessBestTime();
    if (time > current) {
      await _prefs.setDouble(_keyEndlessBestTime, time);
    }
  }

  // Statistics
  int getTotalAnimalsSorted() => _prefs.getInt(_keyTotalAnimalsSorted) ?? 0;
  int getTotalDogsSorted() => _prefs.getInt(_keyTotalDogsSorted) ?? 0;
  int getTotalCatsSorted() => _prefs.getInt(_keyTotalCatsSorted) ?? 0;
  int getTotalWildSorted() => _prefs.getInt(_keyTotalWildSorted) ?? 0;

  Future<void> incrementStats({
    int animals = 0,
    int dogs = 0,
    int cats = 0,
    int wild = 0,
  }) async {
    if (animals > 0) await _prefs.setInt(_keyTotalAnimalsSorted, getTotalAnimalsSorted() + animals);
    if (dogs > 0) await _prefs.setInt(_keyTotalDogsSorted, getTotalDogsSorted() + dogs);
    if (cats > 0) await _prefs.setInt(_keyTotalCatsSorted, getTotalCatsSorted() + cats);
    if (wild > 0) await _prefs.setInt(_keyTotalWildSorted, getTotalWildSorted() + wild);
  }

  // Sound
  bool getSoundEnabled() {
    return _prefs.getBool(_keySoundEnabled) ?? true;
  }

  Future<void> setSoundEnabled(bool enabled) async {
    await _prefs.setBool(_keySoundEnabled, enabled);
  }
}

