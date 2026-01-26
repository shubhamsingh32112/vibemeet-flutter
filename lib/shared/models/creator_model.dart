import 'package:equatable/equatable.dart';

class CreatorModel extends Equatable {
  final String id;
  final String userId; // User ID for initiating calls (REQUIRED - creator always has a user)
  final String name;
  final String about;
  final String photo;
  final List<String>? categories;
  final double price;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CreatorModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.about,
    required this.photo,
    this.categories,
    required this.price,
    this.createdAt,
    this.updatedAt,
  });

  factory CreatorModel.fromJson(Map<String, dynamic> json) {
    return CreatorModel(
      id: json['id'] as String,
      userId: json['userId'] as String, // Required - no fallback
      name: json['name'] as String,
      about: json['about'] as String,
      photo: json['photo'] as String,
      categories: json['categories'] != null
          ? List<String>.from(json['categories'] as List)
          : null,
      price: (json['price'] as num).toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'about': about,
      'photo': photo,
      'categories': categories,
      'price': price,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        about,
        photo,
        categories,
        price,
        createdAt,
        updatedAt,
      ];
}
