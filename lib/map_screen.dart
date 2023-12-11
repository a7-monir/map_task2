import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:location/location.dart';

class MapView extends StatefulWidget {
  const MapView({Key? key}) : super(key: key);

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> with WidgetsBindingObserver{

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  LocationData? currentLocation;


  void getCurrentLocation() async {
    Location location = Location();
    location.getLocation().then(
      (location) {
        currentLocation = location;
        setState(() {
          FirebaseFirestore.instance.collection('users').doc('user1').set({
            "lat":currentLocation!.latitude!,
            "long":currentLocation!.longitude!
          });

        });
      },
    );
    GoogleMapController googleMapController = await _controller.future;

    location.onLocationChanged.listen((newLoc) {
      currentLocation = newLoc;
      googleMapController
          .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
              target: LatLng(
        newLoc.latitude!,
        newLoc.longitude!,
      ),zoom: 15)));
      setState(() {
        FirebaseFirestore.instance.collection('users').doc('user1').update({
          "lat":newLoc.latitude!,
          "long":newLoc.longitude!
        });
      });
    });
    setState(() {});

  }


  @override
  void initState() {
    getCurrentLocation();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      currentLocation == null
          ? const Center(
              child: Text("loading"),
            )
          :
      GoogleMap(
        initialCameraPosition:
        CameraPosition(target: LatLng(currentLocation!.latitude!, currentLocation!.longitude!), zoom: 15),

        markers: {
          Marker(
            markerId: const MarkerId('current'),
            position: LatLng(currentLocation!.latitude!,
                currentLocation!.longitude!),
          ),
        },
        onMapCreated: (mapController) {
          _controller.complete(mapController);
        },
      ),
    );
  }
}
