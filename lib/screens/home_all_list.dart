import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:paraiso/util/local_storage/shared_preferences_helper.dart';
import 'package:provider/provider.dart';

import '../controllers/friends_controller.dart';
import '../repositories/customer_firebase_calls.dart';
import '../widgets/friends_tile.dart';
import '../widgets/restaurant_tile.dart';

class HomeAllList extends StatefulWidget {
  const HomeAllList({Key? key}) : super(key: key);

  @override
  State<HomeAllList> createState() => _HomeAllListState();
}

class _HomeAllListState extends State<HomeAllList> {
  dynamic restaurantLists = [];
  dynamic restaurantListIds = [];

  Future<void> getData() async {
    final mydata = MyCustomerCalls();
    final items = SharedPreferencesHelper.getCustomerType() == 'guest'
        ? await mydata.getRestaurantsWithDiscountsForGuest()
        : await mydata.getRestaurantsWithDiscounts();
    for (final item in items) {
      restaurantListIds.add(item['restaurantId']);
      restaurantLists.add(item);
    }
    setState(() {});
  }

  Future<void> getItems(String restaurantAdminId) async {
    final mydata = MyCustomerCalls();
    final docs = await mydata.getItems(restaurantAdminId);
    for (final doc in docs) {
      if (kDebugMode) print(doc.data());
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * .7,
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: restaurantLists.length *
                  MediaQuery.sizeOf(context).height *
                  .135,
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: restaurantLists.length,
                itemBuilder: (context, index) {
                  final Timestamp lastUpdatedTimestamp =
                      restaurantLists[index]['lastUpdated'];
                  final DateTime lastUpdated = lastUpdatedTimestamp.toDate();
                  final formattedTimeDifference =
                      formatTimeDifference(lastUpdated);

                  return RestaurantTile(
                    restaurantID: restaurantListIds[index],
                    restaurantName: restaurantLists[index]['restaurantName'],
                    restaurantAddress: restaurantLists[index]
                        ['restaurantAddress'],
                    restaurantDescription:
                        '${restaurantLists[index]["discount"]} discount on ${restaurantLists[index]['itemName']}',
                    distance: formattedTimeDifference,
                    image: restaurantLists[index]['restaurantLogo'],
                    isOnlineImage: true,
                  );
                },
              ),
            ),
            Consumer<FriendsController>(
              builder: (context, value, child) {
                return Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: MediaQuery.sizeOf(context).height * .7,
                      child: ListView.builder(
                        itemCount: value.friendsWithRewards.length,
                        itemBuilder: (context, index) {
                          final Timestamp lastUpdatedTimestamp =
                              value.friendsWithRewards[index]!['rewardShare']
                                  ['sendRewardsOn'];
                          final DateTime lastUpdated =
                              lastUpdatedTimestamp.toDate();
                          final formattedTimeDifference =
                              formatTimeDifference(lastUpdated);

                          return FriendsTile(
                            friendName:
                                value.friendsWithRewards[index]!['userName'],
                            sentFoodImage:
                                value.friendsWithRewards[index]!['rewardShare']
                                    ['rewardType'],
                            sentTo:
                                value.friendsWithRewards[index]!['rewardShare']
                                    ['sentTo'],
                            location: '',
                            time: formattedTimeDifference,
                            friendImage:
                                value.friendsWithRewards[index]!['photo'],
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
            // const FriendsTile(
            //   friendName: 'Cassandre',
            //   sentFoodImage: 'burger 1.png',
            //   sentTo: 'Jeff Katz',
            //   location: 'Blue State Coffee',
            //   time: '1 m',
            //   friendImage: '7.png',
            // ),
            // const FriendsTile(
            //   friendName: 'Mikel Jhons',
            //   sentFoodImage: 'coffee 1.png',
            //   sentTo: 'Jeff Katz',
            //   location: 'Blue State Coffee',
            //   time: '1 m',
            //   friendImage: '8.png',
            // ),
            // const FriendsTile(
            //   friendName: 'Mikel Jhons',
            //   sentFoodImage: 'buritto 1.png',
            //   sentTo: 'Jeff Katz',
            //   location: 'Blue State Coffee',
            //   time: '1 m',
            //   friendImage: '9.png',
            // ),
          ],
        ),
      ),
    );
  }
}
