import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_strings.dart';
import '../../models/listing_model.dart';
import '../../providers/locale_provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../theme/app_theme.dart';
import 'marketplace_screen.dart' show typeColor, typeLabel;

class MyAdsScreen extends ConsumerWidget {
  const MyAdsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang   = ref.watch(localeProvider).languageCode;
    final s      = AppStrings.of(lang);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final actions = ref.read(marketplaceActionsProvider);
    final uid     = actions.currentUid;

    final listingsAsync = ref.watch(marketplaceProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => Navigator.pop(context),
                  color: isDark ? AppColors.darkText : AppColors.textPrimary,
                ),
                const SizedBox(width: 8),
                Text(s.myAds,
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkText : AppColors.textPrimary)),
              ]),
            ),

            Expanded(
              child: listingsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error:   (_, _) => const SizedBox.shrink(),
                data: (all) {
                  final mine = uid != null
                      ? all.where((l) => l.userId == uid).toList()
                      : <ListingModel>[];

                  if (mine.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.post_add_rounded, size: 64,
                              color: isDark ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary),
                          const SizedBox(height: 16),
                          Text(s.noListings, textAlign: TextAlign.center,
                              style: TextStyle(fontFamily: 'Poppins', fontSize: 14,
                                  height: 1.6,
                                  color: isDark ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary)),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12))),
                            icon: const Icon(Icons.add_rounded),
                            label: Text(s.addListing,
                                style: const TextStyle(fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600)),
                          ),
                        ]),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                    itemCount: mine.length,
                    itemBuilder: (ctx, i) {
                      final l = mine[i];
                      return _MyAdTile(
                        listing: l, isDark: isDark, s: s,
                        onTap: () => context.push('/marketplace/${l.id}'),
                        onDelete: () => _confirmDelete(ctx, ref, l, s),
                      ).animate(delay: (i * 60).ms)
                          .fadeIn(duration: 300.ms)
                          .slideX(begin: 0.05);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
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
              Navigator.pop(dialogCtx);
              await ref.read(marketplaceActionsProvider)
                  .deleteListing(listing.id, listing.imageUrls);
            },
            child: Text(s.deleteAd, style: const TextStyle(fontFamily: 'Poppins',
                color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ── Tuile d'annonce dans "Mes annonces" ────────────────────────────────────────
class _MyAdTile extends StatelessWidget {
  final ListingModel listing;
  final bool isDark;
  final AppStrings s;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _MyAdTile({
    required this.listing, required this.isDark, required this.s,
    required this.onTap, required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = typeColor(listing.type);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.05),
              blurRadius: 8)],
        ),
        child: Row(children: [
          // Photo
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: listing.imageUrls.isNotEmpty
                ? Image.network(listing.imageUrls.first,
                    width: 72, height: 72, fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _placeholder(color))
                : _placeholder(color),
          ),
          const SizedBox(width: 14),
          // Infos
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(listing.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(fontFamily: 'Poppins', fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkText : AppColors.textPrimary)),
            const SizedBox(height: 4),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6)),
                child: Text(typeLabel(listing.type, s),
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 10,
                        fontWeight: FontWeight.w600, color: color)),
              ),
              const SizedBox(width: 6),
              Text(listing.city, style: const TextStyle(fontFamily: 'Poppins',
                  fontSize: 11, color: AppColors.textSecondary)),
            ]),
            const SizedBox(height: 4),
            listing.type == 'vente' && listing.price != null
                ? Text('${listing.price!.round()} DH',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 14,
                        fontWeight: FontWeight.bold, color: color))
                : Text(listing.type == 'don' ? s.freeLabel : s.swapLabel,
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
                        fontWeight: FontWeight.w600, color: color)),
            if (listing.reviewCount > 0) ...[
              const SizedBox(height: 2),
              Row(children: [
                const Icon(Icons.star_rounded, size: 12, color: Color(0xFFFFD700)),
                const SizedBox(width: 3),
                Text('${listing.reviewAvg.toStringAsFixed(1)}'
                    ' (${listing.reviewCount})',
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 10,
                        color: AppColors.textSecondary)),
              ]),
            ],
          ])),
          // Supprimer
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 22),
            onPressed: onDelete,
          ),
        ]),
      ),
    );
  }

  Widget _placeholder(Color color) => Container(
    width: 72, height: 72,
    decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10)),
    child: Icon(Icons.image_outlined, color: color.withValues(alpha: 0.4)),
  );
}
