import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:paraiso/repositories/res_post_repo.dart';
import 'package:paraiso/models/restaurant_admin_model.dart';

import '../../models/order_model.dart';

class OrdersController with ChangeNotifier {
  final RestaurantPostRepo _repo = RestaurantPostRepo();
  List<OrderModel> _orders = [];
  double _totalSales = 0.0;
  double _todaySales = 0.0;
  double _weeklySales = 0.0;
  double _monthlySales = 0.0;
  double _todayOrdersLength = 0.0;
  double _weeklyOrdersLength = 0.0;
  double _monthlyOrdersLength = 0.0;

  List<OrderModel> get orders => _orders;
  double get totalSales => _totalSales;
  double get todaySales => _todaySales;
  double get weeklySales => _weeklySales;
  double get monthlySales => _monthlySales;
  int get todayOrdersLength => _todayOrdersLength.toInt();
  int get weeklyOrdersLength => _weeklyOrdersLength.toInt();
  int get monthlyOrdersLength => _monthlyOrdersLength.toInt();


  Future<void> fetchOrders(RestaurantAdmin admin) async {
    final ordersData = await _repo.getOrdersForRestaurant(admin.userId);
    _orders = ordersData;

    var tempTodayOrders = 0.0;
    var tempWeeklyOrders = 0.0;
    var tempMonthlyOrders = 0.0;

    for(int i = 0; i < _orders.length; i++){
      if(checkDate(_orders[i].time, "today")){
        tempTodayOrders += 1;
      }
      if(checkDate(_orders[i].time, "weekly")){
        tempWeeklyOrders += 1;
      }
      if(checkDate(_orders[i].time, "monthly")){
        tempMonthlyOrders += 1;
      }
    }
    _todayOrdersLength = tempTodayOrders;
    _weeklyOrdersLength = tempWeeklyOrders;
    _monthlyOrdersLength = tempMonthlyOrders;

    notifyListeners();
  }



  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _repo.updateOrderStatus(orderId, newStatus);
    notifyListeners();
  }

  Future<void> calculateTotalSales(RestaurantAdmin admin) async {
    final sales = await _repo.calculateTotalOrderAmount(admin.userId);
    _totalSales = sales;
    final myCall= RestaurantPostRepo();
    _todaySales=await myCall.calculateTotalOrder( admin.userId  ,"today");
    _weeklySales=await myCall.calculateTotalOrder( admin.userId  ,"weekly");
    _monthlySales=await myCall.calculateTotalOrder( admin.userId  ,"monthly");
    notifyListeners();
  }
}


bool checkDate(String dateString , String type){
  try {
    DateTime date = DateFormat("yyyy-MM-dd hh:mm a").parse(dateString);

    // Get today's date
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    // Check if the date is today
    if(type == "today"){
      return date.year == today.year && date.month == today.month && date.day == today.day;
    }
    else if(type == "weekly"){
      return date.isAfter(today.subtract(Duration(days: 7)));
    }
    else if(type == "monthly"){
      return date.isAfter(today.subtract(Duration(days: 30)));
    }
    else{
      return true;
    }
  } catch (e) {
    print("Error parsing the date: $e");
    return false; // Return false if there's an error parsing the date
  }
}