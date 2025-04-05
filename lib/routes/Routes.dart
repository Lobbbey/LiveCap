import 'package:flutter/material.dart';

class Routes {
  static const String HOMESCREEN = '/home';

  static Map<String, Widget Function(BuildContext)> get getroutes => {
    '/': (context) => HomeScreen(),
  };
}