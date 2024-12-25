import 'package:find_my_doc/types.dart';
import 'package:flutter/material.dart';

const APIHOST = "http://192.168.50.168:3000";
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

class GlobalState {
  // Singleton instance
  static final GlobalState _instance = GlobalState._internal();

  factory GlobalState() {
    return _instance;
  }

  GlobalState._internal();

  User? user;
}