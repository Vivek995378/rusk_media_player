import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

typedef CustomPageBuilderWidget =
    CustomTransitionPage<void> Function(
  BuildContext context,
  GoRouterState state,
  Widget child,
);

CustomPageBuilderWidget customPageBuilderWidget = (
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(
      milliseconds: 250,
    ),
    reverseTransitionDuration: const Duration(
      milliseconds: 200,
    ),
    transitionsBuilder: (
      context,
      animation,
      secondaryAnimation,
      child,
    ) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        ),
        child: child,
      );
    },
  );
};
