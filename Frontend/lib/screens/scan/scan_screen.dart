import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../l10n/app_strings.dart';
import '../../providers/locale_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/scan_entry.dart';
import '../../models/scan_result_model.dart';
import '../../providers/scan_history_provider.dart';
import '../../providers/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/n8n_service.dart';
import '../../providers/challenges_provider.dart';
import '../../services/classifier_service.dart';
import '../../services/scan_api_service.dart';

enum _DetectionState { idle, analyzing, recyclable, dangerous }


class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen>
    with TickerProviderStateMixin {
  late AnimationController _scanLine;
  late AnimationController _pulse;
  late AnimationController _ripple;
  late AnimationController _flash;
  late AnimationController _frameColor;

  late Animation<double> _scanLineAnim;
  late Animation<double> _pulseAnim;
  late Animation<double> _rippleAnim;
  late Animation<double> _flashAnim;

  bool _scanning = false;
  bool _torchOn = false;
  _DetectionState _state = _DetectionState.idle;

  CameraController? _cameraCtrl;
  bool _cameraReady = false;
  String? _cameraError;
  File? _galleryImage;

  final _classifier = ClassifierService();
  bool _modelLoaded = false;
  Timer? _tipTimer;
  int _tipIndex = 0;

  Color get _frameColorValue {
    switch (_state) {
      case _DetectionState.recyclable:
        return AppColors.primary;
      case _DetectionState.dangerous:
        return const Color(0xFFE74C3C);
      case _DetectionState.analyzing:
        return AppColors.accent;
      case _DetectionState.idle:
        return AppColors.primaryLight;
    }
  }

  String _statusLabelStr(AppStrings s) {
    if (!_modelLoaded) return '⏳  ${s.loadingModel}';
    switch (_state) {
      case _DetectionState.recyclable:
        return '♻️  ${s.recyclableDetected}';
      case _DetectionState.dangerous:
        return '⚠️  ${s.dangerousWaste}';
      case _DetectionState.analyzing:
        return '🔍  ${s.analyzing}';
      case _DetectionState.idle:
        return _galleryImage != null ? s.imageLoaded : s.centerWaste;
    }
  }

  @override
  void initState() {
    super.initState();

    _scanLine = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _pulse = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);
    _ripple = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat();
    _flash =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _frameColor =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 400));

    _scanLineAnim = Tween(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _scanLine, curve: Curves.easeInOut));
    _pulseAnim = Tween(begin: 0.98, end: 1.02)
        .animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
    _rippleAnim = Tween(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _ripple, curve: Curves.easeOut));
    _flashAnim = Tween(begin: 0.0, end: 0.6)
        .animate(CurvedAnimation(parent: _flash, curve: Curves.easeIn));

    _initCamera();
    _loadModel();
    // Pré-chauffe le backend Render.com (fire & forget)
    ScanApiService.isAvailable();
  }

  Future<void> _loadModel() async {
    try {
      await _classifier.load();
      if (mounted) setState(() => _modelLoaded = true);
    } catch (e) {
      if (kDebugMode) debugPrint('TFLite load error: $e');
      if (mounted) {
        setState(() => _modelLoaded = false);
        final s = AppStrings.of(ref.read(localeProvider).languageCode);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(s.modelLoadError(e.toString()),
                style: const TextStyle(fontFamily: 'Poppins')),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        final s = AppStrings.of(ref.read(localeProvider).languageCode);
        setState(() => _cameraError = s.noCameraAvailable);
        return;
      }
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final ctrl = CameraController(back, ResolutionPreset.high,
          enableAudio: false, imageFormatGroup: ImageFormatGroup.jpeg);
      await ctrl.initialize();
      if (!mounted) {
        ctrl.dispose();
        return;
      }
      setState(() {
        _cameraCtrl = ctrl;
        _cameraReady = true;
      });
    } catch (_) {
      if (mounted) {
        final s = AppStrings.of(ref.read(localeProvider).languageCode);
        setState(() => _cameraError = s.noCameraAvailable);
      }
    }
  }

  Future<void> _toggleTorch() async {
    if (_cameraCtrl == null || !_cameraReady) return;
    final next = !_torchOn;
    try {
      await _cameraCtrl!.setFlashMode(next ? FlashMode.torch : FlashMode.off);
      setState(() => _torchOn = next);
    } catch (_) {}
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null || !mounted) return;
    setState(() {
      _galleryImage = File(picked.path);
      _state = _DetectionState.idle;
    });
    _triggerScan();
  }

  void _showError(String msg) {
    if (!mounted) return;
    setState(() {
      _scanning = false;
      _state = _DetectionState.idle;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'Poppins')),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _startScanTips() {
    _tipIndex = 0;
    _tipTimer = Timer.periodic(const Duration(milliseconds: 1800), (_) {
      if (mounted) setState(() => _tipIndex = (_tipIndex + 1) % 4);
    });
  }

  void _stopScanTips() {
    _tipTimer?.cancel();
    _tipTimer = null;
  }

  void _showOfflineSnackbar(AppStrings s) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(s.offlineFallback,
              style: const TextStyle(fontFamily: 'Poppins'))),
        ]),
        backgroundColor: Colors.orange.shade700,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<ScanEntry?> _classifyLocal(File image, String lang, AppStrings s) async {
    if (!_modelLoaded) {
      _showError(s.modelNotLoaded);
      return null;
    }
    try {
      final localResult = await _classifier.classify(image);
      final syntheticComponents = [
        ScanComponent(
          partie: s.detectedObject,
          label: localResult.label,
          binColor: ScanEntry.binColorForLabel(localResult.label),
          conseil: '',
        ),
      ];
      return ScanEntry.fromClassification(
        localResult.label, localResult.confidence,
        lang: lang,
        components: syntheticComponents,
      );
    } catch (e) {
      _showError(s.analysisError(e.toString()));
      return null;
    }
  }

  Future<void> _triggerScan() async {
    if (_scanning) return;

    final s = AppStrings.of(ref.read(localeProvider).languageCode);

    setState(() {
      _scanning = true;
      _state = _DetectionState.analyzing;
    });
    _startScanTips();

    File? imageToClassify = _galleryImage;

    if (imageToClassify == null && _cameraReady && _cameraCtrl != null) {
      try {
        final xFile = await _cameraCtrl!.takePicture();
        imageToClassify = File(xFile.path);
      } catch (e) {
        _showError(s.captureError(e.toString()));
        return;
      }
    }

    if (imageToClassify == null) {
      _showError(s.noImageAvailable);
      return;
    }

    final lang = ref.read(localeProvider).languageCode;
    ScanEntry entry;
    try {
      // ── Étape 1 : API online YOLOv8 (priorité) ────────────────────────────
      final onlineResult = await ScanApiService.classify(imageToClassify, lang: lang);

      if (onlineResult != null && onlineResult.topLabel != 'unknown') {
        final base = ScanEntry.fromClassification(
          onlineResult.topLabel, onlineResult.topConfidence,
          lang: lang, components: onlineResult.components,
        );
        entry = ScanEntry(
          id: base.id, name: base.name, category: base.category,
          recyclable: base.recyclable, dangerous: base.dangerous,
          points: base.points, co2Saved: base.co2Saved,
          recyclability: base.recyclability, binColor: base.binColor,
          scannedAt: base.scannedAt, mode: 'cloud',
          components: base.components,
        );
        // Alerte email si une composante est électronique ou dangereuse
        final dangerComp = onlineResult.components.where(
          (c) => c.label == 'electronique' || c.label == 'dangereux',
        ).toList();
        if (dangerComp.isNotEmpty) {
          final fbUser = FirebaseAuth.instance.currentUser;
          N8nService.alerteDanger(
            nom:        ref.read(userProvider).name,
            email:      fbUser?.email ?? '',
            typeDechet: dangerComp.map((c) => c.label).join(', '),
            fcmToken:   '',
          );
        }
      } else {
        _showOfflineSnackbar(s);
        final localEntry = await _classifyLocal(imageToClassify, lang, s);
        if (localEntry == null) { _stopScanTips(); return; }
        entry = localEntry;
      }
    } catch (e) {
      _showOfflineSnackbar(s);
      final localEntry = await _classifyLocal(imageToClassify, lang, s);
      if (localEntry == null) { _stopScanTips(); return; }
      entry = localEntry;
    }

    _stopScanTips();
    final nextState =
        entry.dangerous ? _DetectionState.dangerous : _DetectionState.recyclable;

    if (!mounted) return;
    setState(() => _state = nextState);

    await _flash.forward();
    await _flash.reverse();
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // Affiche le résultat immédiatement
    ref.read(scanHistoryProvider.notifier).addScan(entry);
    ref.read(currentScanProvider.notifier).state = entry;

    setState(() {
      _scanning = false;
      _state = _DetectionState.idle;
      _galleryImage = null;
    });

    context.push('/scan/result');

    // Mise à jour Firestore en arrière-plan (ne bloque pas la navigation)
    final scanResult = ScanResultModel(
      rawClass: entry.category,
      category: entry.category,
      binColor: entry.binColor,
      confidence: entry.recyclability,
      co2SavedPerKg: entry.co2Saved / 1000,
      scannedAt: entry.scannedAt,
    );
    ref.read(userProvider.notifier).recordScan(scanResult)
        .catchError((e) { if (kDebugMode) debugPrint('recordScan error: $e'); });
    ref.read(challengesProvider.notifier).incrementScan();
  }

  @override
  void dispose() {
    _scanLine.dispose();
    _pulse.dispose();
    _ripple.dispose();
    _flash.dispose();
    _frameColor.dispose();
    _cameraCtrl?.dispose();
    _classifier.close();
    _tipTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(ref.watch(localeProvider).languageCode);
    final size = MediaQuery.of(context).size;
    final frameWidth = size.width * 0.85;
    final frameHeight = frameWidth * 1.3;
    final frameCol = _frameColorValue;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera / gallery preview
          if (_cameraReady && _cameraCtrl != null)
            Positioned.fill(
              child: _galleryImage != null
                  ? Image.file(_galleryImage!, fit: BoxFit.cover)
                  : CameraPreview(_cameraCtrl!),
            )
          else
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0A1628), Color(0xFF0D2B1F), Color(0xFF0A1628)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: _cameraError != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.no_photography_rounded,
                              color: Colors.white54, size: 64),
                          const SizedBox(height: 12),
                          Text(_cameraError!,
                              style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors.white54,
                                  fontSize: 14)),
                        ],
                      ),
                    )
                  : Center(
                      child: Opacity(
                        opacity: 0.06,
                        child: Icon(Icons.recycling_rounded,
                            size: 200, color: AppColors.primary),
                      ),
                    ),
            ),

          if (_cameraReady)
            Container(color: Colors.black.withValues(alpha: 0.2)),

          // Dark overlay with frame cutout
          AnimatedBuilder(
            animation: _rippleAnim,
            builder: (_, _) => CustomPaint(
              painter: _OverlayPainter(
                frameWidth: frameWidth,
                frameHeight: frameHeight,
                center: Offset(size.width / 2, size.height / 2 - 40),
                frameColor: frameCol,
              ),
              size: size,
            ),
          ),

          // Ripple rings
          Center(
            child: Transform.translate(
              offset: const Offset(0, -40),
              child: AnimatedBuilder(
                animation: _rippleAnim,
                builder: (_, _) => CustomPaint(
                  painter: _RipplePainter(_rippleAnim.value, frameCol),
                  size: Size(frameHeight + 80, frameHeight + 80),
                ),
              ),
            ),
          ),

          // Scanner frame
          Center(
            child: Transform.translate(
              offset: const Offset(0, -40),
              child: AnimatedBuilder(
                animation: _pulseAnim,
                builder: (_, child) =>
                    Transform.scale(scale: _pulseAnim.value, child: child),
                child: SizedBox(
                  width: frameWidth,
                  height: frameHeight,
                  child: Stack(
                    children: [
                      if (_state != _DetectionState.recyclable &&
                          _state != _DetectionState.dangerous)
                        AnimatedBuilder(
                          animation: _scanLineAnim,
                          builder: (_, _) => Positioned(
                            top: 10 + (frameHeight - 20) * _scanLineAnim.value,
                            left: 10,
                            right: 10,
                            child: Container(
                              height: 2,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [
                                  Colors.transparent,
                                  frameCol.withValues(alpha: 0.9),
                                  frameCol,
                                  frameCol.withValues(alpha: 0.9),
                                  Colors.transparent,
                                ]),
                              ),
                            ),
                          ),
                        ),
                      if (_state == _DetectionState.recyclable ||
                          _state == _DetectionState.dangerous)
                        Positioned.fill(
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: frameCol.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: frameCol.withValues(alpha: 0.5),
                                  width: 2),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _state == _DetectionState.recyclable
                                        ? Icons.recycling_rounded
                                        : Icons.warning_amber_rounded,
                                    color: frameCol,
                                    size: 60,
                                  )
                                      .animate(
                                          onPlay: (c) => c.repeat(reverse: true))
                                      .scale(
                                          begin: const Offset(0.9, 0.9),
                                          end: const Offset(1.1, 1.1),
                                          duration: 600.ms),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: frameCol.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _state == _DetectionState.recyclable
                                          ? s.recyclableLabel
                                          : s.dangerousLabel,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: frameCol,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ).animate().fadeIn(duration: 300.ms),
                        ),
                      ..._corners(frameWidth, frameCol),

                      // ── Analyse tips (cycling text at bottom of frame) ──
                      if (_state == _DetectionState.analyzing)
                        Positioned(
                          bottom: 12,
                          left: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 350),
                              transitionBuilder: (child, anim) =>
                                  FadeTransition(opacity: anim, child: child),
                              child: Text(
                                s.scanTips[_tipIndex],
                                key: ValueKey(_tipIndex),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),

                      // ── Pulsing dots at top of frame during analysis ──
                      if (_state == _DetectionState.analyzing)
                        Positioned(
                          top: 14,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              3,
                              (i) => Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 4),
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: frameCol,
                                  shape: BoxShape.circle,
                                ),
                              )
                                  .animate(
                                    delay: (i * 220).ms,
                                    onPlay: (c) =>
                                        c.repeat(reverse: true),
                                  )
                                  .scaleXY(
                                    begin: 0.5,
                                    end: 1.5,
                                    duration: 500.ms,
                                    curve: Curves.easeInOut,
                                  )
                                  .fadeIn(duration: 300.ms),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Flash overlay
          AnimatedBuilder(
            animation: _flashAnim,
            builder: (_, _) => Opacity(
              opacity: _flashAnim.value,
              child: Container(color: Colors.white),
            ),
          ),


          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.push('/home'),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded,
                          color: Colors.white, size: 22),
                    ),
                  ),
                  Text(
                    s.scanDechet,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                  GestureDetector(
                    onTap: _toggleTorch,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _torchOn
                            ? AppColors.accent.withValues(alpha: 0.3)
                            : Colors.white.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _torchOn
                            ? Icons.flash_on_rounded
                            : Icons.flash_off_rounded,
                        color: _torchOn ? AppColors.accentLight : Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),

          // Bottom panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 48),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _frameColorValue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: _frameColorValue.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      _statusLabelStr(s),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _frameColorValue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Shutter button
                  GestureDetector(
                    onTap: _triggerScan,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: _scanning
                              ? [_frameColorValue, _frameColorValue]
                              : [AppColors.primary, AppColors.teal],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _frameColorValue.withValues(alpha: 0.5),
                            blurRadius: 24,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: _scanning
                          ? const Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Icon(Icons.camera_alt_rounded,
                              color: Colors.white, size: 32),
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(
                        begin: const Offset(1, 1),
                        end: const Offset(1.06, 1.06),
                        duration: 1200.ms,
                        curve: Curves.easeInOut,
                      ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _BottomAction(
                        icon: Icons.photo_library_outlined,
                        label: s.gallery,
                        onTap: _pickFromGallery,
                      ),
                      _BottomAction(
                        icon: Icons.history_rounded,
                        label: s.history_,
                        onTap: () => context.push('/history'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.1),
        ],
      ),
    );
  }

  List<Widget> _corners(double size, Color color) {
    const len = 28.0;
    const thick = 3.5;
    const r = 6.0;

    Widget corner(Alignment align, bool flipX, bool flipY) => Align(
          alignment: align,
          child: Transform.scale(
            scaleX: flipX ? -1 : 1,
            scaleY: flipY ? -1 : 1,
            child: SizedBox(
              width: len + thick,
              height: len + thick,
              child: CustomPaint(
                  painter: _CornerPainter(
                      color: color, length: len, thick: thick, radius: r)),
            ),
          ),
        );

    return [
      corner(Alignment.topLeft, false, false),
      corner(Alignment.topRight, true, false),
      corner(Alignment.bottomLeft, false, true),
      corner(Alignment.bottomRight, true, true),
    ];
  }
}

