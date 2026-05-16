import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<_Notif> _notifs = [
    _Notif(Icons.emoji_events_rounded, 'Badge débloqué !',
        'Vous avez obtenu le badge "Champion" 🏆', '2 min', NotifType.achievement),
    _Notif(Icons.recycling_rounded, 'Objectif hebdo atteint',
        'Bravo ! Vous avez recyclé 15 kg cette semaine.', '1h', NotifType.success),
    _Notif(Icons.map_rounded, 'Nouveau point de collecte',
        'Un centre de tri a ouvert près de chez vous.', '3h', NotifType.info),
    _Notif(Icons.star_rounded, '+50 points gagnés',
        'Dépôt compost validé — 50 points ajoutés.', '5h', NotifType.points),
    _Notif(Icons.warning_amber_rounded, 'Rappel de tri',
        'Jeudi c\'est la collecte ! Préparez vos bacs.', 'Hier', NotifType.warning),
    _Notif(Icons.leaderboard_rounded, 'Nouveau rang',
        'Vous êtes passé au rang 4 dans votre ville !', 'Hier', NotifType.success),
    _Notif(Icons.smart_toy_rounded, 'Conseil EcoBot',
        'Pensez à rincer vos bouteilles avant de les recycler.', '2j', NotifType.info),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notifications',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.darkText
                              : AppColors.textPrimary,
                        ),
                      ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),
                      Text(
                        '${_notifs.length} nouvelles',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
                    ],
                  ),
                  TextButton(
                    onPressed: () => setState(() => _notifs.clear()),
                    child: const Text(
                      'Tout effacer',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: AppColors.danger,
                        fontSize: 13,
                      ),
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
                ],
              ),
            ),
            Expanded(
              child: _notifs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.notifications_off_outlined,
                            size: 72,
                            color: AppColors.textLight.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Aucune notification',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ).animate().fadeIn(duration: 400.ms),
                    )
                  : ListView.separated(
                      padding:
                          const EdgeInsets.fromLTRB(20, 0, 20, 90),
                      itemCount: _notifs.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => Dismissible(
                        key: ValueKey(_notifs[i].title + i.toString()),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) =>
                            setState(() => _notifs.removeAt(i)),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete_rounded,
                              color: AppColors.danger),
                        ),
                        child: _NotifCard(
                          notif: _notifs[i],
                          isDark: isDark,
                        )
                            .animate(delay: (i * 60).ms)
                            .fadeIn(duration: 350.ms)
                            .slideX(begin: 0.08),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final _Notif notif;
  final bool isDark;
  const _NotifCard({required this.notif, required this.isDark});

  Color get _color {
    switch (notif.type) {
      case NotifType.achievement: return AppColors.accent;
      case NotifType.success: return AppColors.primary;
      case NotifType.warning: return AppColors.warning;
      case NotifType.points: return AppColors.teal;
      case NotifType.info: return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: _color, width: 3),
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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(notif.icon, color: _color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      notif.title,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkText
                            : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      notif.time,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notif.body,
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
    );
  }
}

enum NotifType { achievement, success, warning, points, info }

class _Notif {
  final IconData icon;
  final String title;
  final String body;
  final String time;
  final NotifType type;
  const _Notif(this.icon, this.title, this.body, this.time, this.type);
}
