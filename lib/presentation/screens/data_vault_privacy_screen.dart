import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/premium_design_system.dart';

class DataVaultPrivacyScreen extends ConsumerStatefulWidget {
  const DataVaultPrivacyScreen({super.key});

  @override
  ConsumerState<DataVaultPrivacyScreen> createState() =>
      _DataVaultPrivacyScreenState();
}

class _DataVaultPrivacyScreenState
    extends ConsumerState<DataVaultPrivacyScreen> {
  bool _dataEncryption = true;
  bool _anonymousPosting = true;
  bool _localStorageOnly = false;
  bool _analyticsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Data Vault Privacy',
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
                'Control how your data is stored and shared',
                style: PremiumDesignSystem.bodyLarge.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 32),
              _buildToggleTile(
                context,
                'End-to-End Encryption',
                'All journal entries are encrypted with AES-256',
                Icons.lock,
                _dataEncryption,
                (value) {
                  setState(() {
                    _dataEncryption = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildToggleTile(
                context,
                'Anonymous Community Posting',
                'Posts use SHA-256 pseudonyms, not real UIDs',
                Icons.visibility_off,
                _anonymousPosting,
                (value) {
                  setState(() {
                    _anonymousPosting = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildToggleTile(
                context,
                'Local Storage Only',
                'Keep data on device only (no cloud sync)',
                Icons.smartphone,
                _localStorageOnly,
                (value) {
                  setState(() {
                    _localStorageOnly = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildToggleTile(
                context,
                'Analytics & Insights',
                'Allow anonymous usage analytics for improvements',
                Icons.analytics,
                _analyticsEnabled,
                (value) {
                  setState(() {
                    _analyticsEnabled = value;
                  });
                },
              ),
              const SizedBox(height: 32),
              _buildPrivacyInfoCard(context, theme),
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

  Widget _buildPrivacyInfoCard(BuildContext context, ThemeData theme) {
    return Container(
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
                Icons.security,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Privacy Guarantee',
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
            'Your mental health data is sacred. We use military-grade encryption and never sell your personal information. You have full control over your data at all times.',
            style: PremiumDesignSystem.bodySmall.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.check_circle,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'AES-256 Client-Side Encryption',
                style: PremiumDesignSystem.bodySmall.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.check_circle,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'No Third-Party Data Sharing',
                style: PremiumDesignSystem.bodySmall.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.check_circle,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Right to Delete All Data',
                style: PremiumDesignSystem.bodySmall.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
