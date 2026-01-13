import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import '../models/level_config.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'game_screen.dart';
import 'level_select_screen.dart';
import 'statistics_screen.dart';
import 'privacy_policy_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  bool isEndlessUnlocked = false;
  int endlessHighScore = 0;
  bool isSoundOn = true;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  void _loadState() {
    setState(() {
      isEndlessUnlocked = StorageService.instance.isEndlessModeUnlocked();
      endlessHighScore = StorageService.instance.getEndlessBestScore();
      isSoundOn = StorageService.instance.getSoundEnabled();
    });
  }

  void _toggleSound() {
    setState(() {
      isSoundOn = !isSoundOn;
      StorageService.instance.setSoundEnabled(isSoundOn);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Responsive sizing
    final logoWidth = (screenWidth * 0.7).clamp(200.0, 320.0);
    final buttonWidth = (screenWidth * 0.65).clamp(180.0, 280.0);
    final buttonHeight = (screenHeight * 0.07).clamp(50.0, 65.0);
    final iconButtonSize = (screenWidth * 0.15).clamp(50.0, 70.0);
    final spacing = (screenHeight * 0.02).clamp(12.0, 20.0);
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/backgrounds/bg_menu.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Sound Toggle (Top Right)
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  icon: Icon(
                    isSoundOn ? Icons.volume_up : Icons.volume_off, 
                    size: 32, 
                    color: AppTheme.white
                  ),
                  onPressed: _toggleSound,
                ),
              ),
              
              // Main content - scrollable and centered
              Positioned.fill(
                top: 50, // Leave space for sound toggle
                bottom: 50, // Leave space for privacy policy
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: spacing, horizontal: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo
                          Image.asset(
                            'assets/images/ui/logo.png',
                            width: logoWidth,
                            errorBuilder: (context, error, stackTrace) => Text(
                              'Pet Shelter Rush',
                              style: AppTheme.titleStyle.copyWith(
                                fontSize: (screenWidth * 0.08).clamp(28.0, 44.0),
                              ),
                            ),
                          ),
                          SizedBox(height: spacing * 1.5),

                          // Play Button
                          _buildMenuButton(
                            context,
                            label: 'PLAY',
                            width: buttonWidth,
                            height: buttonHeight,
                            onPressed: () {
                              if (isSoundOn) FlameAudio.play('sfx_button.mp3');
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const LevelSelectScreen()),
                              ).then((_) => _loadState());
                            },
                            primary: true,
                          ),
                          SizedBox(height: spacing),

                          // Endless Mode
                          _buildMenuButton(
                            context,
                            label: 'ENDLESS MODE',
                            width: buttonWidth,
                            height: buttonHeight,
                            onPressed: isEndlessUnlocked ? () {
                              if (isSoundOn) FlameAudio.play('sfx_button.mp3');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GameScreen(levelConfig: LevelConfig.endless()),
                                ),
                              ).then((_) => _loadState());
                            } : null,
                            icon: isEndlessUnlocked ? null : Icons.lock,
                          ),
                          SizedBox(height: spacing),

                          // Row for Stats and How to Play
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildIconButton(
                                context,
                                icon: Icons.bar_chart,
                                size: iconButtonSize,
                                onPressed: () {
                                   if (isSoundOn) FlameAudio.play('sfx_button.mp3');
                                   Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const StatisticsScreen()),
                                  );
                                },
                              ),
                              SizedBox(width: spacing),
                              _buildIconButton(
                                context,
                                icon: Icons.help_outline,
                                size: iconButtonSize,
                                onPressed: () {
                                  if (isSoundOn) FlameAudio.play('sfx_button.mp3');
                                  _showHowToPlay(context);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // High Score (Endless)
              if (isEndlessUnlocked)
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ENDLESS BEST', style: AppTheme.bodyTextStyle.copyWith(fontSize: 12)),
                        Text('$endlessHighScore', style: AppTheme.headerStyle.copyWith(fontSize: 20)),
                      ],
                    ),
                  ),
                ),

              // Privacy Policy (Bottom)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: TextButton(
                    onPressed: () {
                       if (isSoundOn) FlameAudio.play('sfx_button.mp3');
                       Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
                      );
                    },
                    child: Text(
                      'Privacy Policy',
                      style: AppTheme.bodyTextStyle.copyWith(
                        decoration: TextDecoration.underline,
                        decorationColor: AppTheme.white,
                        fontSize: 14,
                        color: AppTheme.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, {
    required String label,
    required double width,
    required double height,
    VoidCallback? onPressed,
    bool primary = false,
    IconData? icon,
  }) {
    final fontSize = (height * 0.35).clamp(16.0, 22.0);
    
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary ? AppTheme.primaryButton : AppTheme.secondaryButton,
          foregroundColor: AppTheme.white,
          disabledBackgroundColor: Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppTheme.darkText, width: 2),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: fontSize),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                label,
                style: AppTheme.buttonTextStyle.copyWith(fontSize: fontSize),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(BuildContext context, {
    required IconData icon,
    required double size,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.secondaryButton,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkText, width: 2),
      ),
      child: IconButton(
        icon: Icon(icon, color: AppTheme.white, size: size * 0.5),
        onPressed: onPressed,
      ),
    );
  }

  void _showHowToPlay(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = (screenWidth * 0.85).clamp(280.0, 400.0);
    final iconSize = (dialogWidth * 0.1).clamp(30.0, 50.0);
    final headerSize = (dialogWidth * 0.08).clamp(24.0, 32.0);
    final bodySize = (dialogWidth * 0.045).clamp(14.0, 18.0);
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: dialogWidth,
          padding: EdgeInsets.all(dialogWidth * 0.06),
          decoration: BoxDecoration(
            color: AppTheme.creamWhite,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.darkText, width: 4),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('HOW TO PLAY', style: AppTheme.headerStyle.copyWith(fontSize: headerSize)),
              SizedBox(height: dialogWidth * 0.04),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTutorialStep('Dog', Icons.arrow_back, iconSize, bodySize),
                  _buildTutorialStep('Wild', Icons.arrow_downward, iconSize, bodySize),
                  _buildTutorialStep('Cat', Icons.arrow_forward, iconSize, bodySize),
                ],
              ),
              SizedBox(height: dialogWidth * 0.04),
              Text(
                'Swipe Dogs LEFT, Cats RIGHT,\nand Wild Animals DOWN!',
                textAlign: TextAlign.center,
                style: AppTheme.bodyTextStyle.copyWith(fontSize: bodySize),
              ),
              SizedBox(height: dialogWidth * 0.06),
              ElevatedButton(
                onPressed: () {
                   if (isSoundOn) FlameAudio.play('sfx_button.mp3');
                   Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryButton,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: dialogWidth * 0.08, vertical: 12),
                  child: Text('GOT IT!', style: AppTheme.buttonTextStyle.copyWith(fontSize: bodySize + 2)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTutorialStep(String label, IconData icon, double iconSize, double textSize) {
    return Column(
      children: [
        Icon(icon, size: iconSize, color: AppTheme.darkText),
        const SizedBox(height: 4),
        Text(label, style: AppTheme.bodyTextStyle.copyWith(fontSize: textSize)),
      ],
    );
  }
}
