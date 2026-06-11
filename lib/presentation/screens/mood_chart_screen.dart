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

    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 6));

    // Filter logs from the past 7 days
    final recentLogs = _moodLogs.where((log) {
      return log.timestamp.isAfter(sevenDaysAgo) && 
             log.timestamp.isBefore(now.add(const Duration(days: 1)));
    }).toList();

    // Group entries by calendar date (ignoring time components)
    final Map<DateTime, List<int>> dailyScores = {};
    for (final log in recentLogs) {
      final date = DateTime(log.timestamp.year, log.timestamp.month, log.timestamp.day);
      final moodScore = _extractMoodScore(log.encryptedTitle);
      dailyScores.putIfAbsent(date, () => []).add(moodScore);
    }

    // Generate 7 chronological slots from 6 days ago to today
    final List<FlSpot> spots = [];
    for (int i = 0; i < 7; i++) {
      final targetDate = sevenDaysAgo.add(Duration(days: i));
      final dateKey = DateTime(targetDate.year, targetDate.month, targetDate.day);
      
      if (dailyScores.containsKey(dateKey) && dailyScores[dateKey]!.isNotEmpty) {
        final scores = dailyScores[dateKey]!;
        final averageScore = scores.reduce((a, b) => a + b) / scores.length;
        spots.add(FlSpot(i.toDouble(), averageScore));
      } else {
        // No data for this day, skip or use neutral value
        // Skip to avoid gaps in the line
      }
    }

    return spots;
  }

  DateTime _getDateForIndex(int index) {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 6));
    return sevenDaysAgo.add(Duration(days: index));
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
                  const SizedBox(height: 4),
                  Text(
                    'Last 7 Days',
                    style: PremiumDesignSystem.bodyMedium.copyWith(
                      color: theme.colorScheme.primary.withOpacity(0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
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
                                    reservedSize: 60,
                                    interval: 1,
                                    getTitlesWidget: (value, meta) {
                                      final index = value.toInt();
                                      if (index < 0 || index > 6) {
                                        return const Text('');
                                      }
                                      
                                      final date = _getDateForIndex(index);
                                      final now = DateTime.now();
                                      final isToday = date.year == now.year &&
                                          date.month == now.month &&
                                          date.day == now.day;
                                      
                                      final label = '${date.day}';
                                      
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          label,
                                          style: PremiumDesignSystem.bodySmall
                                              .copyWith(
                                                color: isToday
                                                    ? theme.colorScheme.primary
                                                    : theme.colorScheme.onSurface.withOpacity(0.6),
                                                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                                                fontSize: 10,
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 80,
                                    interval: 1,
                                    getTitlesWidget: (value, meta) {
                                      if (value >= 1 &&
                                          value <= 5 &&
                                          value == value.toInt()) {
                                        String moodLabel;
                                        switch (value.toInt()) {
                                          case 5:
                                            moodLabel = 'Great';
                                            break;
                                          case 4:
                                            moodLabel = 'Good';
                                            break;
                                          case 3:
                                            moodLabel = 'Neutral';
                                            break;
                                          case 2:
                                            moodLabel = 'Low';
                                            break;
                                          case 1:
                                            moodLabel = 'Very Low';
                                            break;
                                          default:
                                            moodLabel = '';
                                        }
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 8.0),
                                          child: Text(
                                            moodLabel,
                                            style: PremiumDesignSystem.bodySmall.copyWith(
                                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(
                                show: false,
                              ),
                              minX: 0,
                              maxX: 6,
                              minY: 1,
                              maxY: 5,
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
                        'Date',
                        style: PremiumDesignSystem.bodySmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Showing your normalized mental wellness index over the last 7 calendar days.',
                      style: PremiumDesignSystem.bodySmall.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
