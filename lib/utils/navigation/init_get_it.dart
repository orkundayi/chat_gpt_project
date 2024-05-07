import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'navigation_service.dart';

GetIt getIt = GetIt.instance;

void initGetIt() {
  // Contextless navigation service
  getIt.registerLazySingleton(() => NavigationService());
  getIt.registerLazySingleton(() => GlobalKey<ScaffoldState>());
}
