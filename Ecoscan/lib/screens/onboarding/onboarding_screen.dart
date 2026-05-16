import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;
  int? _quizAnswer;
  bool _quizSubmitted = false;

  static const _pages = [
    _OBData(
      type: _PageType.intro,
      icon: Icons.qr_code_scanner_rounded,
      bgIcon: Icons.recycling,
      title: 'Scannez & Identifiez',
      subtitle:
          'Photographiez n\'importe quel déchet et notre IA l\'identifie instantanément pour vous indiquer la bonne poubelle.',
      gradient: [Color(0xFF27AE60), Color(0xFF1ABC9C)],
    ),
    _OBData(
      type: _PageType.categories,
      icon: Icons.category_rounded,
      bgIcon: Icons.grid_view_rounded,
      title: 'Les 6 Catégories',
      subtitle: 'Apprenez les 6 grandes familles de déchets pour bien trier.',
      gradient: [Color(0xFF1ABC9C), Color(0xFF3498DB)],
    ),
    _OBData(
      type: _PageType.rewards,
      icon: Icons.emoji_events_rounded,
      bgIcon: Icons.star,
      title: 'Gagnez des Récompenses',
      subtitle:
          'Chaque action éco-responsable vous rapporte des points. Grimpez dans le classement et débloquez des badges exclusifs.',
      gradient: [Color(0xFF9B59B6), Color(0xFF27AE60)],
    ),
    _OBData(
      type: _PageType.quiz,
      icon: Icons.quiz_rounded,
      bgIcon: Icons.lightbulb,
      title: 'Quiz Rapide',
      subtitle: 'Testez vos connaissances avant de commencer !',
      gradient: [Color(0xFFFF6B35), Color(0xFFFFD700)],
    ),
  ];

  void _next() {
    if (_page == _pages.length - 1) {
      context.go('/login');
    } else {
      _controller.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut);
    }
  }

  bool get _canProceed {
    if (_pages[_page].type == _PageType.quiz) return _quizSubmitted;
    return true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final grad = _pages[_page].gradient;

    return Scaffold(
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: grad,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            right: -60,
            top: size.height * 0.05,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Icon(
                _pages[_page].bgIcon,
                key: ValueKey(_page),
                size: 280,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (i) => setState(() {
                    _page = i;
                    _quizAnswer = null;
                    _quizSubmitted = false;
                  }),
                  itemCount: _pages.length,
                  itemBuilder: (_, i) {
                    final data = _pages[i];
                    if (data.type == _PageType.categories) {
                      return _CategoriesPage(data: data);
                    } else if (data.type == _PageType.quiz) {
                      return _QuizPage(
                        data: data,
                        selectedAnswer: _quizAnswer,
                        submitted: _quizSubmitted,
                        onSelect: (a) => setState(() => _quizAnswer = a),
                        onSubmit: () => setState(() => _quizSubmitted = true),
                      );
                    }
                    return _PageContent(data: data);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 48),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == _page ? 28 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: i == _page
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _canProceed ? _next : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: grad[0],
                          disabledBackgroundColor:
                              Colors.white.withValues(alpha: 0.4),
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                          textStyle: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: Text(
                          _page == _pages.length - 1
                              ? 'Commencer'
                              : _pages[_page].type == _PageType.quiz &&
                                      !_quizSubmitted
                                  ? 'Répondre d\'abord'
                                  : 'Suivant',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_page < _pages.length - 1)
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: Text(
                          'Passer',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PageContent extends StatelessWidget {
  final _OBData data;
  const _PageContent({required this.data});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.15),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 40,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: Icon(data.icon, color: Colors.white, size: 80),
            )
                .animate()
                .scale(
                  begin: const Offset(0.5, 0.5),
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 400.ms),
            const SizedBox(height: 48),
            Text(
              data.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.25,
              ),
            )
                .animate()
                .slideY(begin: 0.3, duration: 500.ms, curve: Curves.easeOut)
                .fadeIn(duration: 500.ms, delay: 150.ms),
            const SizedBox(height: 18),
            Text(
              data.subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                color: Colors.white.withValues(alpha: 0.85),
                height: 1.6,
              ),
            )
                .animate()
                .slideY(begin: 0.3, duration: 500.ms, curve: Curves.easeOut)
                .fadeIn(duration: 500.ms, delay: 250.ms),
          ],
        ),
      ),
    );
  }
}

