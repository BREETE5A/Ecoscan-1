import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/avatar_provider.dart';
import '../../l10n/app_strings.dart';
import '../../theme/app_theme.dart';

const _kAvatarPathKey = 'user_avatar_path';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _statCtrl;
  late Animation<double> _statAnim;

  @override
  void initState() {
    super.initState();
    _statCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    _statAnim = CurvedAnimation(parent: _statCtrl, curve: Curves.easeOut);
    _statCtrl.forward();
    _loadAvatarIntoProvider();
  }

  Future<void> _loadAvatarIntoProvider() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_kAvatarPathKey);
    if (path != null && File(path).existsSync() && mounted) {
      ref.read(avatarPathProvider.notifier).state = path;
    }
  }

  @override
  void dispose() {
    _statCtrl.dispose();
    super.dispose();
  }

  List<(IconData, String, String, Color)> _buildMenuItems(AppStrings s) => [
    (Icons.edit_rounded,              s.menuEditProfile,    '/profile/edit',    AppColors.primary),
    (Icons.bar_chart_rounded,         s.menuStats,          '/stats',           AppColors.teal),
    (Icons.emoji_events_rounded,      s.menuBadges,         '/badges',          const Color(0xFFF39C12)),
    (Icons.menu_book_rounded,         s.menuGuide,          '/guide',           const Color(0xFF3498DB)),
    (Icons.leaderboard_rounded,       s.menuLeaderboard,    '/leaderboard',     const Color(0xFF9B59B6)),
    (Icons.notifications_outlined,    s.menuNotifications,  '/notifications',   AppColors.primary),
    (Icons.settings_outlined,         s.menuSettings,       '/settings',        AppColors.textSecondary),
    (Icons.wb_sunny_rounded,          s.menuWeather,        '/weather',         const Color(0xFFFFA726)),
    (Icons.air_rounded,               s.menuAirQuality,     '/air-quality',     const Color(0xFF26C6DA)),
    (Icons.water_drop_rounded,        s.menuWaterFoot,      '/water-footprint', const Color(0xFF0288D1)),
    (Icons.quiz_rounded,              s.menuQuiz,           '/quiz',            const Color(0xFF7E57C2)),
    (Icons.barcode_reader,            s.menuBarcodeScanner, '/barcode',         const Color(0xFF26A69A)),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(userProvider);
    final s = AppStrings.of(ref.watch(localeProvider).languageCode);
    final avatarPath = ref.watch(avatarPathProvider);
    final menuItems = _buildMenuItems(s);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor:
                isDark ? AppColors.darkBackground : AppColors.background,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Hero(
                        tag: 'profile-avatar',
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: avatarPath == null
                                ? AppColors.darkPrimaryGradient
                                : null,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 16,
                              ),
                            ],
                            image: avatarPath != null
                                ? DecorationImage(
                                    image: FileImage(File(avatarPath)),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: avatarPath == null
                              ? const Icon(Icons.person_rounded,
                                  color: Colors.white, size: 46)
                              : null,
                        ),
                      ).animate().scale(
                          begin: const Offset(0.7, 0.7),
                          duration: 600.ms,
                          curve: Curves.elasticOut),
                      const SizedBox(height: 12),
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
                      Text(
                        s.levelCity(user.level, user.city),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _StatItem(label: s.points, value: user.points, anim: _statAnim),
                          Container(height: 30, width: 1, color: Colors.white.withValues(alpha: 0.3)),
                          _StatItem(label: s.scans, value: user.scans, anim: _statAnim),
                          Container(height: 30, width: 1, color: Colors.white.withValues(alpha: 0.3)),
                          _StatItem(label: s.qaBadges, value: user.badges, anim: _statAnim),
                          Container(height: 30, width: 1, color: Colors.white.withValues(alpha: 0.3)),
                          _StatItem(label: s.rank, value: user.rank == 0 ? 1 : user.rank, anim: _statAnim),
                        ],
                      ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _LevelCard(isDark: isDark, user: user, s: s)
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 200.ms)
                    .slideY(begin: 0.1),
                const SizedBox(height: 20),
                _BadgeRow(isDark: isDark, unlockedCount: user.badges, s: s)
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 300.ms),
                const SizedBox(height: 20),
                // ── Menu ──────────────────────────────────────────────────
                Text(
                  s.menu,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkText : AppColors.textPrimary,
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: 350.ms),
                const SizedBox(height: 12),
                ...List.generate(
                  menuItems.length,
                  (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _MenuItem(
                      icon: menuItems[i].$1,
                      label: menuItems[i].$2,
                      route: menuItems[i].$3,
                      color: menuItems[i].$4,
                      isDark: isDark,
                    )
                        .animate(delay: (400 + i * 60).ms)
                        .fadeIn(duration: 300.ms)
                        .slideX(begin: 0.08),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () async {
                    await signOutUser(ref);
                    if (context.mounted) context.go('/login');
                  },
                  icon: const Icon(Icons.logout_rounded,
                      color: AppColors.danger, size: 18),
                  label: Text(
                    s.disconnect,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: AppColors.danger,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: AppColors.danger.withValues(alpha: 0.4)),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ).animate(delay: 800.ms).fadeIn(duration: 300.ms),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final int value;
  final Animation<double> anim;
  const _StatItem({required this.label, required this.value, required this.anim});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: anim,
          builder: (_, _) => Text(
            '${(value * anim.value).round()}',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
  }
}

