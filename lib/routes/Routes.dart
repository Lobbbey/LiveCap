import 'package:flutter/material.dart';
//import 'package:live_cap/routes/Routes.dart';
import 'package:live_cap/screens/HomeScreen.dart';
class Routes{
  static const String HOMESCREEN = '/home';

  static Map<String, Widget Function(BuildContext)> get getroutes => {
   '/': (context) => Homescreen(),
   HOMESCREEN: (context) => Homescreen(),
  };
}