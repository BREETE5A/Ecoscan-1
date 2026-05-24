import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../l10n/app_strings.dart';
import '../providers/locale_provider.dart';
import '../theme/app_theme.dart';

class MainScaffold extends ConsumerStatefulWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold>
    with TickerProviderStateMixin {
  late AnimationController _scanPulse;
  late AnimationController _botPulse;
  late Animation<double> _scanScale;
  late Animation<double> _botScale;

  bool _isOffline = false;
  StreamSubscription<List<ConnectivityResult>>? _connSub;

  @override
  void initState() {
    super.initState();
    _scanPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _scanScale = Tween(begin: 1.0, end: 1.12)
        .animate(CurvedAnimation(parent: _scanPulse, curve: Curves.easeInOut));

    _botPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _botScale = Tween(begin: 1.0, end: 1.08)
        .animate(CurvedAnimation(parent: _botPulse, curve: Curves.easeInOut));

    _connSub = Connectivity()
        .onConnectivityChanged
        .listen((results) {
      final offline = results.every((r) => r == ConnectivityResult.none);
      if (mounted && offline != _isOffline) {
        setState(() => _isOffline = offline);
      }
    });
  }

  @override
  void dispose() {
    _scanPulse.dispose();
    _botPulse.dispose();
    _connSub?.cancel();
    super.dispose();
  }

  int _selectedIndex(BuildContext context) {
    final loc = GoRouterState.of(context).uri.path;
    if (loc.startsWith('/home')) return 0;
    if (loc.startsWith('/map')) return 1;
    if (loc.startsWith('/scan')) return 2;
    if (loc.startsWith('/guide')) return 3;
    if (loc.startsWith('/profile')) return 4;
    return 0;
  }

  void _openEcoBot(BuildContext context) {
    context.go('/chat');
  }

  @override
  Widget build(BuildContext context) {
    final idx = _selectedIndex(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = isDark ? AppColors.darkSurface : Colors.white;
    final loc = GoRouterState.of(context).uri.path;
    final showBotFab = !loc.startsWith('/chat') && !loc.startsWith('/scan') && !loc.startsWith('/map');
    final s = AppStrings.of(ref.watch(localeProvider).languageCode);

    return Scaffold(
      body: Stack(
        children: [
          widget.child,

          // Offline banner
          if (_isOffline)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _OfflineBanner(offlineText: s.offlineBanner),
            ),
        ],
      ),
      floatingActionButton: showBotFab
          ? _EcoBotFab(
              scaleAnim: _botScale,
              onTap: () => _openEcoBot(context),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBg,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 16,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home_rounded,
                      label: s.navHome,
                      selected: idx == 0,
                      onTap: () => context.go('/home'),
                    ),
                    _NavItem(
                      icon: Icons.map_outlined,
                      activeIcon: Icons.map_rounded,
                      label: s.navMap,
                      selected: idx == 1,
                      onTap: () => context.go('/map'),
                    ),
                    const SizedBox(width: 64),
                    _NavItem(
                      icon: Icons.menu_book_outlined,
                      activeIcon: Icons.menu_book_rounded,
                      label: s.navGuide,
                      selected: idx == 3,
                      onTap: () => context.go('/guide'),
                    ),
                    _NavItem(
                      icon: Icons.person_outline_rounded,
                      activeIcon: Icons.person_rounded,
                      label: s.navProfile,
                      selected: idx == 4,
                      onTap: () => context.go('/profile'),
                    ),
                  ],
                ),
                Positioned(
                  top: -18,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _ScanFab(scaleAnim: _scanScale, onTap: () => context.go('/scan')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Offline Banner ────────────────────────────────────────────────────────────

class _OfflineBanner extends StatelessWidget {
  final String offlineText;
  const _OfflineBanner({required this.offlineText});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF6B35), Color(0xFFE74C3C)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              const Icon(Icons.offline_bolt_rounded,
                  color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  offlineText,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'LOCAL',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── EcoBot FAB ────────────────────────────────────────────────────────────────

class _EcoBotFab extends StatefulWidget {
  final Animation<double> scaleAnim;
  final VoidCallback onTap;
  const _EcoBotFab({required this.scaleAnim, required this.onTap});

  @override
  State<_EcoBotFab> createState() => _EcoBotFabState();
}

class _EcoBotFabState extends State<_EcoBotFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _tap;

  @override
  void initState() {
    super.initState();
    _tap = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
  }

  @override
  void dispose() {
    _tap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTapDown: (_) => _tap.forward(),
        onTapUp: (_) {
          _tap.reverse();
          widget.onTap();
        },
        onTapCancel: () => _tap.reverse(),
        child: AnimatedBuilder(
          animation: Listenable.merge([widget.scaleAnim, _tap]),
          builder: (_, child) => Transform.scale(
            scale: widget.scaleAnim.value * (1.0 - _tap.value * 0.12),
            child: child,
          ),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.goldGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.55),
                  blurRadius: 16,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.support_agent_rounded, color: Colors.white, size: 26),
            ),
          ),
        ),
      ),
    );
  }
}

