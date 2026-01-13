import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
              FlameAudio.play('sfx_button.mp3', volume: 0.3);
            }
            Navigator.pop(context);
          },
        ),
        title: Text('PRIVACY POLICY', style: AppTheme.headerStyle),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pet Shelter Rush is an offline game.',
              style: AppTheme.bodyTextStyle.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'We do not collect, store, or share any personal data. '
              'All game progress and settings are stored locally on your device.',
              style: AppTheme.bodyTextStyle,
            ),
            const SizedBox(height: 16),
            Text(
              'If you uninstall the app, your saved progress may be lost.',
              style: AppTheme.bodyTextStyle,
            ),
             const SizedBox(height: 32),
             Center(
               child: Image.asset(
                 'assets/images/ui/logo.png',
                 width: 100,
                 errorBuilder: (ctx, err, stack) => const Icon(Icons.pets, size: 60, color: AppTheme.primaryButton),
               ),
             ),
          ],
        ),
      ),
    );
  }
}
