import 'package:cloud_firestore/cloud_firestore.dart';

class ListingModel {
  final String id;
  final String title;
  final String description;
  final String type;          // 'don' | 'vente' | 'echange'
  final String category;
  final double? price;
  final String city;
  final String phone;
  final String whatsapp;
  final List<String> imageUrls; // plusieurs photos
  final String userId;
  final String userName;
  final DateTime createdAt;
  final bool active;
  final double reviewAvg;
  final int reviewCount;
  final bool trustedSeller;
  final double? latitude;   // coordonnées GPS de l'annonceur
  final double? longitude;

  const ListingModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    this.price,
    required this.city,
    required this.phone,
    required this.whatsapp,
    this.imageUrls = const [],
    required this.userId,
    required this.userName,
    required this.createdAt,
    this.active = true,
    this.reviewAvg = 0,
    this.reviewCount = 0,
    this.trustedSeller = false,
    this.latitude,
    this.longitude,
  });

  // Rétrocompatibilité : première URL ou null
  String? get imageUrl => imageUrls.isNotEmpty ? imageUrls.first : null;

  factory ListingModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;

    // Support ancien format (imageUrl string) + nouveau (imageUrls list)
    final List<String> imgs;
    if (d['imageUrls'] is List) {
      imgs = List<String>.from(d['imageUrls'] as List);
    } else if (d['imageUrl'] is String && (d['imageUrl'] as String).isNotEmpty) {
      imgs = [d['imageUrl'] as String];
    } else {
      imgs = [];
    }

    return ListingModel(
      id:           doc.id,
      title:        (d['title']       as String?) ?? '',
      description:  (d['description'] as String?) ?? '',
      type:         (d['type']        as String?) ?? 'don',
      category:     (d['category']    as String?) ?? 'Autre',
      price:        (d['price']       as num?)?.toDouble(),
      city:         (d['city']        as String?) ?? '',
      phone:        (d['phone']       as String?) ?? '',
      whatsapp:     (d['whatsapp']    as String?) ?? '',
      imageUrls:    imgs,
      userId:       (d['userId']      as String?) ?? '',
      userName:     (d['userName']    as String?) ?? 'Utilisateur',
      createdAt:    (d['createdAt']   as Timestamp?)?.toDate() ?? DateTime.now(),
      active:       (d['active']      as bool?)   ?? true,
      reviewAvg:    (d['reviewAvg']   as num?)?.toDouble() ?? 0,
      reviewCount:  (d['reviewCount'] as num?)?.toInt()    ?? 0,
      trustedSeller:(d['trustedSeller'] as bool?) ?? false,
      latitude:     (d['latitude']    as num?)?.toDouble(),
      longitude:    (d['longitude']   as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
    'title':        title,
    'description':  description,
    'type':         type,
    'category':     category,
    if (price != null) 'price': price,
    'city':         city,
    'phone':        phone,
    'whatsapp':     whatsapp,
    'imageUrls':    imageUrls,
    'userId':       userId,
    'userName':     userName,
    'createdAt':    FieldValue.serverTimestamp(),
    'active':       true,
    'reviewAvg':    0,
    'reviewCount':  0,
    'trustedSeller':false,
    if (latitude  != null) 'latitude':  latitude,
    if (longitude != null) 'longitude': longitude,
  };
}

class ReviewModel {
  final String id;
  final String reviewerId;
  final String reviewerName;
  final int stars;          // 1..5
  final String comment;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.reviewerId,
    required this.reviewerName,
    required this.stars,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ReviewModel(
      id:           doc.id,
      reviewerId:   (d['reviewerId']   as String?) ?? '',
      reviewerName: (d['reviewerName'] as String?) ?? '',
      stars:        (d['stars']        as num?)?.toInt() ?? 5,
      comment:      (d['comment']      as String?) ?? '',
      createdAt:    (d['createdAt']    as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'reviewerId':   reviewerId,
    'reviewerName': reviewerName,
    'stars':        stars,
    'comment':      comment,
    'createdAt':    FieldValue.serverTimestamp(),
  };
}
