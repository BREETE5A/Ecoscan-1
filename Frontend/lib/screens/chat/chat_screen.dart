import 'dart:ui' as ui;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_strings.dart';
import '../../providers/locale_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/chat_message.dart';
import '../../providers/chat_provider.dart';
import '../../providers/challenges_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with TickerProviderStateMixin {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  bool _sending = false;

  late AnimationController _dot1, _dot2, _dot3;

  @override
  void initState() {
    super.initState();
    _dot1 = AnimationController(vsync: this, duration: 600.ms)
      ..repeat(reverse: true);
    _dot2 = AnimationController(vsync: this, duration: 600.ms);
    _dot3 = AnimationController(vsync: this, duration: 600.ms);
    Future.delayed(150.ms, () { if (mounted) _dot2.repeat(reverse: true); });
    Future.delayed(300.ms, () { if (mounted) _dot3.repeat(reverse: true); });
    // Synchronise le message de bienvenue avec la langue actuelle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final lang = ref.read(localeProvider).languageCode;
      ref.read(chatProvider.notifier)
          .updateWelcomeMessage(AppStrings.of(lang).botGreeting);

      // Pre-warm Render : ping silencieux à l'ouverture pour réveiller le serveur
      ref.read(chatServiceProvider).warmUp();

      // Auto-envoie le contexte du scan si disponible (depuis scan_result_screen)
      final pending = ref.read(pendingChatContextProvider);
      if (pending != null && pending.isNotEmpty) {
        ref.read(pendingChatContextProvider.notifier).state = null;
        ref.read(chatProvider.notifier).sendMessage(pending);
      }
    });
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
    if (text.isEmpty || _sending) return;

    _ctrl.clear();
    setState(() => _sending = true);
    _scrollToBottom();

    await ref.read(chatProvider.notifier).sendMessage(text);
    if (!mounted) return;
    ref.read(challengesProvider.notifier).useEcoBot();
    setState(() => _sending = false);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = ref.watch(localeProvider).languageCode;
    final s = AppStrings.of(lang);
    final messages = ref.watch(chatProvider);
    final hasLoading = messages.any((m) => m.isLoading);

    ref.listen(localeProvider, (prev, next) {
      if (prev?.languageCode != next.languageCode) {
        ref.read(chatProvider.notifier)
            .updateWelcomeMessage(AppStrings.of(next.languageCode).botGreeting);
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor:
          isDark ? AppColors.darkBackground : const Color(0xFFF5F5F5),
      body: Column(
        children: [
          _Header(isDark: isDark, s: s, onClear: () {
            ref.read(chatProvider.notifier).clearChat();
          }),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              itemCount: messages.length + (messages.length == 1 ? 1 : 0),
              itemBuilder: (_, i) {
                // Questions suggérées après le message de bienvenue
                if (messages.length == 1 && i == 1) {
                  return _SuggestedQuestions(
                    lang: lang,
                    onTap: (q) {
                      _ctrl.text = q;
                      _send();
                    },
                    isDark: isDark,
                  ).animate(delay: 300.ms).fadeIn(duration: 400.ms);
                }
                final msg = messages[i];
                if (msg.isLoading) {
                  return _TypingBubble(dot1: _dot1, dot2: _dot2, dot3: _dot3,
                          isDark: isDark)
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .slideX(begin: -0.1);
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ChatBubble(msg: msg, isDark: isDark)
                        .animate(delay: i < 6 ? (i * 50).ms : 0.ms)
                        .fadeIn(duration: 300.ms)
                        .slideX(begin: msg.isUser ? 0.1 : -0.1),
                    if (!msg.isUser && !msg.isLoading)
                      _FeedbackRow(
                        msg: msg,
                        isDark: isDark,
                        onFeedback: (liked) => ref
                            .read(chatProvider.notifier)
                            .setFeedback(msg.id, liked),
                      ),
                  ],
                );
              },
            ),
          ),
          _InputBar(
            ctrl: _ctrl,
            sending: _sending || hasLoading,
            isDark: isDark,
            s: s,
            onSend: _send,
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final bool isDark;
  final AppStrings s;
  final VoidCallback onClear;
  const _Header({required this.isDark, required this.s, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 14, 20, 14),
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
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(Icons.smart_toy_rounded,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('EcoBot',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkText : AppColors.textPrimary,
                    )),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(s.online,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        )),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
            onSelected: (v) {
              if (v == 'clear') onClear();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'clear',
                child: Row(children: [
                  const Icon(Icons.delete_outline_rounded,
                      color: Colors.redAccent, size: 20),
                  const SizedBox(width: 10),
                  Text(s.clearConversation,
                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 13)),
                ]),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.05);
  }
}

