import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Client {
  final String userName;
  final String photo;
  final GeoPoint? location;
  final String phoneNumber;
  final String schoolName;
  final num rewards;

  Client({
    required this.userName,
    required this.photo,
    required this.location,
    required this.phoneNumber,
    required this.schoolName,
    required this.rewards,
  });

  Client copyWith({
    String? userName,
    String? photo,
    GeoPoint? location,
    String? phoneNumber,
    String? schoolName,
    num? rewards,
  }) {
    return Client(
      userName: userName ?? this.userName,
      photo: photo ?? this.photo,
      location: location ?? this.location,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      schoolName: schoolName ?? this.schoolName,
      rewards: rewards ?? this.rewards,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'userName': userName});
    result.addAll({'photo': photo});
    if (location != null) {
      result.addAll({'location': location});
    }
    result.addAll({'phoneNumber': phoneNumber});
    result.addAll({'schoolName': schoolName});
    result.addAll({'rewards': rewards});

    return result;
  }

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      userName: map['userName'] ?? '',
      photo: map['photo'] ?? '',
      location: map['location'],
      phoneNumber: map['phoneNumber'] ?? '',
      schoolName: map['schoolName'] ?? '',
      rewards: map['rewards'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Client.fromJson(String source) => Client.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Client(userName: $userName, photo: $photo, location: $location, phoneNumber: $phoneNumber, schoolName: $schoolName, rewards: $rewards)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Client &&
        other.userName == userName &&
        other.photo == photo &&
        other.location == location &&
        other.phoneNumber == phoneNumber &&
        other.schoolName == schoolName &&
        other.rewards == rewards;
  }

  @override
  int get hashCode {
    return userName.hashCode ^
        photo.hashCode ^
        location.hashCode ^
        phoneNumber.hashCode ^
        schoolName.hashCode ^
        rewards.hashCode;
  }
}
