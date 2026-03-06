import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String id;
  final String name;
  final String icon;
  final int color;
  final String description;
  final int order;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
    this.order = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Category(
      id: doc.id,
      name: data['name'] ?? '',
      icon: data['icon'] ?? 'place',
      color: data['color'] ?? 0xFF607D8B,
      description: data['description'] ?? '',
      order: data['order'] ?? 0,
      isActive: data['isActive'] ?? true,
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
      'icon': icon,
      'color': color,
      'description': description,
      'order': order,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Category copyWith({
    String? id,
    String? name,
    String? icon,
    int? color,
    String? description,
    int? order,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      description: description ?? this.description,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, icon: $icon)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