// ── EcoBot Bottom Sheet ───────────────────────────────────────────────────────

class _EcoBotSheet extends ConsumerStatefulWidget {
  const _EcoBotSheet();

  @override
  ConsumerState<_EcoBotSheet> createState() => _EcoBotSheetState();
}

class _EcoBotSheetState extends ConsumerState<_EcoBotSheet> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  bool _isTyping = false;

  final List<_BotMsg> _messages = [
    _BotMsg(
      text:
          '👋 Bonjour ! Je suis EcoBot, votre assistant écologique. Comment puis-je vous aider ?',
      isBot: true,
    ),
  ];

  static const _quickReplies = [
    'Comment trier le plastique ?',
    'Où déposer les piles ?',
    'Mon impact CO₂ ?',
    'Défis disponibles ?',
  ];

  static const _botResponses = {
    'plastique':
        '♻️ Le plastique PET (bouteilles) va dans le bac jaune. Rincez-les avant ! Le plastique dur (jouets, mobilier) va aux déchetteries.',
    'pile':
        '🔋 Les piles doivent être déposées dans les bornes de collecte spéciales, présentes dans les supermarchés et mairies. Ne les jetez JAMAIS à la poubelle !',
    'co2':
        '🌿 Selon vos scans, vous avez économisé environ 870g de CO₂ cette semaine. Continuez comme ça !',
    'défi':
        '🏆 Vous avez 3 défis disponibles : Scanner 3 déchets (2/3 ✓), Streak 7 jours (5/7) et Zéro DEEE.',
    'default':
        '🤔 Je ne comprends pas encore cette question, mais je suis en apprentissage ! Essayez de me demander comment trier un déchet spécifique.',
  };

  String _getResponse(String input) {
    final lower = input.toLowerCase();
    if (lower.contains('plastique') || lower.contains('pet')) {
      return _botResponses['plastique']!;
    }
    if (lower.contains('pile') || lower.contains('batterie') ||
        lower.contains('deee')) {
      return _botResponses['pile']!;
    }
    if (lower.contains('co2') || lower.contains('carbone') ||
        lower.contains('impact')) {
      return _botResponses['co2']!;
    }
    if (lower.contains('défi') || lower.contains('challenge') ||
        lower.contains('badge')) {
      return _botResponses['défi']!;
    }
    return _botResponses['default']!;
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _controller.clear();

    setState(() {
      _messages.add(_BotMsg(text: text, isBot: false));
      _isTyping = true;
    });

    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    setState(() {
      _isTyping = false;
      _messages.add(_BotMsg(text: _getResponse(text), isBot: true));
    });

    await Future.delayed(const Duration(milliseconds: 100));
    if (_scroll.hasClients) {
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = AppStrings.of(ref.watch(localeProvider).languageCode);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      expand: false,
      builder: (_, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Handle + header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.support_agent_rounded, color: Colors.white, size: 22),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'EcoBot',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.darkText
                                  : AppColors.textPrimary,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                s.onlineShort,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Messages
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (_, i) {
                  if (_isTyping && i == _messages.length) {
                    return _TypingIndicator(isDark: isDark);
                  }
                  return _ChatBubble(msg: _messages[i], isDark: isDark);
                },
              ),
            ),

            // Quick replies
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _quickReplies.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) => ActionChip(
                  label: Text(
                    _quickReplies[i],
                    style: const TextStyle(
                        fontFamily: 'Poppins', fontSize: 12),
                  ),
                  onPressed: () => _sendMessage(_quickReplies[i]),
                  backgroundColor:
                      AppColors.primary.withValues(alpha: 0.1),
                  labelStyle: const TextStyle(color: AppColors.primary),
                  side: const BorderSide(color: AppColors.primary, width: 0.5),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Input
            Padding(
              padding: EdgeInsets.fromLTRB(
                  16, 8, 16, MediaQuery.of(context).viewInsets.bottom + 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.inputBg,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _controller,
                        onSubmitted: _sendMessage,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: isDark
                              ? AppColors.darkText
                              : AppColors.textPrimary,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Posez votre question...',
                          hintStyle: TextStyle(
                              fontFamily: 'Poppins',
                              color: AppColors.textSecondary,
                              fontSize: 13),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _sendMessage(_controller.text),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.primaryGradient,
                      ),
                      child: const Icon(Icons.send_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final _BotMsg msg;
  final bool isDark;
  const _ChatBubble({required this.msg, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: msg.isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          gradient: msg.isBot
              ? null
              : AppColors.primaryGradient,
          color: msg.isBot
              ? (isDark ? AppColors.darkCard : AppColors.inputBg)
              : null,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(msg.isBot ? 4 : 18),
            bottomRight: Radius.circular(msg.isBot ? 18 : 4),
          ),
        ),
        child: Text(
          msg.text,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: msg.isBot
                ? (isDark ? AppColors.darkText : AppColors.textPrimary)
                : Colors.white,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  final bool isDark;
  const _TypingIndicator({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.inputBg,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 600 + i * 200),
              builder: (_, v, _) => Container(
                width: 7,
                height: 7,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: AppColors.textSecondary
                      .withValues(alpha: 0.4 + v * 0.6),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _BotMsg {
  final String text;
  final bool isBot;
  _BotMsg({required this.text, required this.isBot});
}

// ── Nav components (unchanged from before) ───────────────────────────────────

class _NavItem extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
    _scale = Tween(begin: 1.0, end: 0.85)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
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
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: SizedBox(
          width: 64,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  widget.selected ? widget.activeIcon : widget.icon,
                  key: ValueKey(widget.selected),
                  color: widget.selected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  size: 24,
                ),
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: widget.selected
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: widget.selected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
                child: Text(widget.label),
              ),
              const SizedBox(height: 2),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                height: 3,
                width: widget.selected ? 20 : 0,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScanFab extends StatefulWidget {
  final Animation<double> scaleAnim;
  final VoidCallback onTap;
  const _ScanFab({required this.scaleAnim, required this.onTap});

  @override
  State<_ScanFab> createState() => _ScanFabState();
}

class _ScanFabState extends State<_ScanFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _tap;
  late Animation<double> _tapScale;

  @override
  void initState() {
    super.initState();
    _tap = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _tapScale = Tween(begin: 1.0, end: 0.88)
        .animate(CurvedAnimation(parent: _tap, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _tap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _tap.forward(),
      onTapUp: (_) {
        _tap.reverse();
        widget.onTap();
      },
      onTapCancel: () => _tap.reverse(),
      child: AnimatedBuilder(
        animation: Listenable.merge([widget.scaleAnim, _tapScale]),
        builder: (_, child) => Transform.scale(
          scale: widget.scaleAnim.value * _tapScale.value,
          child: child,
        ),
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.45),
                blurRadius: 18,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.qr_code_scanner_rounded,
              color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
