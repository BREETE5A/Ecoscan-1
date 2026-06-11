import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_strings.dart';
import '../../models/listing_model.dart';
import '../../providers/locale_provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../theme/app_theme.dart';
import 'marketplace_screen.dart' show typeColor, typeLabel;

class ListingDetailScreen extends ConsumerStatefulWidget {
  final String listingId;
  const ListingDetailScreen({super.key, required this.listingId});

  @override
  ConsumerState<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends ConsumerState<ListingDetailScreen> {
  int _photoIndex = 0;

  @override
  Widget build(BuildContext context) {
    final lang   = ref.watch(localeProvider).languageCode;
    final s      = AppStrings.of(lang);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final listings = ref.watch(marketplaceProvider).valueOrNull ?? [];
    final listing  = listings.cast<ListingModel?>()
        .firstWhere((l) => l?.id == widget.listingId, orElse: () => null);

    if (listing == null) {
      return Scaffold(
        appBar: AppBar(title: Text(s.marketplaceTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final color   = typeColor(listing.type);
    final actions = ref.read(marketplaceActionsProvider);
    final isOwner = actions.isOwner(listing.userId);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          // ── AppBar photo ──────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: color,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 16),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (isOwner)
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.delete_outline_rounded,
                        color: Colors.white, size: 18),
                  ),
                  onPressed: () => _confirmDelete(context, ref, listing, s),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: listing.imageUrls.isNotEmpty
                  ? _PhotoCarousel(
                      urls: listing.imageUrls,
                      index: _photoIndex,
                      onChanged: (i) => setState(() => _photoIndex = i),
                    )
                  : _placeholder(color),
            ),
          ),

          // ── Contenu ───────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges
                  Row(children: [
                    _badge(typeLabel(listing.type, s), color, filled: true),
                    const SizedBox(width: 8),
                    _badge(listing.category, color),
                    if (listing.trustedSeller) ...[
                      const SizedBox(width: 8),
                      _badge(s.trustedSellerLabel, const Color(0xFFFFD700), filled: true),
                    ],
                  ]).animate().fadeIn(duration: 400.ms),
                  const SizedBox(height: 12),

                  // Titre
                  Text(listing.title,
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkText : AppColors.textPrimary))
                      .animate().fadeIn(duration: 400.ms, delay: 60.ms),
                  const SizedBox(height: 8),

                  // Prix
                  (listing.type == 'vente' && listing.price != null
                      ? Text('${listing.price!.round()} DH',
                          style: TextStyle(fontFamily: 'Poppins', fontSize: 26,
                              fontWeight: FontWeight.bold, color: color))
                      : Text(listing.type == 'don' ? s.freeLabel : s.swapLabel,
                          style: TextStyle(fontFamily: 'Poppins', fontSize: 18,
                              fontWeight: FontWeight.bold, color: color)))
                      .animate().fadeIn(duration: 400.ms, delay: 100.ms),
                  const SizedBox(height: 16),

                  // Description
                  if (listing.description.isNotEmpty) ...[
                    _card(isDark, child: Text(listing.description,
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 14,
                            height: 1.55,
                            color: isDark ? AppColors.darkTextSecondary
                                : AppColors.textSecondary)))
                        .animate().fadeIn(duration: 400.ms, delay: 140.ms),
                    const SizedBox(height: 12),
                  ],

                  // Infos vendeur
                  _card(isDark, child: Column(children: [
                    _infoRow(Icons.person_outline_rounded, listing.userName, isDark),
                    const Divider(height: 14),
                    _infoRow(Icons.location_on_outlined, listing.city, isDark),
                    const Divider(height: 14),
                    _infoRow(Icons.access_time_rounded, _fmtDate(listing.createdAt), isDark),
                    if (listing.reviewCount > 0) ...[
                      const Divider(height: 14),
                      Row(children: [
                        ...List.generate(5, (i) => Icon(
                          i < listing.reviewAvg.round()
                              ? Icons.star_rounded : Icons.star_border_rounded,
                          size: 16, color: const Color(0xFFFFD700))),
                        const SizedBox(width: 6),
                        Text('${listing.reviewAvg.toStringAsFixed(1)}'
                            '${s.reviewCountSuffix(listing.reviewCount)}',
                            style: const TextStyle(fontFamily: 'Poppins', fontSize: 12,
                                color: AppColors.textSecondary)),
                      ]),
                    ],
                  ])).animate().fadeIn(duration: 400.ms, delay: 180.ms),
                  const SizedBox(height: 20),

                  // Avis
                  _ReviewsSection(listingId: widget.listingId, isDark: isDark, s: s),
                  const SizedBox(height: 20),

