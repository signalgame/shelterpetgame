import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import '../game/pet_shelter_rush_game.dart';
import '../models/level_config.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'main_menu_screen.dart';
import 'level_select_screen.dart';

class GameScreen extends StatefulWidget {
  final LevelConfig levelConfig;

  const GameScreen({super.key, required this.levelConfig});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Local state for Sound Toggle
  late bool isSoundOn;

  @override
  void initState() {
    super.initState();
    isSoundOn = StorageService.instance.getSoundEnabled();
  }

  void _toggleSound() {
    setState(() {
      isSoundOn = !isSoundOn;
      StorageService.instance.setSoundEnabled(isSoundOn);
      if (isSoundOn) {
         FlameAudio.bgm.resume();
      } else {
         FlameAudio.bgm.pause();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget<PetShelterRushGame>.controlled(
        gameFactory: () => PetShelterRushGame(levelConfig: widget.levelConfig),
        overlayBuilderMap: {
          'HUD': (context, game) => _buildHUD(context, game),
          'PauseMenu': (context, game) => _buildPauseMenu(context, game),
          'GameOver': (context, game) => _buildGameOverMenu(context, game),
          'LevelComplete': (context, game) => _buildLevelCompleteMenu(context, game),
        },
      ),
    );
  }

  Widget _buildHUD(BuildContext context, PetShelterRushGame game) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Top Row: Pause, Level, Timer, Score
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Pause Button
                IconButton(
                  icon: const Icon(Icons.pause, size: 36, color: AppTheme.darkText),
                  onPressed: () {
                     if (isSoundOn) FlameAudio.play('sfx_button.mp3', volume: 0.3);
                     game.pauseGame();
                  },
                ),
                
                // Level Indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryButton,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.darkText, width: 2),
                  ),
                  child: Text(
                    game.isEndless ? 'Endless' : 'Day ${widget.levelConfig.levelNumber}',
                    style: AppTheme.buttonTextStyle.copyWith(fontSize: 18),
                  ),
                ),

                // Timer
                ValueListenableBuilder<double>(
                  valueListenable: game.timeNotifier,
                  builder: (context, value, child) {
                    final int seconds = game.isEndless ? value.floor() : value.ceil();
                    final int mins = seconds ~/ 60;
                    final int secs = seconds % 60;
                    final bool isWarning = !game.isEndless && value <= 10;
                    
                    return Text(
                      '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}',
                      style: AppTheme.timerStyle.copyWith(
                        color: isWarning ? AppTheme.errorDanger : AppTheme.darkText,
                        fontSize: 28,
                      ),
                    );
                  },
                ),

