import 'package:flame/flame.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'main_menu_screen.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initGame();
  }

  Future<void> _initGame() async {
    // Load Audio
    await FlameAudio.audioCache.loadAll([
      'music_gameplay.mp3',
      'sfx_bark.mp3',
      'sfx_meow.mp3',
      'sfx_wild_exit.mp3',
      'sfx_wrong.mp3',
      'sfx_button.mp3',
      'sfx_level_complete.mp3',
      'sfx_game_over.mp3',
      'sfx_unlock.mp3',
    ]);

    // Load Images
    await Flame.images.loadAll([
      'backgrounds/bg_gameplay.png',
      'backgrounds/bg_menu.png',
      'characters/dog.png',
      'characters/cat.png',
      'characters/raccoon.png',
      'characters/skunk.png',
      'effects/dust_cloud.png',
      'ui/heart.png',
      'ui/logo.png',
    ]);
    
    // Wait for minimum time
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MainMenuScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamWhite,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/ui/logo.png',
              width: 250,
              errorBuilder: (context, error, stackTrace) {
                return Text(
                  'PET SHELTER RUSH',
                  style: AppTheme.titleStyle.copyWith(
                    color: AppTheme.primaryButton,
                    fontSize: 32,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              color: AppTheme.primaryButton,
            ),
          ],
        ),
      ),
    );
  }
}
