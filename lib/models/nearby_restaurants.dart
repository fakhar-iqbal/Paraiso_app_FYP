import 'dart:convert';

class NearbyRestaurants {
  final String name;
  final String description;
  final String logo;
  final String workingHrs;
  final num distance;

  NearbyRestaurants({
    required this.name,
    required this.description,
    required this.logo,
    required this.workingHrs,
    required this.distance,
  });

  NearbyRestaurants copyWith({
    String? name,
    String? description,
    String? logo,
    String? workingHrs,
    num? distance,
  }) {
    return NearbyRestaurants(
      name: name ?? this.name,
      description: description ?? this.description,
      logo: logo ?? this.logo,
      workingHrs: workingHrs ?? this.workingHrs,
      distance: distance ?? this.distance,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'name': name});
    result.addAll({'description': description});
    result.addAll({'logo': logo});
    result.addAll({'workingHrs': workingHrs});
    result.addAll({'distance': distance});

    return result;
  }

  factory NearbyRestaurants.fromMap(Map<String, dynamic> map) {
    return NearbyRestaurants(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      logo: map['logo'] ?? '',
      workingHrs: map['workingHrs'] ?? '',
      distance: map['distance'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory NearbyRestaurants.fromJson(String source) =>
      NearbyRestaurants.fromMap(json.decode(source));

  @override
  String toString() {
    return 'NearbyRestaurants(name: $name, description: $description, logo: $logo, workingHrs: $workingHrs, distance: $distance)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NearbyRestaurants &&
        other.name == name &&
        other.description == description &&
        other.logo == logo &&
        other.workingHrs == workingHrs &&
        other.distance == distance;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        description.hashCode ^
        logo.hashCode ^
        workingHrs.hashCode ^
        distance.hashCode;
  }
}
