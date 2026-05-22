import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_theme.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _statCtrl;
  late Animation<double> _statAnim;
  String? _avatarPath;

  @override
  void initState() {
    super.initState();
    _statCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    _statAnim =
        CurvedAnimation(parent: _statCtrl, curve: Curves.easeOut);
    _statCtrl.forward();
  }

  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
              title: const Text('Prendre une photo',
                  style: TextStyle(fontFamily: 'Poppins')),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
              title: const Text('Choisir depuis la galerie',
                  style: TextStyle(fontFamily: 'Poppins')),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 512,
    );
    if (picked == null || !mounted) return;
    setState(() => _avatarPath = picked.path);
  }

  @override
  void dispose() {
    _statCtrl.dispose();
    super.dispose();
  }

  static const _menuItems = [
    (Icons.bar_chart_rounded, 'Mes statistiques', '/stats', AppColors.teal),
    (Icons.emoji_events_rounded, 'Mes badges', '/badges', Color(0xFFF39C12)),
    (Icons.menu_book_rounded, 'Guide de tri', '/guide', Color(0xFF3498DB)),
    (Icons.leaderboard_rounded, 'Classement', '/leaderboard', Color(0xFF9B59B6)),
    (Icons.notifications_outlined, 'Notifications', '/notifications', AppColors.primary),
    (Icons.settings_outlined, 'Paramètres', '/settings', AppColors.textSecondary),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(userProvider);

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
                      // Avatar
                      Stack(
                        children: [
                          Hero(
                            tag: 'profile-avatar',
                            child: Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: _avatarPath == null
                                    ? AppColors.darkPrimaryGradient
                                    : null,
                                border: Border.all(
                                    color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withValues(alpha: 0.2),
                                    blurRadius: 16,
                                  ),
                                ],
                                image: _avatarPath != null
                                    ? DecorationImage(
                                        image: FileImage(File(_avatarPath!)),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: _avatarPath == null
                                  ? const Icon(Icons.person_rounded,
                                      color: Colors.white, size: 46)
                                  : null,
                            ),
                          ).animate().scale(
                              begin: const Offset(0.7, 0.7),
                              duration: 600.ms,
                              curve: Curves.elasticOut),
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: GestureDetector(
                              onTap: _pickPhoto,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.15),
                                        blurRadius: 6),
                                  ],
                                ),
                                child: const Icon(Icons.edit_rounded,
                                    color: AppColors.primary, size: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
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
                        'Niveau ${user.level} • ${user.city}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
                      const SizedBox(height: 20),
                      // Stats row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _StatItem(label: 'Points', value: user.points, anim: _statAnim),
                          Container(
                              height: 30,
                              width: 1,
                              color: Colors.white.withValues(alpha: 0.3)),
                          _StatItem(label: 'Scans', value: user.scans, anim: _statAnim),
                          Container(
                              height: 30,
                              width: 1,
                              color: Colors.white.withValues(alpha: 0.3)),
                          _StatItem(label: 'Badges', value: user.badges, anim: _statAnim),
                          Container(
                              height: 30,
                              width: 1,
                              color: Colors.white.withValues(alpha: 0.3)),
                          _StatItem(label: 'Rang', value: user.rank == 0 ? 1 : user.rank, anim: _statAnim),
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
                // Level progress
                _LevelCard(isDark: isDark, user: user)
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 200.ms)
                    .slideY(begin: 0.1),
                const SizedBox(height: 20),
                // Recent badges
                _BadgeRow(isDark: isDark, unlockedCount: user.badges)
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 300.ms),
                const SizedBox(height: 20),
                // Menu items
                Text(
                  'Menu',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkText : AppColors.textPrimary,
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: 350.ms),
                const SizedBox(height: 12),
                ...List.generate(
                  _menuItems.length,
                  (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _MenuItem(
                      icon: _menuItems[i].$1,
                      label: _menuItems[i].$2,
                      route: _menuItems[i].$3,
                      color: _menuItems[i].$4,
                      isDark: isDark,
                    )
                        .animate(delay: (400 + i * 60).ms)
                        .fadeIn(duration: 300.ms)
                        .slideX(begin: 0.08),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => context.go('/login'),
                  icon: const Icon(Icons.logout_rounded,
                      color: AppColors.danger, size: 18),
                  label: const Text(
                    'Se déconnecter',
                    style: TextStyle(
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
  const _StatItem(
      {required this.label, required this.value, required this.anim});

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
  const _LevelCard({required this.isDark, required this.user});

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
                'Niveau ${user.level}',
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
                child: const Text(
                  'Niveau 8 →',
                  style: TextStyle(
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
                backgroundColor:
                    isDark ? AppColors.darkInput : AppColors.inputBg,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 10,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${user.xp} / ${user.xpMax} XP pour le prochain niveau',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
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
  const _BadgeRow({required this.isDark, required this.unlockedCount});

  static const _badges = [
    (Icons.recycling_rounded, AppColors.primary, 'Recycleur'),
    (Icons.water_drop_rounded, AppColors.info, 'Eau pure'),
    (Icons.forest_rounded, Color(0xFF388E3C), 'Arbre'),
    (Icons.emoji_events_rounded, Color(0xFFF39C12), 'Champion'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Badges récents',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkText : AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () => context.go('/badges'),
              child: const Text(
                'Voir tout',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    color: AppColors.primary,
                    fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            _badges.length,
            (i) {
              final unlocked = i < unlockedCount;
              return Column(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: unlocked
                          ? _badges[i].$2.withValues(alpha: 0.15)
                          : Colors.grey.withValues(alpha: 0.1),
                      border: Border.all(
                          color: unlocked
                              ? _badges[i].$2.withValues(alpha: 0.4)
                              : Colors.grey.withValues(alpha: 0.3),
                          width: 2),
                    ),
                    child: Icon(
                      unlocked ? _badges[i].$1 : Icons.lock_outline_rounded,
                      color: unlocked
                          ? _badges[i].$2
                          : Colors.grey.withValues(alpha: 0.4),
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
                    _badges[i].$3,
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
            },
          ),
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
                    color: widget.isDark
                        ? AppColors.darkText
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.textLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
