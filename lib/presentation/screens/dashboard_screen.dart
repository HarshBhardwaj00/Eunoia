import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'mood_logger_screen.dart';
import '../../services/sync_manager.dart';
import '../../data/models/mood_log_model.dart';
import '../../providers/app_providers.dart';
import 'mood_chart_screen.dart';

// Analytics dashboard - displays recent journal entries and mood trends
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      final repository = ref.read(journalRepositoryProvider);

      // Initialize sync manager
      SyncManager.instance.initialize();

      await repository.initialize();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final moodLogs = ref.watch(journalRepositoryStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.show_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MoodChartScreen(),
                ),
              );
            },
            tooltip: 'View Mood Chart',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MoodLoggerScreen()),
          ).then(
            (_) => ref.read(journalRepositoryStateProvider.notifier).refresh(),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : moodLogs.isEmpty
            ? _buildEmptyView()
            : _buildDashboard(moodLogs),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No mood logs yet',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to log your first entry',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(List<MoodLog> moodLogs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Journal Entries',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...moodLogs.take(10).map((log) => _buildLogCard(log)),
        ],
      ),
    );
  }

  Widget _buildLogCard(MoodLog log) {
    // Extract mood from encryptedTitle
    final moodRegex = RegExp(r'Mood:\s*(\d+)');
    final moodMatch = moodRegex.firstMatch(log.encryptedTitle);
    final moodScore = moodMatch != null
        ? int.parse(moodMatch.group(1) ?? '3')
        : 3;
    final moodEmojis = {1: '😢', 2: '😔', 3: '😐', 4: '🙂', 5: '😊'};

    // Get sentiment color and icon
    Color getSentimentColor(String? sentiment) {
      if (sentiment == null) return Colors.grey;
      switch (sentiment.toLowerCase()) {
        case 'positive':
          return Colors.green;
        case 'negative':
          return Colors.red;
        case 'neutral':
          return Colors.grey;
        default:
          return Colors.grey;
      }
    }

    IconData getSentimentIcon(String? sentiment) {
      if (sentiment == null) return Icons.sentiment_neutral;
      switch (sentiment.toLowerCase()) {
        case 'positive':
          return Icons.sentiment_satisfied;
        case 'negative':
          return Icons.sentiment_dissatisfied;
        case 'neutral':
          return Icons.sentiment_neutral;
        default:
          return Icons.sentiment_neutral;
      }
    }

    final sentimentColor = getSentimentColor(log.sentiment);
    final sentimentIcon = getSentimentIcon(log.sentiment);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI Analysis Badge (horizontal minimalist card)
            if (log.sentiment != null ||
                log.detectedEmotion != null ||
                log.summary != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: sentimentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: sentimentColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Sentiment icon with color accent
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: sentimentColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        sentimentIcon,
                        size: 20,
                        color: sentimentColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Emotion chip
                    if (log.detectedEmotion != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: sentimentColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: sentimentColor.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          log.detectedEmotion!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: sentimentColor,
                          ),
                        ),
                      ),
                    const Spacer(),
                    // Sentiment label
                    if (log.sentiment != null)
                      Text(
                        log.sentiment!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: sentimentColor.withOpacity(0.8),
                          letterSpacing: 0.5,
                        ),
                      ),
                  ],
                ),
              ),
            // Summary blockquote
            if (log.summary != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 8, top: 2),
                      width: 3,
                      height: 40,
                      decoration: BoxDecoration(
                        color: sentimentColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '"${log.summary}"',
                        style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            // Main content
            Row(
              children: [
                Text(
                  moodEmojis[moodScore] ?? '😐',
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mood: $moodScore/5',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      _formatDate(log.timestamp),
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => _deleteLog(log.id),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(log.encryptedContent, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteLog(String id) async {
    try {
      await ref.read(journalRepositoryStateProvider.notifier).deleteMoodLog(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Log deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete log: $e')));
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
