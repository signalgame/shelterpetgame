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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isLandscape = screenWidth > screenHeight;
    
    // Responsive grid: 6 columns in landscape, 4 in portrait
    final crossAxisCount = isLandscape ? 6 : 4;
    final spacing = isLandscape ? 10.0 : 12.0;
    final padding = isLandscape ? 12.0 : 16.0;
    
    return Scaffold(
      backgroundColor: AppTheme.creamWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: isLandscape ? 48 : 56,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.darkText, size: isLandscape ? 24 : 28),
          onPressed: () {
            if (StorageService.instance.getSoundEnabled()) {
              FlameAudio.play('sfx_button.mp3', volume: 0.3);
            }
            Navigator.pop(context);
          },
        ),
        title: Text('SELECT DAY', style: AppTheme.headerStyle.copyWith(fontSize: isLandscape ? 24 : 32)),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: isLandscape ? 1.0 : 0.9,
          ),
          itemCount: 12,
          itemBuilder: (context, index) {
            final int level = index + 1;
            final bool isUnlocked = level <= highestUnlocked; 
            final int score = StorageService.instance.getBestScoreForLevel(level);
            final bool isCompleted = score > 0;

            return _buildLevelButton(context, level, isUnlocked, isCompleted, score, isLandscape);
          },
        ),
      ),
    );
  }

  Widget _buildLevelButton(BuildContext context, int level, bool isUnlocked, bool isCompleted, int score, bool isLandscape) {
    // Responsive sizes for landscape
    final dayFontSize = isLandscape ? 10.0 : 14.0;
    final levelFontSize = isLandscape ? 22.0 : 32.0;
    final scoreFontSize = isLandscape ? 9.0 : 12.0;
    final starSize = isLandscape ? 12.0 : 16.0;
    final lockSize = isLandscape ? 28.0 : 40.0;
    final checkSize = isLandscape ? 14.0 : 20.0;
    final borderRadius = isLandscape ? 10.0 : 16.0;
    
    return GestureDetector(
      onTap: isUnlocked
          ? () {
              if (StorageService.instance.getSoundEnabled()) {
                FlameAudio.play('sfx_button.mp3', volume: 0.3);
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
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: AppTheme.darkText, width: isLandscape ? 1.5 : 2),
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
                      fontSize: dayFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$level',
                    style: AppTheme.headerStyle.copyWith(
                      color: AppTheme.white,
                      fontSize: levelFontSize,
                    ),
                  ),
                   if (isCompleted) ...[
                    SizedBox(height: isLandscape ? 2 : 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, color: AppTheme.successGold, size: starSize),
                        SizedBox(width: isLandscape ? 2 : 4),
                        Text(
                          '$score',
                          style: AppTheme.bodyTextStyle.copyWith(
                            color: AppTheme.white,
                            fontSize: scoreFontSize,
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
                  borderRadius: BorderRadius.circular(borderRadius - 2),
                ),
                child: Center(
                  child: Icon(Icons.lock, color: Colors.white, size: lockSize),
                ),
              ),
            if (isCompleted)
              Positioned(
                top: isLandscape ? 4 : 8,
                right: isLandscape ? 4 : 8,
                child: Container(
                  padding: EdgeInsets.all(isLandscape ? 1 : 2),
                  decoration: const BoxDecoration(
                    color: AppTheme.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_circle, color: AppTheme.successGold, size: checkSize),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
