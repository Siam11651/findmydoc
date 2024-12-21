import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:find_my_doc/globals.dart';
import 'package:find_my_doc/types.dart';
import 'package:find_my_doc/widgets/start.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  Widget _body = const Center();

  void _initStateAsync() async {
    SharedPreferencesAsync prefs = SharedPreferencesAsync();

    String? userJson = await prefs.getString('user');

    if(userJson != null) {
      Map<String, dynamic> jsonMap = jsonDecode(userJson);
      String? id = jsonMap['id'];

      if(id != null) {
        user = User(
            id: id,
            name: jsonMap['name'],
            imageUrl: jsonMap['image'],
            accToken: jsonMap['acc-token']
        );
      }
    }
  
    if(user == null) {
      GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if(googleUser == null) {
        Fluttertoast.showToast(msg: 'Signin to continue');
        SystemNavigator.pop();
      } else {
        GoogleSignInAuthentication auth = await googleUser.authentication;
        user = User(
          id: googleUser.id,
          name: googleUser.displayName,
          imageUrl: googleUser.photoUrl,
          accToken: auth.accessToken!
        );
        Map<String, String?> jsonMap = {};
        jsonMap['id'] = googleUser.id;
        jsonMap['name'] = googleUser.displayName;
        jsonMap['image'] = googleUser.photoUrl;
        jsonMap['acc-token'] = auth.accessToken;

        prefs.setString('user', jsonEncode(jsonMap));
      }

    //   register(user!.id, user!.accToken);
    }

    setState(() {
      _body = const Start();
    });
  }

  @override
  void initState() {
    super.initState();
    _initStateAsync();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body
    );
  }
}