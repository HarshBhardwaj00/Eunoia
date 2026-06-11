import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/journal_repository.dart';
import '../../services/ai_analysis_service.dart';
import '../../data/models/mood_log_model.dart';
import '../../theme/premium_design_system.dart';
import '../../widgets/premium_card.dart';
import '../../widgets/premium_button.dart';

// Mood logging screen - captures daily mood, sleep, and journal entries
class MoodLoggerScreen extends StatefulWidget {
  const MoodLoggerScreen({super.key});

  @override
  State<MoodLoggerScreen> createState() => _MoodLoggerScreenState();
}

class _MoodLoggerScreenState extends State<MoodLoggerScreen> {
  int _selectedMood = 3;
  double _sleepHours = 7.0;
  final TextEditingController _notesController = TextEditingController();
  bool _isSaving = false;

  late final JournalRepository _repository;

  final List<MoodOption> _moodOptions = [
    MoodOption(emoji: '😢', label: 'Terrible', value: 1),
    MoodOption(emoji: '😔', label: 'Bad', value: 2),
    MoodOption(emoji: '😐', label: 'Okay', value: 3),
    MoodOption(emoji: '🙂', label: 'Good', value: 4),
    MoodOption(emoji: '😊', label: 'Great', value: 5),
  ];

  @override
  void initState() {
    super.initState();
    _repository = JournalRepository(FirebaseFirestore.instance);
    _repository.initialize();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _saveLog() async {
    if (_notesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add some journal notes')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Show loading indicator for AI analysis
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AI is analyzing your entry...')),
        );
      }

      // Call AI analysis service
      final aiService = AIAnalysisService();
      final analysis = await aiService.analyzeJournal(
        _notesController.text.trim(),
      );

      // Create mood log with AI analysis results
      final moodLog = MoodLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        encryptedTitle: 'Mood: $_selectedMood',
        encryptedContent: _notesController.text.trim(),
        timestamp: DateTime.now(),
        sentiment: analysis['sentiment'] as String?,
        detectedEmotion: analysis['detectedEmotion'] as String?,
        summary: analysis['summary'] as String?,
      );

      await _repository.saveMoodLog(moodLog);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Log saved successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save log: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Daily Mood Log',
          style: PremiumDesignSystem.headline.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How are you feeling today?',
                style: PremiumDesignSystem.displayMedium.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 24),
              _buildMoodSelector(context),
              const SizedBox(height: 32),
              _buildSleepSlider(context),
              const SizedBox(height: 32),
              _buildJournalNotes(context),
              const SizedBox(height: 32),
              _buildSaveButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodSelector(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mood',
          style: PremiumDesignSystem.label.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _moodOptions.map((mood) {
              final isSelected = _selectedMood == mood.value;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMood = mood.value;
                  });
                },
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary.withOpacity(0.1)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline.withOpacity(0.3),
                          width: PremiumDesignSystem.borderWidth,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withOpacity(
                                    0.2,
                                  ),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        mood.emoji,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      mood.label,
                      style: PremiumDesignSystem.bodySmall.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSleepSlider(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Sleep Hours',
              style: PremiumDesignSystem.label.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  width: PremiumDesignSystem.borderWidth,
                ),
              ),
              child: Text(
                '${_sleepHours.toStringAsFixed(1)}h',
                style: PremiumDesignSystem.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            activeTrackColor: theme.colorScheme.primary,
            inactiveTrackColor: theme.colorScheme.outline.withOpacity(0.3),
            thumbColor: theme.colorScheme.primary,
            overlayColor: theme.colorScheme.primary.withOpacity(0.2),
            valueIndicatorColor: theme.colorScheme.primary,
            valueIndicatorTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: Slider(
            value: _sleepHours,
            min: 1,
            max: 12,
            divisions: 22,
            label: '${_sleepHours.toStringAsFixed(1)}h',
            onChanged: (value) {
              setState(() {
                _sleepHours = value;
              });
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '1h',
              style: PremiumDesignSystem.bodySmall.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            Text(
              '12h',
              style: PremiumDesignSystem.bodySmall.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildJournalNotes(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Journal Notes',
          style: PremiumDesignSystem.label.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        PremiumCard(
          padding: EdgeInsets.zero,
          child: TextField(
            controller: _notesController,
            maxLines: 5,
            style: PremiumDesignSystem.bodyLarge.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: 'How are you feeling? What\'s on your mind?',
              hintStyle: PremiumDesignSystem.bodyLarge.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return PremiumButton(
      label: 'Save Log',
      onPressed: _isSaving ? null : _saveLog,
      isLoading: _isSaving,
    );
  }
}

class MoodOption {
  final String emoji;
  final String label;
  final int value;

  MoodOption({required this.emoji, required this.label, required this.value});
}
