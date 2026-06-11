import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/premium_design_system.dart';

class NotificationPreferencesScreen extends ConsumerStatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  ConsumerState<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends ConsumerState<NotificationPreferencesScreen> {
  bool _dailyReminders = true;
  bool _moodCheckIns = true;
  bool _communityUpdates = false;
  bool _weeklyReports = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Notification Preferences',
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
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'Manage your notification settings',
                style: PremiumDesignSystem.bodyLarge.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 32),
              _buildToggleTile(
                context,
                'Daily Reminders',
                'Get reminded to log your mood daily',
                Icons.alarm,
                _dailyReminders,
                (value) {
                  setState(() {
                    _dailyReminders = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildToggleTile(
                context,
                'Mood Check-ins',
                'Receive prompts to check your mood',
                Icons.psychology,
                _moodCheckIns,
                (value) {
                  setState(() {
                    _moodCheckIns = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildToggleTile(
                context,
                'Community Updates',
                'Notifications from community feed',
                Icons.people,
                _communityUpdates,
                (value) {
                  setState(() {
                    _communityUpdates = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildToggleTile(
                context,
                'Weekly Reports',
                'Receive weekly mood summaries',
                Icons.bar_chart,
                _weeklyReports,
                (value) {
                  setState(() {
                    _weeklyReports = value;
                  });
                },
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.15),
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Notification Settings',
                            style: PremiumDesignSystem.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'You can change these settings anytime. Notifications help you stay consistent with your wellness journey.',
                      style: PremiumDesignSystem.bodySmall.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    final theme = Theme.of(context);

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
        subtitle: Text(
          subtitle,
          style: PremiumDesignSystem.bodySmall.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
