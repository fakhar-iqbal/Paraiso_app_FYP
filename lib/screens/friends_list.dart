import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:paraiso/util/local_storage/shared_preferences_helper.dart';
import 'package:paraiso/widgets/friends_tile.dart';
import 'package:provider/provider.dart';

import '../controllers/friends_controller.dart';
import '../widgets/restaurant_tile.dart';

class HomeFriendsList extends StatefulWidget {
  const HomeFriendsList({Key? key}) : super(key: key);

  @override
  State<HomeFriendsList> createState() => _HomeFriendsListState();
}

class _HomeFriendsListState extends State<HomeFriendsList> {
  late FriendsController _friendsController;

  String mySchool = "";

  @override
  void didChangeDependencies() async {
    _friendsController = Provider.of<FriendsController>(context, listen: false);
    // final email = SharedPreferencesHelper.getCustomerEmail();
    await _friendsController.getFriendsWithRewards();
    super.didChangeDependencies();
  }

  bool CheckIsFriend({dynamic friendList, dynamic singeUser, isOrder = false}) {
    for (var i = 0; i < friendList.length; i++) {
      if (isOrder) {
        if (friendList[i]['userName'] == singeUser['user']) {
          return true;
        }
      } else if (friendList[i]['email'] == singeUser['senderEmail']) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FriendsController>(
      builder: (context, value, child) {
        return SizedBox(
          width: double.infinity,
          height: MediaQuery.sizeOf(context).height * .65,
          child: value.friendsWithRewards.isEmpty
              ? Center(
                  child:
                      Text(AppLocalizations.of(context)!.noFriendsUpdatesYet))
              : RefreshIndicator(
                  onRefresh: () async {
                    await _friendsController.getFriendsWithRewards(
                        letLoading: false);
                  },
                  child: SharedPreferencesHelper.getCustomerType() == 'guest'
                      ? SizedBox()
                      : ListView.builder(
                          itemCount: value.friendsWithRewards.length,
                          itemBuilder: (context, index) {
                            final lastUpdatedTimestamp = value
                                        .friendsWithRewards[index]!['type'] ==
                                    'reward'
                                ? value.friendsWithRewards[index]!['sentOn']
                                : value.friendsWithRewards[index]!['orderTime'];
                            // final DateTime lastUpdated = lastUpdatedTimestamp.toDate();
                            final formattedTimeDifference =
                                formatTimeDifference(lastUpdatedTimestamp);

                            return value.friendsWithRewards[index]!['type'] ==
                                    'reward'
                                ? Column(
                                    children: [
                                      FriendsTile(
                                        friendName: value.friendsWithRewards[
                                            index]!['sender'],
                                        sentFoodImage: "Coconut",
                                        sentTo: value.friendsWithRewards[
                                            index]!['sentTo'],
                                        location: '',
                                        time: formattedTimeDifference,
                                        friendImage: value.friendsWithRewards[
                                                index]!['photo'] ??
                                            "",
                                      )
                                    ],
                                  )
                                : Column(
                                    children: [
                                      FriendRewardFrmRestaurantTile(
                                        userName: value
                                            .friendsWithRewards[index]!['user'],
                                        restaurant: value.friendsWithRewards[
                                            index]!['restaurantName'],
                                        location: "",
                                        itemOrdered: value.friendsWithRewards[
                                            index]!['itemName'],
                                        time: formattedTimeDifference,
                                        friendImage: value.friendsWithRewards[
                                                index]!['photo'] ??
                                            "",
                                      ),
                                    ],
                                  );
                          },
                        ),
                ),
        );
      },
    );
  }
}
