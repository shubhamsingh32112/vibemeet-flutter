import 'package:equatable/equatable.dart';

/// Model for displaying user profiles in the home feed
/// Used when creators view users
class UserProfileModel extends Equatable {
  final String id;
  final String? username;
  final String? avatar;
  final String? gender;
  final List<String> categories;
  final DateTime? createdAt;

  const UserProfileModel({
    required this.id,
    this.username,
    this.avatar,
    this.gender,
    this.categories = const [],
    this.createdAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      username: json['username'] as String?,
      avatar: json['avatar'] as String?,
      gender: json['gender'] as String?,
      categories: json['categories'] != null
          ? List<String>.from(json['categories'] as List)
          : [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'avatar': avatar,
      'gender': gender,
      'categories': categories,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        username,
        avatar,
        gender,
        categories,
        createdAt,
      ];
}