                  // Boutons contact
                  if (!isOwner) ...[
                    Text(s.contactSeller,
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkText : AppColors.textPrimary)),
                    const SizedBox(height: 10),
                    Row(children: [
                      if (listing.phone.isNotEmpty)
                        Expanded(child: _ContactBtn(
                          icon: Icons.phone_rounded, label: s.callSeller,
                          color: const Color(0xFF27AE60),
                          onTap: () => _call(listing.phone),
                        )),
                      if (listing.phone.isNotEmpty && listing.whatsapp.isNotEmpty)
                        const SizedBox(width: 12),
                      if (listing.whatsapp.isNotEmpty)
                        Expanded(child: _ContactBtn(
                          icon: Icons.chat_rounded, label: s.whatsappSeller,
                          color: const Color(0xFF25D366),
                          onTap: () => _whatsapp(listing.whatsapp, listing.title, s),
                        )),
                    ]).animate().fadeIn(duration: 400.ms, delay: 240.ms),
                    const SizedBox(height: 12),
                    // Bouton noter
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showReviewSheet(context, ref, listing, s, isDark),
                        icon: const Icon(Icons.star_outline_rounded,
                            color: Color(0xFFFFD700)),
                        label: Text(s.leaveReview,
                            style: const TextStyle(fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFFFD700),
                          side: const BorderSide(color: Color(0xFFFFD700)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 280.ms),
                  ],
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String label, Color color, {bool filled = false}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    decoration: BoxDecoration(
      color: filled ? color : color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(label, style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
        fontWeight: FontWeight.bold,
        color: filled ? Colors.white : color)),
  );

  Widget _card(bool isDark, {required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: isDark ? AppColors.darkCard : Colors.white,
      borderRadius: BorderRadius.circular(14),
    ),
    child: child,
  );

  Widget _infoRow(IconData icon, String text, bool isDark) => Row(children: [
    Icon(icon, size: 18,
        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
    const SizedBox(width: 10),
    Expanded(child: Text(text, style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
        color: isDark ? AppColors.darkText : AppColors.textPrimary))),
  ]);

  Widget _placeholder(Color color) => Container(
    color: color.withValues(alpha: 0.15),
    child: Center(child: Icon(Icons.image_outlined, size: 64,
        color: color.withValues(alpha: 0.4))),
  );

  String _fmtDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

  void _call(String phone) => launchUrl(
      Uri.parse('tel:${phone.replaceAll(' ', '')}'),
      mode: LaunchMode.externalApplication);

  void _whatsapp(String phone, String title, AppStrings s) {
    var p = phone.replaceAll(RegExp(r'\s+'), '');
    if (!p.startsWith('+')) p = p.startsWith('0') ? '+212${p.substring(1)}' : '+212$p';
    final msg = Uri.encodeComponent(s.whatsappInterest(title));
    launchUrl(Uri.parse('https://wa.me/$p?text=$msg'),
        mode: LaunchMode.externalApplication);
  }

  void _confirmDelete(BuildContext ctx, WidgetRef ref,
      ListingModel listing, AppStrings s) {
    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        title: Text(s.deleteAd, style: const TextStyle(fontFamily: 'Poppins')),
        content: Text(s.confirmDelete, style: const TextStyle(fontFamily: 'Poppins')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(s.cancel,
                style: const TextStyle(fontFamily: 'Poppins', color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogCtx); // ferme le dialog
              await ref.read(marketplaceActionsProvider)
                  .deleteListing(listing.id, listing.imageUrls);
              if (ctx.mounted) Navigator.pop(ctx); // retour à la liste
            },
            child: Text(s.deleteAd,
                style: const TextStyle(fontFamily: 'Poppins',
                    color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showReviewSheet(BuildContext ctx, WidgetRef ref,
      ListingModel listing, AppStrings s, bool isDark) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReviewSheet(
        listing: listing, s: s, isDark: isDark, ref: ref,
      ),
    );
  }
}

// ── Carousel photos ────────────────────────────────────────────────────────────
class _PhotoCarousel extends StatefulWidget {
  final List<String> urls;
  final int index;
  final ValueChanged<int> onChanged;
  const _PhotoCarousel({required this.urls, required this.index, required this.onChanged});

  @override
  State<_PhotoCarousel> createState() => _PhotoCarouselState();
}

class _PhotoCarouselState extends State<_PhotoCarousel> {
  late final PageController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = PageController(initialPage: widget.index);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _openFullscreen(BuildContext context, int startIndex) {
    Navigator.push(context, MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => _FullscreenGallery(urls: widget.urls, initialIndex: startIndex),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      PageView.builder(
        controller: _ctrl,
        itemCount: widget.urls.length,
        onPageChanged: widget.onChanged,
        itemBuilder: (ctx, i) => GestureDetector(
          onTap: () => _openFullscreen(ctx, i),
          child: Image.network(widget.urls[i],
              fit: BoxFit.cover, width: double.infinity,
              errorBuilder: (_, _, _) => Container(color: AppColors.primary.withValues(alpha: 0.1),
                  child: const Icon(Icons.image_outlined, size: 64, color: AppColors.primary))),
        ),
      ),
      // Dots
      if (widget.urls.length > 1)
        Positioned(bottom: 12, left: 0, right: 0,
          child: Row(mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.urls.length, (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: widget.index == i ? 18 : 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: widget.index == i ? Colors.white : Colors.white54,
                borderRadius: BorderRadius.circular(3),
              ),
            )),
          )),
    ]);
  }
}

