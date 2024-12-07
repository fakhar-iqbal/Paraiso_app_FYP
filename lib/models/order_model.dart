import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String orderId;
  final String clientId;
  final String restaurantId;
  final String status;
  final double totalPrice;
  final List<Map<String, dynamic>> items;
  final String photo;
  final String userName;
  final Timestamp timestamp;
  final String time;
  final String instructions;
  final List<dynamic> addOns;

  OrderModel({
    required this.orderId,
    required this.clientId,
    required this.restaurantId,
    required this.status,
    required this.totalPrice,
    required this.items,
    required this.photo,
    required this.userName,
    required this.timestamp,
    required this.time,
    required this.instructions,
    required this.addOns,
  });

  OrderModel copyWith({
    String? orderId,
    String? clientId,
    String? restaurantId,
    String? status,
    double? totalPrice,
    List<Map<String, dynamic>>? items,
    String? photo,
    String? userName,
    Timestamp? timestamp,
    String? time,
    String? instructions,
    List<dynamic>? addOns,
  }) {
    return OrderModel(
      orderId: orderId ?? this.orderId,
      clientId: clientId ?? this.clientId,
      restaurantId: restaurantId ?? this.restaurantId,
      status: status ?? this.status,
      totalPrice: totalPrice ?? this.totalPrice,
      items: items ?? this.items,
      photo: photo ?? this.photo,
      userName: userName ?? this.userName,
      timestamp: timestamp ?? this.timestamp,
      time: time ?? this.time,
      instructions: instructions ?? this.instructions,
      addOns: addOns ?? this.addOns,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'clientId': clientId,
      'restaurantId': restaurantId,
      'status': status,
      'totalPrice': totalPrice,
      'items': items,
      'photo': photo,
      'userName': userName,
      'timestamp': timestamp,
      'time': time,
      'instructions': instructions,
      'addOns': addOns,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      orderId: map['orderId'] ?? '',
      clientId: map['clientId'] ?? '',
      restaurantId: map['restaurantId'] ?? '',
      status: map['status'] ?? '',
      totalPrice: map['totalPrice']?.toDouble() ?? 0.0,
      items: List<Map<String, dynamic>>.from(map['items'] ?? []),
      photo: map['photo'] ?? '',
      userName: map['userName'] ?? '',
      timestamp: map['timestamp'] as Timestamp,
      time: map['time'] ?? '',
      instructions: map['instructions'] ?? '',
      addOns: (map['addOns'] as List<dynamic>?) ?? [],
    );
  }

  String toJson() => json.encode(toMap());

  factory OrderModel.fromJson(String source) =>
      OrderModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'OrderModel(orderId: $orderId, clientId: $clientId, restaurantId: $restaurantId, status: $status, totalPrice: $totalPrice, items: $items, photo: $photo, userName: $userName, timestamp: $timestamp, time: $time, instructions: $instructions, addOns: $addOns)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is OrderModel &&
        other.orderId == orderId &&
        other.clientId == clientId &&
        other.restaurantId == restaurantId &&
        other.status == status &&
        other.totalPrice == totalPrice &&
        listEquals(other.items, items) &&
        other.photo == photo &&
        other.userName == userName &&
        other.timestamp == timestamp &&
        other.time == time &&
        other.instructions == instructions &&
        listEquals(other.addOns, addOns);
  }

  @override
  int get hashCode {
    return orderId.hashCode ^
        clientId.hashCode ^
        restaurantId.hashCode ^
        status.hashCode ^
        totalPrice.hashCode ^
        items.hashCode ^
        photo.hashCode ^
        userName.hashCode ^
        timestamp.hashCode ^
        time.hashCode ^
        instructions.hashCode ^
        addOns.hashCode;
  }
}
