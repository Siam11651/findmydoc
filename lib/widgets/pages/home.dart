import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:icare/globals.dart';
import 'package:icare/types.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  Widget? _body;

  @override
  void initState() async {
    super.initState();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('user');

    if(userJson != null) {
      Map<String, String?> jsonMap = jsonDecode(userJson);
      String? id = jsonMap['id'];

      if(id != null) {
        user = User(id, jsonMap['name'], jsonMap['image']);
      }
    }

    if(user == null) {
      GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if(googleUser == null) {
        Fluttertoast.showToast(msg: 'Signin to continue');
        SystemNavigator.pop();
      } else {
        user = User(googleUser.id, googleUser.displayName, googleUser.photoUrl);
        Map<String, String?> jsonMap = {};
        jsonMap['id'] = googleUser.id;
        jsonMap['name'] = googleUser.displayName;
        jsonMap['image'] = googleUser.photoUrl;

        prefs.setString('user', jsonEncode(jsonMap));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body
    );
  }
}