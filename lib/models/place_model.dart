import 'package:cloud_firestore/cloud_firestore.dart';

class Place {
  final String id;
  final String name;
  final String description;
  final String categoryId;
  final String address;
  final double latitude;
  final double longitude;
  final String? phoneNumber;
  final String? email;
  final String? website;
  final List<String> imageUrls;
  final List<String> openingHours;
  final bool isOpen24Hours;
  final double? rating;
  final int? reviewCount;
  final bool isFeatured;
  
  // User management fields
  final String createdBy;     // User UID who created the place
  final DateTime createdAt;   // Creation timestamp
  final DateTime updatedAt;   // Last update timestamp

  Place({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.phoneNumber,
    this.email,
    this.website,
    this.imageUrls = const [],
    this.openingHours = const [],
    this.isOpen24Hours = false,
    this.rating,
    this.reviewCount = 0,
    this.isFeatured = false,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Place.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Place(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      categoryId: data['categoryId'] ?? '',
      address: data['address'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      phoneNumber: data['phoneNumber'],
      email: data['email'],
      website: data['website'],
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      openingHours: List<String>.from(data['openingHours'] ?? []),
      isOpen24Hours: data['isOpen24Hours'] ?? false,
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      isFeatured: data['isFeatured'] ?? false,
      createdBy: data['createdBy'] ?? 'anonymous',
      createdAt: (data['createdAt'] != null)
          ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'].millisecondsSinceEpoch)
          : DateTime.now(),
      updatedAt: (data['updatedAt'] != null)
          ? DateTime.fromMillisecondsSinceEpoch(data['updatedAt'].millisecondsSinceEpoch)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'categoryId': categoryId,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phoneNumber': phoneNumber,
      'email': email,
      'website': website,
      'imageUrls': imageUrls,
      'openingHours': openingHours,
      'isOpen24Hours': isOpen24Hours,
      'rating': rating,
      'reviewCount': reviewCount,
      'isFeatured': isFeatured,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Place copyWith({
    String? id,
    String? name,
    String? description,
    String? categoryId,
    String? address,
    double? latitude,
    double? longitude,
    String? phoneNumber,
    String? email,
    String? website,
    List<String>? imageUrls,
    List<String>? openingHours,
    bool? isOpen24Hours,
    double? rating,
    int? reviewCount,
    bool? isFeatured,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Place(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      website: website ?? this.website,
      imageUrls: imageUrls ?? this.imageUrls,
      openingHours: openingHours ?? this.openingHours,
      isOpen24Hours: isOpen24Hours ?? this.isOpen24Hours,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isFeatured: isFeatured ?? this.isFeatured,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if the current user can edit this place
  bool canEdit(String? currentUserId) {
    if (currentUserId == null) return false;
    return createdBy == currentUserId;
  }

  /// Check if the current user can delete this place
  bool canDelete(String? currentUserId) {
    if (currentUserId == null) return false;
    return createdBy == currentUserId;
  }

  @override
  String toString() {
    return 'Place(id: $id, name: $name, categoryId: $categoryId, address: $address, createdBy: $createdBy)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Place && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

