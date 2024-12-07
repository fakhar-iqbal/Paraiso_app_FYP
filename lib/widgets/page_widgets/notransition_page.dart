import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class NoTransitionPage<T> extends CustomTransitionPage<T> {
  NoTransitionPage({
    required Widget child,
    LocalKey? key,
    String? name,
    Object? arguments,
    String? restorationId,
  }) : super(
          key: key,
          child: child,
          name: name,
          arguments: arguments,
          restorationId: restorationId,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return child;
          },
        );
}
