import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'location_permission.dart';
//수정 본
class MyGoogleMap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _MapSample();
  }
}

class _MapSample extends StatefulWidget {
  @override
  State<_MapSample> createState() => _MapSampleState();
}

class _MapSampleState extends State<_MapSample> {
  Completer<GoogleMapController> _controller = Completer();

  Set<Marker> _markers = {};
  MyLocation myLocation = MyLocation();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.5271883, 126.9659283),
    zoom: 14.4746,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  // 남산타워 위치 설정
  static final CameraPosition _kNamsanTower = CameraPosition(
    target: LatLng(37.5511694, 126.9882266),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    _initializeMarkers();
  }

  void _initializeMarkers() {
    _markers.add(
      Marker(
        markerId: MarkerId('_kGooglePlex'),
        position: _kGooglePlex.target,
        infoWindow: InfoWindow(
          title: 'Google Plex',
          snippet: 'Google Headquarters',
        ),
        icon: BitmapDescriptor.defaultMarker,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: _kGooglePlex,
        markers: _markers,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton.extended(
            onPressed: (){myLocation.getMyCurrentLocation();},
            label: Text('To the lake!'),
            icon: Icon(Icons.directions_boat),
          ),
          SizedBox(width: 16), // 버튼 사이의 간격
          FloatingActionButton.extended(
            onPressed: _goToNamsanTower,
            label: Text('To Namsan Tower!'),
            icon: Icon(Icons.landscape),
          ),
        ],
      ),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }

  // 남산타워로 이동하는 함수
  Future<void> _goToNamsanTower() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kNamsanTower));
  }
}

