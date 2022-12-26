/// Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.
import 'package:flutter/material.dart';

import 'my_home_page.dart';


class NavigationHelper {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<HomepageState> key =
      GlobalKey<HomepageState>();



  static Future<void> pop() => navigatorKey.currentState!.maybePop();
}