class _CategoriesPage extends StatelessWidget {
  final _OBData data;
  const _CategoriesPage({required this.data});

  static const _cats = [
    ('♻️', 'Plastique', 'Bac jaune'),
    ('📄', 'Papier', 'Bac bleu'),
    ('🍶', 'Verre', 'Bac vert'),
    ('🥫', 'Métal', 'Bac jaune'),
    ('🌿', 'Organique', 'Compost'),
    ('📱', 'DEEE', 'Point collecte'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: Column(
          children: [
            Text(
              data.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 8),
            Text(
              data.subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.0,
                physics: const NeverScrollableScrollPhysics(),
                children: _cats.asMap().entries.map((e) {
                  final i = e.key;
                  final c = e.value;
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(c.$1, style: const TextStyle(fontSize: 28)),
                        const SizedBox(height: 4),
                        Text(
                          c.$2,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          c.$3,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate(delay: (i * 80).ms)
                      .scale(
                        begin: const Offset(0.7, 0.7),
                        duration: 400.ms,
                        curve: Curves.elasticOut,
                      )
                      .fadeIn(duration: 300.ms);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuizPage extends StatelessWidget {
  final _OBData data;
  final int? selectedAnswer;
  final bool submitted;
  final ValueChanged<int> onSelect;
  final VoidCallback onSubmit;

  const _QuizPage({
    required this.data,
    required this.selectedAnswer,
    required this.submitted,
    required this.onSelect,
    required this.onSubmit,
  });

  static const _question = 'Dans quel bac met-on une bouteille en verre ?';
  static const _options = ['Bac jaune', 'Bac vert', 'Bac noir', 'Compost'];
  static const _correct = 1;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Text('🧠', style: TextStyle(fontSize: 40)),
            ).animate().scale(
                  begin: const Offset(0.5, 0.5),
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                ),
            const SizedBox(height: 16),
            Text(
              data.title,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _question,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
            ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: 16),
            ...List.generate(_options.length, (i) {
              final isSelected = selectedAnswer == i;
              final isCorrect = i == _correct;
              Color bg;
              Color border;
              if (!submitted) {
                bg = isSelected
                    ? Colors.white.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.1);
                border = isSelected
                    ? Colors.white.withValues(alpha: 0.8)
                    : Colors.white.withValues(alpha: 0.2);
              } else {
                if (isCorrect) {
                  bg = AppColors.primary.withValues(alpha: 0.4);
                  border = AppColors.primary;
                } else if (isSelected) {
                  bg = AppColors.danger.withValues(alpha: 0.4);
                  border = AppColors.danger;
                } else {
                  bg = Colors.white.withValues(alpha: 0.08);
                  border = Colors.white.withValues(alpha: 0.1);
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: submitted ? null : () => onSelect(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: border, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Text(
                          String.fromCharCode(65 + i),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            _options[i],
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        if (submitted && (isCorrect || isSelected))
                          Icon(
                            isCorrect
                                ? Icons.check_circle_rounded
                                : Icons.cancel_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                ),
              )
                  .animate(delay: (300 + i * 80).ms)
                  .fadeIn(duration: 300.ms)
                  .slideX(begin: -0.1, duration: 300.ms);
            }),
            if (!submitted && selectedAnswer != null) ...[
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFFF6B35),
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Valider',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
            if (submitted) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: (selectedAnswer == _correct
                          ? AppColors.primary
                          : AppColors.danger)
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Text(
                      selectedAnswer == _correct ? '🎉' : '💡',
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        selectedAnswer == _correct
                            ? 'Bravo ! Le verre va bien dans le bac vert.'
                            : 'Pas tout à fait ! Le verre va dans le bac vert.',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).scale(
                    begin: const Offset(0.9, 0.9),
                    duration: 400.ms,
                    curve: Curves.elasticOut,
                  ),
            ],
          ],
        ),
      ),
    );
  }
}

enum _PageType { intro, categories, rewards, quiz }

class _OBData {
  final _PageType type;
  final IconData icon;
  final IconData bgIcon;
  final String title;
  final String subtitle;
  final List<Color> gradient;

  const _OBData({
    required this.type,
    required this.icon,
    required this.bgIcon,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });
}
