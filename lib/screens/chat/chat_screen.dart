import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  bool _isTyping = false;

  late AnimationController _dot1, _dot2, _dot3;

  final List<_Msg> _messages = [
    _Msg('Bonjour ! Je suis EcoBot 🌿 Votre assistant de tri intelligent. Comment puis-je vous aider ?', true),
    _Msg('Où mettre les cartons de pizza ?', false),
    _Msg('Les cartons de pizza légèrement souillés doivent aller dans le composteur ou la poubelle ordinaire. Si propre, le bac bleu (papier/carton) est parfait ! 🍕♻', true),
    _Msg('Et les bouteilles d\'huile vides ?', false),
    _Msg('Les bouteilles en plastique d\'huile vides peuvent aller dans le bac jaune. Pensez à les rincer rapidement avant ! 🫙', true),
  ];

  @override
  void initState() {
    super.initState();
    _dot1 = AnimationController(vsync: this, duration: 600.ms)..repeat(reverse: true);
    _dot2 = AnimationController(vsync: this, duration: 600.ms)
      ..repeat(reverse: true);
    _dot3 = AnimationController(vsync: this, duration: 600.ms)
      ..repeat(reverse: true);

    Future.delayed(150.ms, () { if (mounted) _dot2.forward(); });
    Future.delayed(300.ms, () { if (mounted) _dot3.forward(); });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    _dot1.dispose();
    _dot2.dispose();
    _dot3.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Msg(text, false));
      _isTyping = true;
    });
    _ctrl.clear();
    _scrollToBottom();

    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;

    const replies = [
      'Bonne question ! Pour ce type de déchet, je recommande de vérifier la consigne locale sur l\'application. Chaque ville peut avoir des règles spécifiques. 🌍',
      'Ce déchet va dans le bac jaune s\'il est en plastique recyclable (regardez le symbole ♻), sinon dans la poubelle ordinaire.',
      'Excellent réflexe ! Le tri sélectif peut réduire jusqu\'à 30% de vos déchets résiduels. Continuez comme ça ! 💚',
      'Je suggère de l\'apporter à la déchetterie la plus proche. Consultez la carte dans l\'application pour la localiser !',
    ];
    final reply = replies[_messages.length % replies.length];

    setState(() {
      _isTyping = false;
      _messages.add(_Msg(reply, true));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  static const _quickReplies = [
    'Où recycler les piles ?',
    'Comment trier le verre ?',
    'Plastique ou compost ?',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  // EcoBot avatar with pulse
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 1.0, end: 1.06),
                    duration: const Duration(milliseconds: 1000),
                    builder: (_, v, child) => Transform.scale(scale: v, child: child),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.primaryGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.smart_toy_rounded,
                          color: Colors.white, size: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
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
                            const SizedBox(width: 5),
                            const Text(
                              'En ligne — Assistant IA',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.more_vert_rounded,
                      color: AppColors.textSecondary),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.05),

            // Messages
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (_, i) {
                  if (_isTyping && i == _messages.length) {
                    return _TypingBubble(
                      dot1: _dot1,
                      dot2: _dot2,
                      dot3: _dot3,
                      isDark: isDark,
                    ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.1);
                  }
                  final msg = _messages[i];
                  return _MessageBubble(
                    msg: msg,
                    isDark: isDark,
                  )
                      .animate(delay: i < 5 ? (i * 80).ms : 0.ms)
                      .fadeIn(duration: 300.ms)
                      .slideX(begin: msg.isBot ? -0.1 : 0.1);
                },
              ),
            ),

            // Quick replies
            if (!_isTyping)
              SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _quickReplies.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => GestureDetector(
                    onTap: () {
                      _ctrl.text = _quickReplies[i];
                      _send();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.25)),
                      ),
                      child: Text(
                        _quickReplies[i],
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                      .animate(delay: (i * 60).ms)
                      .fadeIn(duration: 300.ms)
                      .slideX(begin: 0.1),
                ),
              ),
            const SizedBox(height: 8),

            // Input bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkInput
                            : AppColors.inputBg,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _ctrl,
                        onSubmitted: (_) => _send(),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: isDark
                              ? AppColors.darkText
                              : AppColors.textPrimary,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Posez votre question...',
                          filled: false,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _send,
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
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

class _MessageBubble extends StatelessWidget {
  final _Msg msg;
  final bool isDark;
  const _MessageBubble({required this.msg, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isBot = msg.isBot;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (isBot) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
              ),
              child: const Icon(Icons.smart_toy_rounded,
                  color: Colors.white, size: 16),
            ),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isBot
                    ? (isDark ? AppColors.darkCard : Colors.white)
                    : AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isBot ? 4 : 18),
                  bottomRight: Radius.circular(isBot ? 18 : 4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isBot ? Colors.black : AppColors.primary)
                        .withValues(alpha: isBot ? 0.06 : 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                msg.text,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  height: 1.5,
                  color: isBot
                      ? (isDark ? AppColors.darkText : AppColors.textPrimary)
                      : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  final AnimationController dot1, dot2, dot3;
  final bool isDark;
  const _TypingBubble(
      {required this.dot1,
      required this.dot2,
      required this.dot3,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 8),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
            ),
            child: const Icon(Icons.smart_toy_rounded,
                color: Colors.white, size: 16),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [dot1, dot2, dot3].map((ctrl) {
                return AnimatedBuilder(
                  animation: ctrl,
                  builder: (_, _) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 7,
                    height: 7 + ctrl.value * 5,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.6 + ctrl.value * 0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Msg {
  final String text;
  final bool isBot;
  const _Msg(this.text, this.isBot);
}
