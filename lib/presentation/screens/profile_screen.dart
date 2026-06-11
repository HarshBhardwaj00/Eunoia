import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../theme/premium_design_system.dart';
import '../../data/models/user_model.dart';
import '../../data/models/mood_log_model.dart';
import 'notification_preferences_screen.dart';
import 'data_vault_privacy_screen.dart';

// User profile screen - displays wellness statistics and app settings
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userProfileAsync = ref.watch(userProfileFirestoreProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: userProfileAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
            data: (userProfile) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _buildHeader(context, userProfile, theme),
                  const SizedBox(height: 24),
                  _buildWellnessStats(context, ref, theme),
                  const SizedBox(height: 24),
                  _buildSettingsPanel(context, ref, theme),
                  const SizedBox(height: 24),
                  _buildLogoutButton(context, ref, theme),
                  const SizedBox(height: 24),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    UserModel? userProfile,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      child: Row(
        children: [
          // Compact circular avatar with thin borde
          // r
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF1AFFFFFF), // Colors.white12 equivalent
                width: 1.2,
              ),
            ),
            child: Center(
              child: Text(
                (userProfile != null && userProfile.name.isNotEmpty
                    ? userProfile.name[0].toUpperCase()
                    : 'U'),
                style: PremiumDesignSystem.displayLarge.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // User information column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userProfile?.name ?? 'User',
                  style: const TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Member since ${_formatDate(userProfile?.createdAt)}',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                if (userProfile != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Age: ${userProfile.age} years',
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWellnessStats(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
  ) {
    final moodLogs = ref.watch(journalRepositoryStateProvider);

    final streakDays = _calculateStreakDays(moodLogs);
    final moodScore = _calculateMoodScore(moodLogs);
    final totalJournals = moodLogs.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Wellness Statistics',
          style: PremiumDesignSystem.headline.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        // Professional vertical layout for wellness stats
        _buildStatBox(
          context,
          'Streak Days',
          streakDays.toString(),
          Icons.local_fire_department,
          theme,
          isFullWidth: true,
        ),
        const SizedBox(height: 12),
        _buildStatBox(
          context,
          'Mood Score',
          moodScore.toString(),
          Icons.sentiment_satisfied,
          theme,
          isFullWidth: true,
        ),
        const SizedBox(height: 12),
        _buildStatBox(
          context,
          'Total Journals',
          totalJournals.toString(),
          Icons.book,
          theme,
          isFullWidth: true,
        ),
      ],
    );
  }

  int _calculateStreakDays(List<MoodLog> moodLogs) {
    if (moodLogs.isEmpty) return 0;

    final sortedLogs = List<MoodLog>.from(moodLogs)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (sortedLogs.isEmpty) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int streak = 0;
    DateTime currentDate = today;

    for (var log in sortedLogs) {
      final logDate = DateTime(
        log.timestamp.year,
        log.timestamp.month,
        log.timestamp.day,
      );

      if (logDate == currentDate ||
          logDate == currentDate.subtract(const Duration(days: 1))) {
        if (logDate != currentDate) {
          streak++;
          currentDate = logDate;
        } else {
          streak = 1;
        }
      } else {
        break;
      }
    }

    return streak;
  }

  int _calculateMoodScore(List<MoodLog> moodLogs) {
    if (moodLogs.isEmpty) return 0;

    int totalScore = 0;
    int count = 0;

    for (var log in moodLogs) {
      final score = _extractMoodScore(log.encryptedTitle);
      if (score > 0) {
        totalScore += score;
        count++;
      }
    }

    if (count == 0) return 0;

    // Convert to percentage (1-5 scale to 0-100)
    return ((totalScore / count) * 20).round();
  }

  int _extractMoodScore(String encryptedTitle) {
    final regex = RegExp(r'Mood:\s*(\d+)');
    final match = regex.firstMatch(encryptedTitle);
    if (match != null) {
      return int.parse(match.group(1) ?? '3');
    }
    return 3;
  }

  Widget _buildStatBox(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    ThemeData theme, {
    bool isFullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: PremiumDesignSystem.headline.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  label,
                  style: PremiumDesignSystem.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsPanel(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
  ) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: PremiumDesignSystem.headline.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        // Dark Mode Toggle
        _buildSettingsTile(
          context,
          'Dark Mode',
          isDark ? 'Enabled' : 'Disabled',
          Icons.dark_mode_outlined,
          theme,
          onTap: () {
            ref.read(themeModeProvider.notifier).state = isDark
                ? ThemeMode.light
                : ThemeMode.dark;
          },
        ),
        const SizedBox(height: 8),
        // Notification Preferences
        _buildSettingsTile(
          context,
          'Notification Preferences',
          'Configure',
          Icons.notifications_outlined,
          theme,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationPreferencesScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        // Data Vault Privacy
        _buildSettingsTile(
          context,
          'Data Vault Privacy',
          'View',
          Icons.lock_outlined,
          theme,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DataVaultPrivacyScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    String title,
    String trailing,
    IconData icon,
    ThemeData theme, {
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.15),
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        title: Text(
          title,
          style: PremiumDesignSystem.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              trailing,
              style: PremiumDesignSystem.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutButton(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withOpacity(0.08),
        border: Border.all(
          color: theme.colorScheme.error.withOpacity(0.3),
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        leading: Icon(
          Icons.logout_rounded,
          size: 24,
          color: theme.colorScheme.error,
        ),
        title: Text(
          'Sign Out',
          style: PremiumDesignSystem.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.error,
          ),
          textAlign: TextAlign.center,
        ),
        onTap: () async {
          final authService = ref.read(authServiceProvider);
          try {
            await authService.signOut();
            if (context.mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/',
                (route) => false,
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to sign out: $e'),
                  backgroundColor: theme.colorScheme.error,
                ),
              );
            }
          }
        },
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      // Fallback to current month/year or "Recent Member"
      final now = DateTime.now();
      return '${now.month}/${now.year}';
    }
    return '${date.month}/${date.year}';
  }
}
