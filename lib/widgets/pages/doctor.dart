import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';

void docLocOnstart(ServiceInstance service) {
    final timer = Timer.periodic(
        const Duration(seconds: 30),
        (timer) async {
            Position position = await Geolocator.getCurrentPosition();

            Fluttertoast.showToast(msg: "latitude: ${position.latitude}\nlongitude: ${position.longitude}");
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
    FlutterBackgroundService? service;

    void _initService() {
        service = FlutterBackgroundService();
        
        service!.configure(
            androidConfiguration: AndroidConfiguration(
                onStart: docLocOnstart,
                isForegroundMode: true
            ),
            iosConfiguration: IosConfiguration()
        );
    }

    void _destoryService() {
        if(service != null) {
            service!.invoke("stop");

            service = null;
        }
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