import 'dart:async';
import 'dart:convert';

import 'package:find_my_doc/globals.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class MapPage extends StatefulWidget {
    const MapPage({super.key});
    
    @override
    State<StatefulWidget> createState() {
        return _MapPageState();
    }
}

class _MapPageState extends State<MapPage> {
    late final Timer _timer;
    Marker _meMarker = const Marker(markerId: MarkerId(''));
    final Set<Marker> _doctorsMarkers = {};
    final Set<Marker> _markers = {};
    final Completer<GoogleMapController> _mapControllerCompleter = Completer<GoogleMapController>();

    Future<void> _update() async {
        Position position = await Geolocator.getCurrentPosition();
        http.Response response = await http.post(
            Uri.parse('$APIHOST/get-doctors'),
            body: jsonEncode({
                'latitude': position.latitude,
                'longitude': position.longitude,
                'acc-token': GlobalState().user!.accToken
            })
        );

        if(response.statusCode == 200) {
            List<dynamic> doctors = jsonDecode(response.body);

            _doctorsMarkers.clear();

            for(int i = 0; i < doctors.length; ++i) {
                final Map<String, dynamic> doctor = doctors[i];
                final String id = doctor['id'];

                _doctorsMarkers.add(
                    Marker(
                        markerId: MarkerId(id),
                        position: LatLng(doctor['latitude'], doctor['longitude']),
                        onTap: () {
                            showMaterialModalBottomSheet(
                                context: context,
                                builder: (_) {
                                    return SizedBox(
                                        height: 500,
                                        child: Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                    Text(
                                                        id,
                                                        style: const TextStyle(
                                                            fontSize: 24
                                                        ),
                                                    ),
                                                    FilledButton(
                                                        onPressed: () {

                                                        },
                                                        child: const Text('Request Doctor')
                                                    )
                                                ],
                                            ),
                                        )
                                    );
                                },
                            );
                        }
                    )
                );
            }

            setState(() {
                _markers.clear();
                _markers.add(_meMarker);
                _markers.addAll(_doctorsMarkers);
            });
        }
    }

    Future<void> _init() async {
        LocationPermission locationPermission = await Geolocator.checkPermission();

        if(locationPermission == LocationPermission.denied) {
            locationPermission = await Geolocator.requestPermission();

            if(locationPermission == LocationPermission.denied) {
                Fluttertoast.showToast(msg: "Need location permission");
                WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.pop(context);
                });

                return;
            }
        }

        final Position position = await Geolocator.getCurrentPosition();
        final LatLng latlng = LatLng(position.latitude, position.longitude);

        _meMarker = Marker(
            markerId: const MarkerId(''),
            position: latlng,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
        );
        _mapControllerCompleter.future.then((controller) {
            controller.animateCamera(
                CameraUpdate
                    .newCameraPosition(
                        CameraPosition(
                            target: latlng,
                            zoom: 20
                        )
                    )
            );
        });
        _update();

        _timer = Timer.periodic(
            const Duration(seconds: 30),
            (_) {
                _update();
            }
        );

        setState(() {
          _markers.clear();
          _markers.add(_meMarker);
          _markers.addAll(_doctorsMarkers);
        });
    }

    @override
    void initState() {
        super.initState();
        _init();
    }

    @override
    void dispose() {
        _timer.cancel();
        _mapControllerCompleter.future.then((controller) {
            controller.dispose();
        });
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: GoogleMap(
                initialCameraPosition: const CameraPosition(
                    target: LatLng(0.0, 0.0)
                ),
                markers: _markers,
                onMapCreated: (GoogleMapController controller) {
                    _mapControllerCompleter.complete(controller);
                },
            ),
        );
    }
}