import 'package:flutter/material.dart';
import 'package:paraiso/screens/friends_list.dart';
import 'package:velocity_x/velocity_x.dart';

class AllList extends StatelessWidget {
  const AllList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const VStack([
      HomeFriendsList(),
    ]);
  }
}
