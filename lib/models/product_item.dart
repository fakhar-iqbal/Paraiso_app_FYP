import 'dart:convert';

import 'package:flutter/foundation.dart';

class ProductItem {
  final String name;
  final String description;
  final List<String> sizes;
  final Map<String, num> prices;
  final String photo;
  final bool availability;
  final String discount;
  final double discountedPrice;
  final String type;
  final String itemId;
  final String workingHrs;
  final String prepDelay;
  final int rewards;
  final Map<String, dynamic> free;
  final List<dynamic> addOns;

  ProductItem({
    required this.name,
    required this.description,
    required this.sizes,
    required this.prices,
    required this.photo,
    required this.availability,
    required this.discount,
    required this.discountedPrice,
    required this.type,
    required this.itemId,
    required this.workingHrs,
    required this.prepDelay,
    required this.rewards,
    required this.free,
    required this.addOns,
  });

  ProductItem copyWith({
    String? name,
    String? description,
    List<String>? sizes,
    Map<String, num>? prices,
    String? photo,
    bool? availability,
    String? discount,
    double? discountedPrice,
    String? type,
    String? itemId,
    String? workingHrs,
    String? prepDelay,
    int? rewards,
    Map<String, dynamic>? free,
    List<dynamic>? addOns,
  }) {
    return ProductItem(
      name: name ?? this.name,
      description: description ?? this.description,
      sizes: sizes ?? this.sizes,
      prices: prices ?? this.prices,
      photo: photo ?? this.photo,
      availability: availability ?? this.availability,
      discount: discount ?? this.discount,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      type: type ?? this.type,
      itemId: itemId ?? this.itemId,
      workingHrs: workingHrs ?? this.workingHrs,
      prepDelay: prepDelay ?? this.prepDelay,
      rewards: rewards ?? this.rewards,
      free: free ?? this.free,
      addOns: addOns ?? this.addOns,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{
      'name': name,
      'description': description,
      'sizes': sizes,
      'prices': prices,
      'photo': photo,
      'availability': availability,
      'discount': discount,
      'discountedPrice': discountedPrice,
      'type': type,
      'itemId': itemId,
      'workingHrs': workingHrs,
      'prepDelay': prepDelay,
      'rewards': rewards,
      'free': free,
      'addOns': addOns,
    };
    return result;
  }

  factory ProductItem.fromMap(Map<String, dynamic> map) {
    return ProductItem(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      sizes: List<String>.from(map['sizes']),
      prices: Map<String, num>.from(map['prices']),
      photo: map['photo'] ?? '',
      availability: map['availability'] ?? false,
      discount: map['discount'] ?? '',
      discountedPrice: map['discountedPrice']?.toDouble() ?? 0.0,
      type: map['type'] ?? '',
      itemId: map['itemId'] ?? '',
      workingHrs: map['workingHrs'] ?? '',
      prepDelay: map['prepDelay'] ?? '',
      rewards: map['rewards']?.toInt() ?? 0,
      free: (map['free'] as Map<String, dynamic>?) ?? {},
      addOns: (map['addOns'] as List<dynamic>?) ?? [],
    );
  }

  String toJson() => json.encode(toMap());

  factory ProductItem.fromJson(String source) =>
      ProductItem.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ProductItem(name: $name, description: $description, sizes: $sizes, prices: $prices, photo: $photo, availability: $availability, discount: $discount, discountedPrice: $discountedPrice, type: $type, itemId: $itemId, workingHrs: $workingHrs, prepDelay: $prepDelay, rewards: $rewards, free: $free, addOns: $addOns)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProductItem &&
        other.name == name &&
        other.description == description &&
        listEquals(other.sizes, sizes) &&
        mapEquals(other.prices, prices) &&
        other.photo == photo &&
        other.availability == availability &&
        other.discount == discount &&
        other.discountedPrice == discountedPrice &&
        other.type == type &&
        other.itemId == itemId &&
        other.workingHrs == workingHrs &&
        other.prepDelay == prepDelay &&
        other.rewards == rewards &&
        other.free == free &&
        listEquals(other.addOns, addOns);
  }

  @override
  int get hashCode {
    return name.hashCode ^
        description.hashCode ^
        sizes.hashCode ^
        prices.hashCode ^
        photo.hashCode ^
        availability.hashCode ^
        discount.hashCode ^
        discountedPrice.hashCode ^
        type.hashCode ^
        itemId.hashCode ^
        workingHrs.hashCode ^
        prepDelay.hashCode ^
        rewards.hashCode ^
        free.hashCode ^
        addOns.hashCode;
  }
}

class AddonItem {
  final String addonName;
  final String addonType;
  final int canChooseUpto;
  final List<Map<String, dynamic>> addonItems;

  AddonItem({
    required this.addonName,
    required this.addonType,
    required this.canChooseUpto,
    required this.addonItems,
  });

  AddonItem copyWith({
    String? addonName,
    String? addonType,
    int? canChooseUptoCount,
    List<Map<String, dynamic>>? addonItems,
  }) {
    return AddonItem(
      addonName: addonName ?? this.addonName,
      addonType: addonType ?? this.addonType,
      canChooseUpto: canChooseUptoCount ?? this.canChooseUpto,
      addonItems: addonItems ?? this.addonItems,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'addonName': addonName,
      'addonType': addonType,
      'canChooseUpto': canChooseUpto,
      'addonItems': addonItems,
    };
  }

  factory AddonItem.fromMap(Map<String, dynamic> map) {
    return AddonItem(
      addonName: map['addonName'],
      addonType: map['addonType'],
      canChooseUpto: map['canChooseUpto'],
      addonItems: List<Map<String, dynamic>>.from(map['addonItems']),
    );
  }
}


class AddonItemWithId {
  final String addonName;
  final String addonType;
  final int canChooseUpto;
  final List<Map<String, dynamic>> addonItems;
  final String addonId; // New field

  AddonItemWithId({
    required this.addonName,
    required this.addonType,
    required this.canChooseUpto,
    required this.addonItems,
    required this.addonId, // New parameter
  });

  AddonItemWithId copyWith({
    String? addonName,
    String? addonType,
    int? canChooseUptoCount,
    List<Map<String, dynamic>>? addonItems,
    String? addonId, // New parameter
  }) {
    return AddonItemWithId(
      addonName: addonName ?? this.addonName,
      addonType: addonType ?? this.addonType,
      canChooseUpto: canChooseUptoCount ?? this.canChooseUpto,
      addonItems: addonItems ?? this.addonItems,
      addonId: addonId ?? this.addonId, // New parameter
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'addonName': addonName,
      'addonType': addonType,
      'canChooseUpto': canChooseUpto,
      'addonItems': addonItems,
      'addonId': addonId, // New field
    };
  }

  factory AddonItemWithId.fromMap(Map<String, dynamic> map) {
    return AddonItemWithId(
      addonName: map['addonName'],
      addonType: map['addonType'],
      canChooseUpto: map['canChooseUpto'],
      addonItems: List<Map<String, dynamic>>.from(map['addonItems']),
      addonId: map['addonId'], // New field
    );
  }
}

