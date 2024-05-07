import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:loader_overlay/loader_overlay.dart';

class NavigationService {
  static NavigationService get instance {
    return GetIt.instance<NavigationService>();
  }

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

  String? lastObservedPush;

  void showLoaderOverlay() {
    navigatorKey.currentState?.context.loaderOverlay.show();
  }

  void hideLoaderOverlay() {
    navigatorKey.currentState?.context.loaderOverlay.hide();
  }
}
