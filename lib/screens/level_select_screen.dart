import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import '../models/level_config.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'game_screen.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  late int highestUnlocked;

  @override
  void initState() {
    super.initState();
    highestUnlocked = StorageService.instance.getHighestLevelUnlocked();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.darkText),
          onPressed: () {
            if (StorageService.instance.getSoundEnabled()) {
              FlameAudio.play('sfx_button.mp3');
            }
            Navigator.pop(context);
          },
        ),
        title: Text('SELECT DAY', style: AppTheme.headerStyle),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: 12,
          itemBuilder: (context, index) {
            final int level = index + 1;
            final bool isUnlocked = level <= highestUnlocked; 
            final int score = StorageService.instance.getBestScoreForLevel(level);
            final bool isCompleted = score > 0;

            return _buildLevelButton(context, level, isUnlocked, isCompleted, score);
          },
        ),
      ),
    );
  }

  Widget _buildLevelButton(BuildContext context, int level, bool isUnlocked, bool isCompleted, int score) {
    return GestureDetector(
      onTap: isUnlocked
          ? () {
              if (StorageService.instance.getSoundEnabled()) {
                FlameAudio.play('sfx_button.mp3');
              }
              final config = LevelConfig.levels.firstWhere((l) => l.levelNumber == level);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => GameScreen(levelConfig: config)),
              );
            }
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: isUnlocked ? AppTheme.secondaryButton : Colors.grey[400],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.darkText, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppTheme.darkText.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'DAY',
                    style: AppTheme.bodyTextStyle.copyWith(
                      color: AppTheme.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$level',
                    style: AppTheme.headerStyle.copyWith(
                      color: AppTheme.white,
                      fontSize: 32,
                    ),
                  ),
                   if (isCompleted) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, color: AppTheme.successGold, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '$score',
                          style: AppTheme.bodyTextStyle.copyWith(
                            color: AppTheme.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (!isUnlocked)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Icon(Icons.lock, color: Colors.white, size: 40),
                ),
              ),
            if (isCompleted)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: AppTheme.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle, color: AppTheme.successGold, size: 20),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
