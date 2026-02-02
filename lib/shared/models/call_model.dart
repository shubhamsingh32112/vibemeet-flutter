import 'package:equatable/equatable.dart';

// TASK 1: Define Call States (Shared Contract)
enum CallStatus {
  initiated,
  ringing,
  accepted,
  rejected,
  ended,
  missed;

  static CallStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'initiated':
        return CallStatus.initiated;
      case 'ringing':
        return CallStatus.ringing;
      case 'accepted':
        return CallStatus.accepted;
      case 'rejected':
        return CallStatus.rejected;
      case 'ended':
        return CallStatus.ended;
      case 'missed':
        return CallStatus.missed;
      default:
        return CallStatus.initiated;
    }
  }

  String toJson() {
    return name;
  }
}

class CallModel extends Equatable {
  final String callId;
  final String channelName;
  final String callerUserId;
  final String creatorUserId;
  final CallStatus status;
  final String? token;
  final int? uid;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? acceptedAt;
  final DateTime? endedAt;
  final int? duration; // Duration in seconds
  final String? durationFormatted; // Human-readable duration (e.g., "5m 30s")
  // Rating (caller-only visibility from backend)
  final int? rating; // 1-5
  final DateTime? ratedAt;
  final CallerInfo? caller;
  final CreatorInfo? creator;

  const CallModel({
    required this.callId,
    required this.channelName,
    required this.callerUserId,
    required this.creatorUserId,
    required this.status,
    this.token,
    this.uid,
    this.createdAt,
    this.updatedAt,
    this.acceptedAt,
    this.endedAt,
    this.duration,
    this.durationFormatted,
    this.rating,
    this.ratedAt,
    this.caller,
    this.creator,
  });

  factory CallModel.fromJson(Map<String, dynamic> json) {
    return CallModel(
      callId: json['callId'] as String,
      channelName: json['channelName'] as String,
      callerUserId: json['callerUserId'] as String? ?? '',
      creatorUserId: json['creatorUserId'] as String? ?? '',
      status: CallStatus.fromString(json['status'] as String? ?? 'initiated'),
      token: json['token'] as String?,
      uid: json['uid'] as int?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      acceptedAt: json['acceptedAt'] != null
          ? DateTime.parse(json['acceptedAt'] as String)
          : null,
      endedAt: json['endedAt'] != null
          ? DateTime.parse(json['endedAt'] as String)
          : null,
      duration: json['duration'] as int?,
      durationFormatted: json['durationFormatted'] as String?,
      rating: (json['rating'] is num) ? (json['rating'] as num).toInt() : null,
      ratedAt: json['ratedAt'] != null ? DateTime.parse(json['ratedAt'] as String) : null,
      caller: json['caller'] != null
          ? CallerInfo.fromJson(json['caller'] as Map<String, dynamic>)
          : null,
      creator: json['creator'] != null
          ? CreatorInfo.fromJson(json['creator'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'callId': callId,
      'channelName': channelName,
      'callerUserId': callerUserId,
      'creatorUserId': creatorUserId,
      'status': status.toJson(),
      'token': token,
      'uid': uid,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'acceptedAt': acceptedAt?.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'duration': duration,
      'durationFormatted': durationFormatted,
      'rating': rating,
      'ratedAt': ratedAt?.toIso8601String(),
      'caller': caller?.toJson(),
      'creator': creator?.toJson(),
    };
  }

  CallModel copyWith({
    String? callId,
    String? channelName,
    String? callerUserId,
    String? creatorUserId,
    CallStatus? status,
    String? token,
    int? uid,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? acceptedAt,
    DateTime? endedAt,
    int? duration,
    String? durationFormatted,
    int? rating,
    DateTime? ratedAt,
    CallerInfo? caller,
    CreatorInfo? creator,
  }) {
    return CallModel(
      callId: callId ?? this.callId,
      channelName: channelName ?? this.channelName,
      callerUserId: callerUserId ?? this.callerUserId,
      creatorUserId: creatorUserId ?? this.creatorUserId,
      status: status ?? this.status,
      token: token ?? this.token,
      uid: uid ?? this.uid,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      endedAt: endedAt ?? this.endedAt,
      duration: duration ?? this.duration,
      durationFormatted: durationFormatted ?? this.durationFormatted,
      rating: rating ?? this.rating,
      ratedAt: ratedAt ?? this.ratedAt,
      caller: caller ?? this.caller,
      creator: creator ?? this.creator,
    );
  }

  @override
  List<Object?> get props => [
        callId,
        channelName,
        callerUserId,
        creatorUserId,
        status,
        token,
        uid,
        createdAt,
        updatedAt,
        acceptedAt,
        endedAt,
        duration,
        durationFormatted,
        rating,
        ratedAt,
        caller,
        creator,
      ];
}

class CallerInfo extends Equatable {
  final String id;
  final String? username;
  final String? avatar;

  const CallerInfo({
    required this.id,
    this.username,
    this.avatar,
  });

  factory CallerInfo.fromJson(Map<String, dynamic> json) {
    return CallerInfo(
      id: json['id'] as String,
      username: json['username'] as String?,
      avatar: json['avatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'avatar': avatar,
    };
  }

  @override
  List<Object?> get props => [id, username, avatar];
}

class CreatorInfo extends Equatable {
  final String id;
  final String? username;
  final String? avatar;

  const CreatorInfo({
    required this.id,
    this.username,
    this.avatar,
  });

  factory CreatorInfo.fromJson(Map<String, dynamic> json) {
    return CreatorInfo(
      id: json['id'] as String,
      username: json['username'] as String?,
      avatar: json['avatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'avatar': avatar,
    };
  }

  @override
  List<Object?> get props => [id, username, avatar];
}
