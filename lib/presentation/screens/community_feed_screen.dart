import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../data/models/post_model.dart';
import '../../theme/premium_design_system.dart';
import '../../widgets/premium_card.dart';

// Community feed screen - displays anonymous user posts and reflections
class CommunityFeedScreen extends ConsumerWidget {
  const CommunityFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(communityFeedProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
        title: Text(
          'Community Feed',
          style: PremiumDesignSystem.headline.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.edit,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            onPressed: () => _showComposeSheet(context, ref),
            tooltip: 'Compose',
          ),
        ],
      ),
      body: feedAsync.when(
        data: (posts) {
          if (posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.forum_outlined,
                    size: 64,
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No posts yet',
                    style: PremiumDesignSystem.bodyMedium.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Be the first to share',
                    style: PremiumDesignSystem.bodySmall.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return _buildPostCard(context, ref, posts[index]);
            },
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(color: theme.colorScheme.primary),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red.withOpacity(0.6),
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load feed',
                style: PremiumDesignSystem.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showComposeSheet(context, ref),
        backgroundColor: theme.colorScheme.primary,
        child: Icon(Icons.add, color: theme.colorScheme.onPrimary),
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, WidgetRef ref, PostModel post) {
    final date = DateTime.fromMillisecondsSinceEpoch(post.timestamp);
    final theme = Theme.of(context);

    return PremiumCard(
      padding: const EdgeInsets.all(PremiumDesignSystem.cardPaddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Anonymous',
                      style: PremiumDesignSystem.bodySmall.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${date.day}/${date.month}/${date.year}',
                      style: PremiumDesignSystem.bodySmall.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.4),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              post.content,
              style: PremiumDesignSystem.bodyLarge.copyWith(
                color: theme.colorScheme.onSurface,
                height: 1.6,
              ),
            ),
          ),
          if (post.moodTag != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  width: PremiumDesignSystem.borderWidth,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                post.moodTag!,
                style: PremiumDesignSystem.bodySmall.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              InkWell(
                onTap: () => _incrementSupport(context, ref, post.id),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.3),
                      width: PremiumDesignSystem.borderWidth,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${post.supportCount}',
                        style: PremiumDesignSystem.bodySmall.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showComposeSheet(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    bool isPosting = false;
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(PremiumDesignSystem.modalTopRadius),
        ),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isPosting)
                  const LinearProgressIndicator(
                    backgroundColor: Color(0xFF1a1a2e),
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Share Reflection',
                      style: PremiumDesignSystem.headline.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: controller,
                  maxLines: 5,
                  style: PremiumDesignSystem.bodyLarge.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Share your thoughts anonymously...',
                    hintStyle: PremiumDesignSystem.bodyLarge.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        PremiumDesignSystem.borderRadius,
                      ),
                      borderSide: BorderSide(
                        color: theme.colorScheme.outline.withOpacity(0.3),
                        width: PremiumDesignSystem.borderWidth,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        PremiumDesignSystem.borderRadius,
                      ),
                      borderSide: BorderSide(
                        color: theme.colorScheme.outline.withOpacity(0.3),
                        width: PremiumDesignSystem.borderWidth,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        PremiumDesignSystem.borderRadius,
                      ),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: PremiumDesignSystem.borderWidth,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SafeArea(
                  child: ElevatedButton(
                    onPressed: isPosting
                        ? null
                        : () async {
                            final content = controller.text.trim();
                            if (content.isNotEmpty) {
                              setState(() {
                                isPosting = true;
                              });
                              try {
                                await ref
                                    .read(communityRepositoryProvider)
                                    .createPost(content);
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Reflection shared anonymously with the community.',
                                      ),
                                      backgroundColor: Colors.grey,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  setState(() {
                                    isPosting = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to publish: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          PremiumDesignSystem.borderRadius,
                        ),
                      ),
                      elevation: 0,
                    ),
                    child: isPosting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Post anonymously',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _incrementSupport(
    BuildContext context,
    WidgetRef ref,
    String postId,
  ) async {
    try {
      await ref.read(communityRepositoryProvider).incrementSupport(postId);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to support: $e')));
      }
    }
  }
}