class _LevelCard extends StatelessWidget {
  final bool isDark;
  final dynamic user;
  final AppStrings s;
  const _LevelCard({required this.isDark, required this.user, required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
              blurRadius: 12),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${s.level} ${user.level}',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkText : AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  s.nextLevelLabel(user.level + 1),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: user.xp / user.xpMax),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOut,
              builder: (_, v, _) => LinearProgressIndicator(
                value: v,
                backgroundColor: isDark ? AppColors.darkInput : AppColors.inputBg,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 10,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            s.xpProgressText(user.xp, user.xpMax),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeRow extends StatelessWidget {
  final bool isDark;
  final int unlockedCount;
  final AppStrings s;
  const _BadgeRow({required this.isDark, required this.unlockedCount, required this.s});

  @override
  Widget build(BuildContext context) {
    final badges = [
      (Icons.recycling_rounded,   AppColors.primary,           s.badgeRecycleur),
      (Icons.water_drop_rounded,  AppColors.info,              s.badgeEau),
      (Icons.forest_rounded,      const Color(0xFF388E3C),     s.badgeArbre),
      (Icons.emoji_events_rounded, const Color(0xFFF39C12),   s.badgeChampion),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              s.recentBadges,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkText : AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () => context.go('/badges'),
              child: Text(
                s.seeAll,
                style: const TextStyle(
                    fontFamily: 'Poppins', color: AppColors.primary, fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(badges.length, (i) {
            final unlocked = i < unlockedCount;
            return Column(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: unlocked
                        ? badges[i].$2.withValues(alpha: 0.15)
                        : Colors.grey.withValues(alpha: 0.1),
                    border: Border.all(
                        color: unlocked
                            ? badges[i].$2.withValues(alpha: 0.4)
                            : Colors.grey.withValues(alpha: 0.3),
                        width: 2),
                  ),
                  child: Icon(
                    unlocked ? badges[i].$1 : Icons.lock_outline_rounded,
                    color: unlocked ? badges[i].$2 : Colors.grey.withValues(alpha: 0.4),
                    size: 26,
                  ),
                )
                    .animate(delay: (i * 80).ms)
                    .scale(
                        begin: const Offset(0, 0),
                        duration: 500.ms,
                        curve: Curves.elasticOut)
                    .fadeIn(duration: 300.ms),
                const SizedBox(height: 6),
                Text(
                  badges[i].$3,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: unlocked
                        ? (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)
                        : Colors.grey.withValues(alpha: 0.5),
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}

class _MenuItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final String route;
  final Color color;
  final bool isDark;
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.color,
    required this.isDark,
  });

  @override
  State<_MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<_MenuItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween(begin: 1.0, end: 0.96).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        context.go(widget.route);
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: widget.isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: widget.isDark ? 0.15 : 0.04),
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(widget.icon, color: widget.color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: widget.isDark ? AppColors.darkText : AppColors.textPrimary,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textLight),
            ],
          ),
        ),
      ),
    );
  }
}
