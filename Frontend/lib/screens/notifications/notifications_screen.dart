import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/notification_service.dart';
import '../../providers/locale_provider.dart';
import '../../l10n/app_strings.dart';
import '../../theme/app_theme.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = AppStrings.of(ref.watch(localeProvider).languageCode);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Text(
                s.notifications,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkText : AppColors.textPrimary,
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),
            ),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: NotificationService.getNotifications(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final notifs = snapshot.data ?? [];
                  if (notifs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.notifications_off_outlined,
                            size: 72,
                            color: AppColors.textLight.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            s.noNotifications,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ).animate().fadeIn(duration: 400.ms),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 90),
                    itemCount: notifs.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final n = notifs[i];
                      final isRead = n['read'] == true;
                      return GestureDetector(
                        onTap: () => NotificationService.markAsRead(n['id'] as String),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkCard : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border(
                              left: BorderSide(
                                color: isRead ? Colors.grey.shade300 : AppColors.primary,
                                width: 3,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundColor: isRead
                                    ? Colors.grey.shade200
                                    : AppColors.primary.withValues(alpha: 0.12),
                                child: const Text('🌿'),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      n['title'] as String? ?? '',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 13,
                                        fontWeight: isRead ? FontWeight.normal : FontWeight.w700,
                                        color: isDark ? AppColors.darkText : AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      n['body'] as String? ?? '',
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ).animate(delay: (i * 60).ms).fadeIn(duration: 350.ms).slideX(begin: 0.08),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