                // Score
                ValueListenableBuilder<int>(
                  valueListenable: game.scoreNotifier,
                  builder: (context, value, child) {
                    return Text(
                      'Score: $value',
                      style: AppTheme.headerStyle.copyWith(fontSize: 24),
                    );
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Lives (Hearts)
            Row(
              children: [
                 ValueListenableBuilder<int>(
                  valueListenable: game.livesNotifier,
                  builder: (context, lives, child) {
                    return Row(
                      children: List.generate(3, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Icon(
                            Icons.favorite,
                            color: index < lives ? AppTheme.errorDanger : Colors.grey,
                            size: 32,
                          ),
                        );
                      }),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlayContainer({required Widget child, bool scrollable = false}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = constraints.maxHeight;
        final screenWidth = constraints.maxWidth;
        final isLandscape = screenWidth > screenHeight;
        
        // Responsive sizing for landscape
        final containerWidth = isLandscape 
            ? (screenWidth * 0.35).clamp(280.0, 360.0)
            : (screenWidth * 0.85).clamp(280.0, 320.0);
        final containerPadding = isLandscape ? 16.0 : 24.0;
        final maxHeight = isLandscape ? screenHeight * 0.85 : screenHeight * 0.7;
        
        Widget content = child;
        
        if (scrollable) {
          content = SingleChildScrollView(
            child: child,
          );
        }
        
        return Center(
          child: Container(
            width: containerWidth,
            constraints: BoxConstraints(maxHeight: maxHeight),
            padding: EdgeInsets.all(containerPadding),
            decoration: BoxDecoration(
              color: AppTheme.creamWhite,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.darkText, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(4, 4),
                ),
              ],
            ),
            child: content,
          ),
        );
      },
    );
  }

  Widget _buildPauseMenu(BuildContext context, PetShelterRushGame game) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.5),
      child: _buildOverlayContainer(
        scrollable: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('PAUSED', style: AppTheme.headerStyle.copyWith(fontSize: 28)),
            const SizedBox(height: 16),
            _buildOverlayButton(
              context,
              label: 'RESUME',
              onPressed: () {
                if (isSoundOn) FlameAudio.play('sfx_button.mp3', volume: 0.3);
                game.resumeEngine();
                if (isSoundOn) FlameAudio.bgm.resume(); 
                game.overlays.remove('PauseMenu');
              },
              primary: true,
            ),
            const SizedBox(height: 12),
            _buildOverlayButton(
              context,
              label: 'RESTART',
              onPressed: () {
                if (isSoundOn) FlameAudio.play('sfx_button.mp3', volume: 0.3);
                game.restartLevel();
              },
            ),
            const SizedBox(height: 12),
            // Sound Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Sound: ', style: AppTheme.bodyTextStyle),
                Switch(
                  value: isSoundOn,
                  onChanged: (val) {
                    _toggleSound();
                  },
                  activeTrackColor: AppTheme.primaryButton,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildOverlayButton(
              context,
              label: 'LEVEL SELECT',
              onPressed: () {
                if (isSoundOn) FlameAudio.play('sfx_button.mp3', volume: 0.3);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LevelSelectScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOverMenu(BuildContext context, PetShelterRushGame game) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.5),
      child: _buildOverlayContainer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('GAME OVER', style: AppTheme.headerStyle.copyWith(color: AppTheme.errorDanger)),
            const SizedBox(height: 16),
            Text('Score: ${game.score}', style: AppTheme.titleStyle),
            const SizedBox(height: 24),
            _buildOverlayButton(
              context,
              label: 'RETRY',
              onPressed: () {
                 if (isSoundOn) FlameAudio.play('sfx_button.mp3', volume: 0.3);
                 game.restartLevel();
              },
              primary: true,
            ),
            const SizedBox(height: 16),
            _buildOverlayButton(
              context,
              label: 'MAIN MENU',
              onPressed: () {
                if (isSoundOn) FlameAudio.play('sfx_button.mp3', volume: 0.3);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const MainMenuScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelCompleteMenu(BuildContext context, PetShelterRushGame game) {
    final bool hasNextLevel = widget.levelConfig.levelNumber < 12;

    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.5),
      child: _buildOverlayContainer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('LEVEL COMPLETE!', style: AppTheme.headerStyle.copyWith(color: AppTheme.primaryButton)),
            const SizedBox(height: 16),
            Text('Score: ${game.score}', style: AppTheme.titleStyle),
            const SizedBox(height: 8),
            // We could check if it's a new best score here, but for now we just show it.
            // Ideally we'd pass that info from the game.
            
            const SizedBox(height: 24),
            if (hasNextLevel) ...[
              _buildOverlayButton(
                context,
                label: 'NEXT LEVEL',
                onPressed: () {
                  if (isSoundOn) FlameAudio.play('sfx_button.mp3', volume: 0.3);
                  // Load next level
                  final nextLevelConfig = LevelConfig.levels.firstWhere(
                    (l) => l.levelNumber == widget.levelConfig.levelNumber + 1
                  );
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => GameScreen(levelConfig: nextLevelConfig),
                    ),
                  );
                },
                primary: true,
              ),
              const SizedBox(height: 16),
            ],
            _buildOverlayButton(
              context,
              label: 'LEVEL SELECT',
              onPressed: () {
                 if (isSoundOn) FlameAudio.play('sfx_button.mp3', volume: 0.3);
                 Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LevelSelectScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlayButton(BuildContext context, {required String label, required VoidCallback onPressed, bool primary = false}) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary ? AppTheme.primaryButton : AppTheme.secondaryButton,
          foregroundColor: AppTheme.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppTheme.darkText, width: 2),
          ),
        ),
        child: Text(label, style: AppTheme.buttonTextStyle.copyWith(fontSize: 18)),
      ),
    );
  }
}
