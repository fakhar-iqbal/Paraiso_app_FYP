import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:paraiso/controllers/cart_controller.dart';
import 'package:paraiso/screens/order_status.dart';
import 'package:get/get.dart';
import '../repositories/customer_firebase_calls.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({Key? key}) : super(key: key);

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  List items = [];

  Future<void> getOrders() async {
    final mydata = MyCustomerCalls();
    final docs = await mydata.getOrders();
    for (final doc in docs) {
      print("____________");
      print(doc.data());
      items.add(doc.data());
    }
    setState(() {});
    if (kDebugMode) print(items);
  }

  @override
  void initState() {
    super.initState();
    getOrders();
  }

  int getOrderStatus(int itemIndex) {
    String orderStatus = items[itemIndex]['status'];
    switch (orderStatus) {
      case "Pending":
        if (kDebugMode) print("Pending 0");
        return 0;
      case "In Progress":
        if (kDebugMode) print("In Progress 1");
        return 1;
      case "Fulfilled":
        if (kDebugMode) print("Fulfilled 2");
        return 2;
      case "Declined":
        if (kDebugMode) print("Declined 404");
        return 404;
      default:
        if (kDebugMode) print("Default 0");
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.myOrders),
          centerTitle: true,
          backgroundColor: const Color.fromRGBO(42, 42, 42, 1),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
            child: Column(
              children: [
                SizedBox(
                  height: 770.h,
                  child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) => MyOrderTile(
                            restaurantImage: 'https://th.bing.com/th/id/R.adb765cbe2c4a250ec8dddb4c1e635ad?rik=mwK83sntzxKILA&pid=ImgRaw&r=0',
                            orderDate: items[index]['time'] ?? "",
                            orderId: items[index]['orderId'].toString().substring(0, 12),
                            orderNumber: (index + 1).toString(),
                            orderItems: items[index]["items"].length.toString(),
                            onTap: () async {
                              int status = getOrderStatus(index);
                              final res = await MyCustomerCalls().getRestaurantById(items[index]['restaurantId']);
                              if (mounted) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => OrderStatus(
                                              restaurantAddress: res['address'],
                                              prepDelay: res['prepDelay'] ?? "30 mnts",
                                              workingHrs: res['workingHrs'] ?? "24 Hrs",
                                              restaurantId: items[index]['restaurantId'],
                                              restaurantName: items[index]['restaurantName'],
                                              restaurantImage: items[index]['photo'],
                                              orderStatus: status,
                                            )));
                              }
                            },
                          )),
                ),
              ],
            ),
          ),
        ));
  }
}

class MyOrderTile extends StatelessWidget {
  final String orderNumber;
  final String orderId;
  final String orderItems;
  final String orderDate;
  final String restaurantImage;
  final Function()? onTap;
  MyOrderTile({Key? key, required this.orderNumber, required this.orderId, this.onTap, required this.orderItems, required this.orderDate, required this.restaurantImage}) : super(key: key);

  final textStyle1 = TextStyle(
    color: Colors.white,
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
  );

  final textStyle2 = TextStyle(
    color: Colors.white,
    fontSize: 8.sp,
    fontWeight: FontWeight.w300,
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(53, 53, 53, 1),
          borderRadius: BorderRadius.circular(22.r),
        ),
        margin: EdgeInsets.symmetric(vertical: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Row(
          children: [
            Container(
              width: 50.w,
              height: 50.h,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: const CircleBorder(),
                image: DecorationImage(image: Image.network(restaurantImage).image),
              ),
            ),
            15.horizontalSpace,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "# $orderId",
                  style: textStyle1,
                ),
                5.verticalSpace,
                Text(
                  "Items: $orderItems",
                  style: textStyle2,
                ),
              ],
            ),
            const Spacer(),
            // Text(
            //   orderDate,
            //   style: textStyle2,
            // ),
            if (orderDate == "")
              Text(
                AppLocalizations.of(context)!.notSheduled,
                style: textStyle2,
              )
            else
              Column(
                children: [
                  Text(
                    orderDate.split(' ')[0],
                    style: textStyle2,
                  ),
                  Text(
                    DateFormat.jm().format(DateFormat("yyyy-MM-dd HH:mm").parse(orderDate)),
                    style: textStyle2,
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}