// ── Section avis ───────────────────────────────────────────────────────────────
class _ReviewsSection extends ConsumerWidget {
  final String listingId;
  final bool isDark;
  final AppStrings s;
  const _ReviewsSection({required this.listingId, required this.isDark, required this.s});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(reviewsProvider(listingId));
    return reviewsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (reviews) {
        if (reviews.isEmpty) return const SizedBox.shrink();
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.reviewsCount(reviews.length),
              style: TextStyle(fontFamily: 'Poppins', fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkText : AppColors.textPrimary)),
          const SizedBox(height: 10),
          ...reviews.take(3).map((r) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(r.reviewerName,
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkText : AppColors.textPrimary))),
                Row(children: List.generate(5, (i) => Icon(
                  i < r.stars ? Icons.star_rounded : Icons.star_border_rounded,
                  size: 14, color: const Color(0xFFFFD700),
                ))),
              ]),
              if (r.comment.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(r.comment, style: const TextStyle(fontFamily: 'Poppins',
                    fontSize: 12, color: AppColors.textSecondary)),
              ],
            ]),
          )),
        ]);
      },
    );
  }
}

// ── Feuille notation ───────────────────────────────────────────────────────────
class _ReviewSheet extends StatefulWidget {
  final ListingModel listing;
  final AppStrings s;
  final bool isDark;
  final WidgetRef ref;
  const _ReviewSheet({required this.listing, required this.s,
      required this.isDark, required this.ref});

  @override
  State<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<_ReviewSheet> {
  int    _stars   = 5;
  final _ctrl     = TextEditingController();
  bool  _loading  = false;

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: widget.isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(widget.s.leaveReview,
              style: TextStyle(fontFamily: 'Poppins', fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: widget.isDark ? AppColors.darkText : AppColors.textPrimary)),
          const SizedBox(height: 20),
          // Étoiles
          Row(mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) => GestureDetector(
              onTap: () => setState(() => _stars = i + 1),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  i < _stars ? Icons.star_rounded : Icons.star_border_rounded,
                  size: 40, color: const Color(0xFFFFD700),
                ),
              ),
            ))),
          const SizedBox(height: 16),
          TextField(
            controller: _ctrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: widget.s.commentHint,
              hintStyle: const TextStyle(fontFamily: 'Poppins',
                  color: AppColors.textSecondary, fontSize: 13),
              filled: true,
              fillColor: widget.isDark ? AppColors.darkInput : AppColors.inputBg,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: _loading ? null : _submit,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0),
              child: _loading
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(widget.s.publishReview,
                      style: const TextStyle(fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold, color: Colors.black87)),
            ),
          ),
        ]),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    final ok = await widget.ref.read(marketplaceActionsProvider).addReview(
      listingId:  widget.listing.id,
      sellerId:   widget.listing.userId,
      stars:      _stars,
      comment:    _ctrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.pop(context);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: const Color(0xFFFFD700),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        content: Text(widget.s.reviewPublished,
            style: const TextStyle(fontFamily: 'Poppins', color: Colors.black87,
                fontWeight: FontWeight.bold)),
      ));
    }
  }
}

// ── Bouton contact ─────────────────────────────────────────────────────────────
// ── Visionneuse fullscreen ────────────────────────────────────────────────────
class _FullscreenGallery extends StatefulWidget {
  final List<String> urls;
  final int initialIndex;
  const _FullscreenGallery({required this.urls, required this.initialIndex});

  @override
  State<_FullscreenGallery> createState() => _FullscreenGalleryState();
}

class _FullscreenGalleryState extends State<_FullscreenGallery> {
  late int _current;
  late final PageController _ctrl;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _ctrl = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        PageView.builder(
          controller: _ctrl,
          itemCount: widget.urls.length,
          onPageChanged: (i) => setState(() => _current = i),
          itemBuilder: (_, i) => InteractiveViewer(
            minScale: 0.8,
            maxScale: 4.0,
            child: Center(
              child: Image.network(
                widget.urls[i],
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                    Icons.broken_image_rounded, color: Colors.white54, size: 64),
              ),
            ),
          ),
        ),
        // Bouton fermer
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          right: 12,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.black54, shape: BoxShape.circle),
              child: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
            ),
          ),
        ),
        // Compteur photos
        if (widget.urls.length > 1)
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 24,
            left: 0, right: 0,
            child: Row(mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.urls.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: _current == i ? 20 : 7,
                height: 7,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: _current == i ? Colors.white : Colors.white38,
                  borderRadius: BorderRadius.circular(4),
                ),
              )),
            ),
          ),
        // Numéro photo
        Positioned(
          top: MediaQuery.of(context).padding.top + 12,
          left: 0, right: 0,
          child: Center(child: Text(
            '${_current + 1} / ${widget.urls.length}',
            style: const TextStyle(fontFamily: 'Poppins',
                fontSize: 13, color: Colors.white70),
          )),
        ),
      ]),
    );
  }
}

class _ContactBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ContactBtn({required this.icon, required this.label,
      required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.35),
            blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontFamily: 'Poppins',
            fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
      ]),
    ),
  );
}