// ── Painters & helpers ────────────────────────────────────────────────────────

class _CornerPainter extends CustomPainter {
  final Color color;
  final double length, thick, radius;
  const _CornerPainter(
      {required this.color,
      required this.length,
      required this.thick,
      required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thick
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(0, length)
      ..lineTo(0, radius)
      ..arcToPoint(Offset(radius, 0), radius: Radius.circular(radius))
      ..lineTo(length, 0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) => old.color != color;
}

class _OverlayPainter extends CustomPainter {
  final double frameWidth;
  final double frameHeight;
  final Offset center;
  final Color frameColor;
  _OverlayPainter(
      {required this.frameWidth,
      required this.frameHeight,
      required this.center,
      required this.frameColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.65);
    final frameRect =
        Rect.fromCenter(center: center, width: frameWidth, height: frameHeight);
    final path = Path.combine(
      PathOperation.difference,
      Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
      Path()
        ..addRRect(
            RRect.fromRectAndRadius(frameRect, const Radius.circular(16))),
    );
    canvas.drawPath(path, paint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(frameRect, const Radius.circular(16)),
      Paint()
        ..color = frameColor.withValues(alpha: 0.4)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_OverlayPainter old) =>
      old.frameColor != frameColor ||
      old.center != center ||
      old.frameWidth != frameWidth ||
      old.frameHeight != frameHeight;
}

class _RipplePainter extends CustomPainter {
  final double progress;
  final Color color;
  _RipplePainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (int i = 0; i < 3; i++) {
      final p = (progress + i / 3) % 1.0;
      canvas.drawCircle(
        center,
        130.0 + p * 70,
        Paint()
          ..color = color.withValues(alpha: (1 - p) * 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(_RipplePainter old) =>
      old.progress != progress || old.color != color;
}

class _BottomAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _BottomAction(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.7))),
        ],
      ),
    );
  }
}
