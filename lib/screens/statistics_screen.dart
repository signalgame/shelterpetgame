import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late int totalAnimals;
  late int totalDogs;
  late int totalCats;
  late int totalWild;
  late int completedLevels;
  late int endlessBestScore;
  late double endlessBestTime;
  late int totalCampaignScore;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    final storage = StorageService.instance;
    totalAnimals = storage.getTotalAnimalsSorted();
    totalDogs = storage.getTotalDogsSorted();
    totalCats = storage.getTotalCatsSorted();
    totalWild = storage.getTotalWildSorted();
    endlessBestScore = storage.getEndlessBestScore();
    endlessBestTime = storage.getEndlessBestTime();

    completedLevels = 0;
    totalCampaignScore = 0;
    for (int i = 1; i <= 12; i++) {
      final score = storage.getBestScoreForLevel(i);
      if (score > 0) {
        completedLevels++;
        totalCampaignScore += score;
      }
    }
  }

  String _formatTime(double seconds) {
    final int mins = seconds ~/ 60;
    final int secs = (seconds % 60).toInt();
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
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
              FlameAudio.play('sfx_button.mp3', volume: 0.3);
            }
            Navigator.pop(context);
          },
        ),
        title: Text('STATISTICS', style: AppTheme.headerStyle),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildStatCard('Total Animals Sorted', '$totalAnimals'),
            _buildStatCard('Dogs Sorted', '$totalDogs', icon: Icons.pets),
            _buildStatCard('Cats Sorted', '$totalCats', icon: Icons.pets),
            _buildStatCard('Wild Animals Kicked', '$totalWild', icon: Icons.do_not_disturb),
            const Divider(thickness: 2, color: AppTheme.darkText, height: 32),
            _buildStatCard('Levels Completed', '$completedLevels/12'),
            _buildStatCard('Total Campaign Score', '$totalCampaignScore'),
            _buildStatCard('Endless Best Score', '$endlessBestScore'),
            _buildStatCard('Endless Best Time', _formatTime(endlessBestTime)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, {IconData? icon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkText.withValues(alpha: 0.5), width: 1),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppTheme.primaryButton, size: 28),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Text(
              label,
              style: AppTheme.bodyTextStyle.copyWith(fontSize: 16),
            ),
          ),
          Text(
            value,
            style: AppTheme.headerStyle.copyWith(
              fontSize: 20,
              color: AppTheme.darkText,
            ),
          ),
        ],
      ),
    );
  }
}
