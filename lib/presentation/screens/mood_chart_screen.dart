import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/journal_repository.dart';
import '../../data/models/mood_log_model.dart';
import '../../theme/premium_design_system.dart';
import '../../widgets/premium_card.dart';

// Mood trends visualization screen - displays historical mood data charts
class MoodChartScreen extends StatefulWidget {
  const MoodChartScreen({super.key});

  @override
  State<MoodChartScreen> createState() => _MoodChartScreenState();
}

class _MoodChartScreenState extends State<MoodChartScreen> {
  late final JournalRepository _repository;
  List<MoodLog> _moodLogs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repository = JournalRepository(FirebaseFirestore.instance);
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await _repository.initialize();
      final logs = _repository.getLocalMoodLogs();
      setState(() {
        _moodLogs = logs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  int _extractMoodScore(String encryptedTitle) {
    // Parse mood score from encryptedTitle format "Mood: X"
    final regex = RegExp(r'Mood:\s*(\d+)');
    final match = regex.firstMatch(encryptedTitle);
    if (match != null) {
      return int.parse(match.group(1) ?? '3');
    }
    return 3; // Default to middle value
  }

  List<FlSpot> _getMoodSpots() {
    if (_moodLogs.isEmpty) return [];

    // Sort logs by timestamp
    final sortedLogs = List<MoodLog>.from(_moodLogs)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Take last 30 entries for better visualization
    final recentLogs = sortedLogs.take(30).toList();

    return recentLogs.asMap().entries.map((entry) {
      final index = entry.key;
      final log = entry.value;
      final moodScore = _extractMoodScore(log.encryptedTitle);
      return FlSpot(index.toDouble(), moodScore.toDouble());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Mood Trends',
          style: PremiumDesignSystem.headline.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                ),
              )
            : _moodLogs.isEmpty
            ? _buildEmptyView(context)
            : _buildChart(context),
      ),
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No mood data yet',
            style: PremiumDesignSystem.bodyMedium.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Log your mood to see trends',
            style: PremiumDesignSystem.bodySmall.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    final theme = Theme.of(context);
    final spots = _getMoodSpots();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PremiumCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mood Over Time',
                    style: PremiumDesignSystem.headline.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Recent mood entries (1-5 scale)',
                    style: PremiumDesignSystem.bodyMedium.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Y-axis label
                      RotatedBox(
                        quarterTurns: 3,
                        child: Text(
                          'Mood Level',
                          style: PremiumDesignSystem.bodySmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Chart
                      Expanded(
                        child: SizedBox(
                          height: 300,
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: 1,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: theme.colorScheme.outline
                                        .withOpacity(0.3),
                                    strokeWidth: 1,
                                  );
                                },
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, meta) {
                                      if (value.toInt() % 5 == 0 &&
                                          value.toInt() < spots.length) {
                                        return Text(
                                          '${value.toInt() + 1}',
                                          style: PremiumDesignSystem.bodySmall
                                              .copyWith(
                                                color: theme
                                                    .colorScheme
                                                    .onSurface
                                                    .withOpacity(0.6),
                                              ),
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, meta) {
                                      if (value >= 1 &&
                                          value <= 5 &&
                                          value == value.toInt()) {
                                        final moodLabels = {
                                          1: '😢',
                                          2: '😔',
                                          3: '😐',
                                          4: '🙂',
                                          5: '😊',
                                        };
                                        return Text(
                                          moodLabels[value.toInt()] ?? '',
                                          style: const TextStyle(fontSize: 16),
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border: Border.all(
                                  color: theme.colorScheme.outline.withOpacity(
                                    0.3,
                                  ),
                                ),
                              ),
                              minX: 0,
                              maxX: (spots.length - 1).toDouble().clamp(
                                0,
                                double.infinity,
                              ),
                              minY: 0,
                              maxY: 6,
                              lineBarsData: [
                                LineChartBarData(
                                  spots: spots,
                                  isCurved: true,
                                  gradient: LinearGradient(
                                    colors: [
                                      theme.colorScheme.primary.withOpacity(
                                        0.8,
                                      ),
                                      theme.colorScheme.primary.withOpacity(
                                        0.4,
                                      ),
                                    ],
                                  ),
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter:
                                        (spot, percent, barData, index) {
                                          return FlDotCirclePainter(
                                            radius: 4,
                                            color: theme.colorScheme.primary,
                                            strokeWidth: 2,
                                            strokeColor:
                                                theme.colorScheme.surface,
                                          );
                                        },
                                  ),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient(
                                      colors: [
                                        theme.colorScheme.primary.withOpacity(
                                          0.3,
                                        ),
                                        theme.colorScheme.primary.withOpacity(
                                          0.1,
                                        ),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // X-axis label
                      Text(
                        'Entry #',
                        style: PremiumDesignSystem.bodySmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildMoodLegend(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodLegend(BuildContext context) {
    final theme = Theme.of(context);

    return PremiumCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mood Scale',
              style: PremiumDesignSystem.label.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(child: _buildLegendItem(context, '😢', 'Terrible', 1)),
                Expanded(child: _buildLegendItem(context, '😔', 'Bad', 2)),
                Expanded(child: _buildLegendItem(context, '😐', 'Okay', 3)),
                Expanded(child: _buildLegendItem(context, '🙂', 'Good', 4)),
                Expanded(child: _buildLegendItem(context, '😊', 'Great', 5)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    String emoji,
    String label,
    int value,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.0,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