// ── Chat bubble ───────────────────────────────────────────────────────────────

class _ChatBubble extends StatelessWidget {
  final ChatMessage msg;
  final bool isDark;
  const _ChatBubble({required this.msg, required this.isDark});

  bool _hasArabic(String text) =>
      text.contains(RegExp(r'[؀-ۿ]'));

  @override
  Widget build(BuildContext context) {
    final isBot = !msg.isUser;
    final timeStr = DateFormat('HH:mm').format(msg.timestamp);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment:
            isBot ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Row(
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
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
                  child: Directionality(
                    textDirection: _hasArabic(msg.text)
                        ? ui.TextDirection.rtl
                        : ui.TextDirection.ltr,
                    child: _RichMessageText(
                      text: msg.text,
                      isBot: isBot,
                      isDark: isDark,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
                left: isBot ? 48 : 0, right: isBot ? 0 : 4, top: 4),
            child: Text(
              timeStr,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                color: isDark
                    ? AppColors.darkTextSecondary.withValues(alpha: 0.6)
                    : AppColors.textLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Rich message text (URLs + téléphones + emails + domaines cliquables) ──────

class _RichMessageText extends StatelessWidget {
  final String text;
  final bool isBot;
  final bool isDark;
  const _RichMessageText({required this.text, required this.isBot, required this.isDark});

  // Numéros d'urgence courts marocains (officiels vérifiés)
  static final _emergencyRegex = RegExp(
    r'\b(15|19|112|141|150|177|190|2511|08000\s?8888)\b',
  );

  // Ordre : numéros urgence courts > email > url > tel international > marocain 10 chiffres > domaine
  static final _linkRegex = RegExp(
    r'(\b(?:15|19|112|141|150|177|190|2511|08000\s?8888)\b'           // urgences courtes
    r'|[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}'            // email
    r'|https?://[^\s()\[\]<>"]+'                                       // http(s)://
    r'|www\.[^\s()\[\]<>"]+'                                           // www.
    r'|\+[0-9]{6,15}(?:[\s\-][0-9]{2,6}){0,4}'                       // +XX... international
    r'|00[0-9]{6,14}'                                                  // 00XX...
    r'|0[5-9][0-9]{2}[\s\-]?[0-9]{2}[\s\-]?[0-9]{2}[\s\-]?[0-9]{2}' // 0XXX XX XX XX (10 chiffres)
    r'|(?<![0-9@.])\b[a-zA-Z][a-zA-Z0-9\-]*\.(?:ma|com|org|net|io)\b(?:/[^\s()\[\]<>"]*)?)', // domaine nu
    caseSensitive: false,
  );

  // Supprime la ponctuation finale résiduelle
  static final _trailingPunct = RegExp(r'[.,!?:;)\]>}"»]+$');
  static String _clean(String s) => s.replaceAll(_trailingPunct, '').trim();

  bool _isEmail(String s)    => s.contains('@') && !s.startsWith('http');
  bool _isEmergency(String s) => _emergencyRegex.hasMatch(s.trim());
  bool _isDomain(String s)   => !s.contains('@') && !s.startsWith('http') && !s.startsWith('+') && !RegExp(r'^\d').hasMatch(s);

  Future<void> _launch(String raw) async {
    final url = _clean(raw);

    // ── Numéro d'urgence court (15, 150, 19, 177…) ────────────────────────
    if (_isEmergency(url)) {
      final digits = url.replaceAll(RegExp(r'\s'), '');
      final uri = Uri.parse('tel:$digits');
      if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }

    // ── Email ──────────────────────────────────────────────────────────────
    if (_isEmail(url)) {
      final uri = Uri.parse('mailto:$url');
      if (await canLaunchUrl(uri)) await launchUrl(uri);
      return;
    }

    // ── Téléphone long ─────────────────────────────────────────────────────
    final digits = url.replaceAll(RegExp(r'[\s\-\.\(\)]'), '');
    if (digits.startsWith('+')) {
      final uri = Uri.parse('tel:$digits');
      if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
    if (digits.startsWith('00')) {
      final uri = Uri.parse('tel:+${digits.substring(2)}');
      if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
    if (RegExp(r'^0[5-9]').hasMatch(digits)) {
      final uri = Uri.parse('tel:+212${digits.substring(1)}');
      if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }

    // ── URL / Domaine ──────────────────────────────────────────────────────
    final webUrl = url.startsWith('http') ? url : 'https://$url';
    final uri = Uri.parse(webUrl);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String _displayLabel(String raw) {
    final s = _clean(raw);
    if (_isEmail(s)) return '✉ $s';
    if (_isEmergency(s)) return '📞 $s';
    if (_isDomain(s) && !s.startsWith('www')) return '🌐 $s';
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = isBot
        ? (isDark ? AppColors.darkText : AppColors.textPrimary)
        : Colors.white;
    final linkColor = isBot ? AppColors.primary : Colors.white70;

    final baseStyle = TextStyle(
      fontFamily: 'Poppins', fontSize: 13, height: 1.55, color: baseColor,
    );
    final linkStyle = baseStyle.copyWith(
      color: linkColor,
      decoration: TextDecoration.underline,
      decorationColor: linkColor,
      fontWeight: FontWeight.w600,
    );

    final spans = <InlineSpan>[];
    int cursor = 0;
    for (final m in _linkRegex.allMatches(text)) {
      if (m.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, m.start), style: baseStyle));
      }
      // Texte affiché et URL lancée sans ponctuation finale
      final raw          = m.group(0)!;
      final display      = _displayLabel(raw);
      final cleanedLen   = _clean(raw).length;
      final trailingLen  = raw.length - cleanedLen;
      spans.add(TextSpan(
        text: display,
        style: linkStyle,
        recognizer: TapGestureRecognizer()..onTap = () => _launch(raw),
      ));
      // Restitue la ponctuation finale en texte normal
      if (trailingLen > 0) {
        spans.add(TextSpan(
          text: raw.substring(raw.length - trailingLen),
          style: baseStyle,
        ));
      }
      cursor = m.end;
    }
    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor), style: baseStyle));
    }

    return RichText(text: TextSpan(children: spans));
  }
}

// ── Typing indicator ──────────────────────────────────────────────────────────

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
      padding: const EdgeInsets.only(bottom: 12),
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
            child:
                const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 16),
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
                    color: Colors.black.withValues(alpha: 0.06), blurRadius: 8),
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
                      color: AppColors.primary
                          .withValues(alpha: 0.5 + ctrl.value * 0.5),
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

