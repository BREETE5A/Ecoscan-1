// Champ de texte réutilisable avec shake, bordure erreur animée et message slide-down
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? errorText;      // null = pas d'erreur
  final bool shake;             // déclenche le shake quand true
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final bool isDark;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.errorText,
    this.shake = false,
    this.onChanged,
    this.validator,
    this.isDark = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with TickerProviderStateMixin {          // ✅ CORRECTION ICI
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  // Couleur de bordure animée
  late AnimationController _borderCtrl;
  late Animation<Color?> _borderColor;

  @override
  void initState() {
    super.initState();

    // Shake horizontal (5 oscillations)
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeInOut));

    // Transition rouge ↔ transparent pour la bordure
    _borderCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _borderColor = ColorTween(
      begin: Colors.transparent,
      end: AppColors.danger,
    ).animate(CurvedAnimation(parent: _borderCtrl, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(CustomTextField old) {
    super.didUpdateWidget(old);
    // Déclencher shake + bordure rouge si une erreur vient d'apparaître
    if (widget.shake && !old.shake) {
      _shakeCtrl.forward(from: 0);
      _borderCtrl.forward(from: 0);
    }
    if (widget.errorText == null && old.errorText != null) {
      _borderCtrl.reverse();
    }
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    _borderCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return AnimatedBuilder(
      animation: Listenable.merge([_shakeAnim, _borderColor]),
      builder: (_, child) => Transform.translate(
        offset: Offset(_shakeAnim.value, 0),
        child: child,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Text(
            widget.label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: widget.isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),

          // Champ avec bordure animée
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: hasError
                    ? (_borderColor.value ?? AppColors.danger)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: TextFormField(
              controller: widget.controller,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              onChanged: widget.onChanged,
              validator: widget.validator,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: widget.isDark ? AppColors.darkText : AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                prefixIcon: Icon(
                  widget.prefixIcon,
                  color: hasError
                      ? AppColors.danger
                      : (widget.isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary),
                  size: 20,
                ),
                suffixIcon: hasError
                    ? _ErrorIcon(show: hasError)
                    : widget.suffixIcon,
                filled: true,
                fillColor: widget.isDark
                    ? AppColors.darkInput
                    : AppColors.inputBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: hasError ? AppColors.danger : AppColors.primary,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 16),
              ),
            ),
          ),

          // Message d'erreur slide-down
          _ErrorMessage(message: widget.errorText, isDark: widget.isDark),
        ],
      ),
    );
  }
}

// Icône erreur avec ScaleTransition
class _ErrorIcon extends StatefulWidget {
  final bool show;
  const _ErrorIcon({required this.show});
  @override
  State<_ErrorIcon> createState() => _ErrorIconState();
}

class _ErrorIconState extends State<_ErrorIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    if (widget.show) _ctrl.forward();
  }

  @override
  void didUpdateWidget(_ErrorIcon old) {
    super.didUpdateWidget(old);
    widget.show ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScaleTransition(
        scale: _scale,
        child: const Icon(Icons.error_outline_rounded,
            color: AppColors.danger, size: 20),
      );
}

// Message slide-down animé
class _ErrorMessage extends StatefulWidget {
  final String? message;
  final bool isDark;
  const _ErrorMessage({required this.message, required this.isDark});
  @override
  State<_ErrorMessage> createState() => _ErrorMessageState();
}

class _ErrorMessageState extends State<_ErrorMessage>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _slide;
  late Animation<double> _fade;
  String _last = '';

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _slide = Tween(begin: -8.0, end: 0.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    if (widget.message != null) {
      _last = widget.message!;
      _ctrl.forward();
    }
  }

  @override
  void didUpdateWidget(_ErrorMessage old) {
    super.didUpdateWidget(old);
    if (widget.message != null && widget.message!.isNotEmpty) {
      _last = widget.message!;
      _ctrl.forward();
    } else {
      _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _ctrl,
        builder: (_, _) => _ctrl.value == 0
            ? const SizedBox.shrink()
            : Transform.translate(
                offset: Offset(0, _slide.value),
                child: Opacity(
                  opacity: _fade.value,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6, left: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            size: 12, color: AppColors.danger),
                        const SizedBox(width: 4),
                        Text(
                          _last,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            color: AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      );
}