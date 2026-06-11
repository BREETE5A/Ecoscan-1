import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/listing_model.dart';

final _db = FirebaseFirestore.instance;

// ── Cloudinary config ─────────────────────────────────────────────────────────
const _cloudName    = 'dfuhrnnxx';
const _uploadPreset = 'ecoscan_marketplace';
const _cloudUrl     = 'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

Future<String?> _uploadToCloudinary(File file) async {
  try {
    final formData = FormData.fromMap({
      'file':          await MultipartFile.fromFile(file.path),
      'upload_preset': _uploadPreset,
      'folder':        'marketplace',
    });
    final response = await Dio().post(_cloudUrl, data: formData);
    return response.data['secure_url'] as String?;
  } catch (_) {
    return null;
  }
}

// ── Stream de toutes les annonces actives ─────────────────────────────────────
final marketplaceProvider = StreamProvider<List<ListingModel>>((ref) {
  return _db
      .collection('marketplace')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs
          .map(ListingModel.fromFirestore)
          .where((l) => l.active)
          .toList());
});

// ── Stream des avis d'une annonce ─────────────────────────────────────────────
final reviewsProvider =
    StreamProvider.family<List<ReviewModel>, String>((ref, listingId) {
  return _db
      .collection('marketplace')
      .doc(listingId)
      .collection('reviews')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(ReviewModel.fromFirestore).toList());
});

// ── Actions CRUD ──────────────────────────────────────────────────────────────
final marketplaceActionsProvider =
    Provider<MarketplaceActions>((_) => MarketplaceActions());

class MarketplaceActions {
  String? get _uid  => FirebaseAuth.instance.currentUser?.uid;
  String  get _name => FirebaseAuth.instance.currentUser?.displayName ?? 'Utilisateur';

  // ── Publier une annonce ───────────────────────────────────────────────────
  Future<String?> addListing({
    required String title,
    required String description,
    required String type,
    required String category,
    double?  price,
    required String city,
    required String phone,
    required String whatsapp,
    List<File> imageFiles = const [],
    double? latitude,
    double? longitude,
  }) async {
    final uid = _uid;
    if (uid == null) return null;

    try {
      // Upload toutes les photos sur Cloudinary
      final imageUrls = <String>[];
      for (final file in imageFiles) {
        final url = await _uploadToCloudinary(file);
        if (url != null) imageUrls.add(url);
      }

      final listing = ListingModel(
        id:          '',
        title:       title,
        description: description,
        type:        type,
        category:    category,
        price:       price,
        city:        city,
        phone:       phone,
        whatsapp:    whatsapp,
        imageUrls:   imageUrls,
        userId:      uid,
        userName:    _name,
        createdAt:   DateTime.now(),
        latitude:    latitude,
        longitude:   longitude,
      );

      final doc = await _db.collection('marketplace').add(listing.toMap());

      // ── EcoPoints : +5 pts général, +15 pts si don ───────────────────────
      final pts = type == 'don' ? 15 : 5;
      try {
        await _db.collection('users').doc(uid).update({
          'ecoPoints': FieldValue.increment(pts),
        });
      } catch (_) {}  // ne pas bloquer si update points échoue

      // ── Challenge "Premier Don" ───────────────────────────────────────────
      if (type == 'don') {
        final progress = await _db
            .collection('users')
            .doc(uid)
            .collection('progress')
            .doc('challenges')
            .get();
        final data = progress.data() ?? {};
        if ((data['firstDonListed'] as bool?) != true) {
          await _db
              .collection('users')
              .doc(uid)
              .collection('progress')
              .doc('challenges')
              .set({'firstDonListed': true}, SetOptions(merge: true));
        }
      }

      return doc.id;
    } catch (e) {
      return null;
    }
  }

  // ── Supprimer une annonce ─────────────────────────────────────────────────
  Future<bool> deleteListing(String listingId, List<String> imageUrls) async {
    final uid = _uid;
    if (uid == null) return false;
    try {
      // Supprimer la sous-collection reviews avant le document principal
      await _deleteSubcollection(
          _db.collection('marketplace').doc(listingId).collection('reviews'));
      await _db.collection('marketplace').doc(listingId).delete();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _deleteSubcollection(CollectionReference col) async {
    QuerySnapshot snap;
    do {
      snap = await col.limit(100).get();
      if (snap.docs.isEmpty) break;
      final batch = _db.batch();
      for (final doc in snap.docs) { batch.delete(doc.reference); }
      await batch.commit();
    } while (snap.docs.length == 100);
  }

  // ── Laisser un avis ───────────────────────────────────────────────────────
  Future<bool> addReview({
    required String listingId,
    required String sellerId,
    required int stars,
    required String comment,
  }) async {
    final uid = _uid;
    if (uid == null || uid == sellerId) return false;

    try {
      final review = ReviewModel(
        id:           '',
        reviewerId:   uid,
        reviewerName: _name,
        stars:        stars,
        comment:      comment,
        createdAt:    DateTime.now(),
      );

      // Ajoute l'avis dans la sous-collection
      await _db
          .collection('marketplace')
          .doc(listingId)
          .collection('reviews')
          .add(review.toMap());

      // Recalcule la moyenne sur l'annonce
      final reviews = await _db
          .collection('marketplace')
          .doc(listingId)
          .collection('reviews')
          .get();
      final count = reviews.docs.length;
      final avg   = reviews.docs
              .map((d) => (d.data()['stars'] as num?)?.toDouble() ?? 0)
              .fold(0.0, (a, b) => a + b) /
          count;

      await _db.collection('marketplace').doc(listingId).update({
        'reviewAvg':    avg,
        'reviewCount':  count,
        'trustedSeller': count >= 5 && avg >= 4.0,
      });

      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Vérifie si l'utilisateur a déjà noté cette annonce ───────────────────
  Future<bool> hasReviewed(String listingId) async {
    final uid = _uid;
    if (uid == null) return false;
    final snap = await _db
        .collection('marketplace')
        .doc(listingId)
        .collection('reviews')
        .where('reviewerId', isEqualTo: uid)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  bool isOwner(String listingUserId) => _uid == listingUserId;
  String? get currentUid => _uid;
}