// ── Input bar ─────────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  final TextEditingController ctrl;
  final bool sending;
  final bool isDark;
  final AppStrings s;
  final VoidCallback onSend;
  const _InputBar(
      {required this.ctrl,
      required this.sending,
      required this.isDark,
      required this.s,
      required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                color: isDark ? AppColors.darkInput : AppColors.inputBg,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: ctrl,
                enabled: !sending,
                onSubmitted: (_) => onSend(),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: isDark ? AppColors.darkText : AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: sending ? s.botThinking : s.typeMessage,
                  hintStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: isDark
                        ? AppColors.darkTextSecondary.withValues(alpha: 0.5)
                        : AppColors.textLight,
                  ),
                  filled: false,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: sending ? null : onSend,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: sending
                    ? const LinearGradient(
                        colors: [Colors.grey, Colors.grey])
                    : AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: sending
                    ? []
                    : [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
              ),
              child: sending
                  ? const Padding(
                      padding: EdgeInsets.all(13),
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded,
                      color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Questions suggérées ───────────────────────────────────────────────────────

class _SuggestedQuestions extends StatelessWidget {
  final String lang;
  final void Function(String) onTap;
  final bool isDark;
  const _SuggestedQuestions({required this.lang, required this.onTap, required this.isDark});

  List<String> get _questions {
    switch (lang) {
      case 'en':
        return [
          'Where to put plastic bottles?',
          'How to change my password?',
          'ECOVAL contact number?',
          'How to recycle electronics?',
          'Where to see my recycling stats?',
          'How to compost at home?',
        ];
      case 'ar':
        return [
          'أين أضع زجاجات البلاستيك؟',
          'كيف أغير كلمة المرور؟',
          'رقم هاتف ECOVAL؟',
          'كيف أعيد تدوير الأجهزة الإلكترونية؟',
          'أين أرى إحصائياتي؟',
          'كيف أصنع سمادًا منزليًا؟',
        ];
      case 'es':
        return [
          '¿Dónde poner las botellas de plástico?',
          '¿Cómo cambiar mi contraseña?',
          '¿Número de contacto de ECOVAL?',
          '¿Cómo reciclar aparatos electrónicos?',
          '¿Dónde ver mis estadísticas?',
          '¿Cómo hacer compost en casa?',
        ];
      default:
        return [
          'Où mettre les bouteilles plastiques ?',
          'Comment changer mon mot de passe ?',
          'Numéro de contact ECOVAL ?',
          'Comment recycler les appareils électroniques ?',
          'Où voir mes statistiques de recyclage ?',
          'Comment composter à la maison ?',
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 48, bottom: 8),
            child: Text(
              lang == 'en' ? 'Suggested questions' :
              lang == 'ar' ? 'أسئلة مقترحة' :
              lang == 'es' ? 'Preguntas sugeridas' : 'Questions fréquentes',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _questions.map((q) => GestureDetector(
              onTap: () => onTap(q),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  q,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: AppColors.primary,
                  ),
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

// ── Feedback 👍/👎 ────────────────────────────────────────────────────────────

class _FeedbackRow extends StatelessWidget {
  final ChatMessage msg;
  final bool isDark;
  final void Function(bool) onFeedback;
  const _FeedbackRow({required this.msg, required this.isDark, required this.onFeedback});

  @override
  Widget build(BuildContext context) {
    if (msg.text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(left: 48, bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _FeedbackBtn(
            icon: Icons.thumb_up_rounded,
            active: msg.feedback == true,
            activeColor: AppColors.primary,
            isDark: isDark,
            onTap: () => onFeedback(true),
          ),
          const SizedBox(width: 6),
          _FeedbackBtn(
            icon: Icons.thumb_down_rounded,
            active: msg.feedback == false,
            activeColor: AppColors.danger,
            isDark: isDark,
            onTap: () => onFeedback(false),
          ),
        ],
      ),
    );
  }
}

class _FeedbackBtn extends StatelessWidget {
  final IconData icon;
  final bool active;
  final Color activeColor;
  final bool isDark;
  final VoidCallback onTap;
  const _FeedbackBtn({required this.icon, required this.active,
      required this.activeColor, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: active
              ? activeColor.withValues(alpha: 0.12)
              : (isDark ? AppColors.darkCard : Colors.white),
          shape: BoxShape.circle,
          border: Border.all(
            color: active
                ? activeColor.withValues(alpha: 0.5)
                : AppColors.textSecondary.withValues(alpha: 0.2),
          ),
        ),
        child: Icon(
          icon,
          size: 14,
          color: active ? activeColor : AppColors.textSecondary,
        ),
      ),
    );
  }
}
