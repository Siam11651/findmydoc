import 'dart:async';
import 'dart:convert';

import 'package:find_my_doc/globals.dart';
import 'package:find_my_doc/types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<void> updateLocation(User user) async {
    Position position = await Geolocator.getCurrentPosition();

    http
        .post(
            Uri.parse('$APIHOST/update-location'),
            body: jsonEncode({
                'latitude': position.latitude,
                'longitude': position.longitude,
                'acc-token': user.accToken,
            })
        );
}

Future<void> docLocOnstart(ServiceInstance service) async {
    User user;
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
      } else {
        service.stopSelf();

        return;
      }
    } else {
        service.stopSelf();

        return;
    }

    updateLocation(user);

    final timer = Timer.periodic(
        const Duration(seconds: 30),
        (timer) {
            updateLocation(user);
        }
    );

    service.on("stop").listen((data) {
        timer.cancel();
        service.stopSelf();
    });
}

class DoctorPage extends StatefulWidget {
  const DoctorPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _DoctorPageState();
  }
}

class _DoctorPageState extends State<DoctorPage> {
    bool ready = false;
    FlutterBackgroundService service = FlutterBackgroundService();

    void _initService() {
        service.configure(
            androidConfiguration: AndroidConfiguration(
                onStart: docLocOnstart,
                isForegroundMode: true
            ),
            iosConfiguration: IosConfiguration()
        );
    }

    void _destoryService() {
        service.invoke("stop");
    }

    @override
    void initState() {
        super.initState();
        _destoryService();
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(),
            body: Column(
                children: [
                    Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                                const Text("Visible"),
                                Switch(value: ready, onChanged: (newValue) async {
                                    if(newValue) {
                                        LocationPermission locationPermission = await Geolocator.checkPermission();

                                        if(locationPermission == LocationPermission.denied) {
                                            locationPermission = await Geolocator.requestPermission();

                                            if(locationPermission == LocationPermission.denied) {
                                                Fluttertoast.showToast(msg: "Need location permission");

                                                return;
                                            }
                                        }

                                        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

                                        if(!serviceEnabled) {
                                            await Geolocator.openLocationSettings();

                                            return;
                                        }
                                    }

                                    setState(() {
                                        ready = newValue;

                                        if(ready) {
                                            _initService();
                                        } else {
                                            _destoryService();
                                        }
                                    });
                                })
                            ],
                        ),
                    )
                ],
            ),
        );
    }

    @override
  void dispose() {
    _destoryService();
    super.dispose();
  }
}