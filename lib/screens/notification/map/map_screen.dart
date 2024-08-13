import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:habitatgn/models/house_result_model.dart';
import 'package:habitatgn/utils/appcolors.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';

class LocationMapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String address;
  final HouseType houseType;

  const LocationMapScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.houseType,
  });

  @override
  _LocationMapScreenState createState() => _LocationMapScreenState();
}

class _LocationMapScreenState extends State<LocationMapScreen> {
  late LocationData _userLocation;
  late Location _location;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  String _distance = '';
  bool _isLoading = true;
  GoogleMapController? _mapController;
  final Completer<void> _mapCreatedCompleter = Completer<void>();
  final MarkerId _houseMarkerId = const MarkerId('houseLocation');

  @override
  void initState() {
    super.initState();
    _location = Location();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      final permission = await _location.hasPermission();
      if (permission == PermissionStatus.granted) {
        _userLocation = await _location.getLocation();
        _calculateDistance();
        _addMarkersAndPolyline();
      } else if (permission == PermissionStatus.denied) {
        final result = await _location.requestPermission();
        if (result == PermissionStatus.granted) {
          _userLocation = await _location.getLocation();
          _calculateDistance();
          _addMarkersAndPolyline();
        }
      }
    } catch (e) {
      print('Erreur lors de la récupération de la localisation : $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _calculateDistance() {
    final distanceInMeters = Geolocator.distanceBetween(
      _userLocation.latitude!,
      _userLocation.longitude!,
      widget.latitude,
      widget.longitude,
    );
    setState(() {
      _distance = (distanceInMeters / 1000).toStringAsFixed(2);
    });
  }

  void _addMarkersAndPolyline() {
    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId('userLocation'),
          position: LatLng(_userLocation.latitude!, _userLocation.longitude!),
          infoWindow: InfoWindow(
            title: 'Votre Position',
            snippet:
                'Lat: ${_userLocation.latitude}, Lng: ${_userLocation.longitude}',
          ),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        ),
      );

      _markers.add(
        Marker(
          markerId: _houseMarkerId,
          position: LatLng(widget.latitude, widget.longitude),
          infoWindow: InfoWindow(
            title: '🏠  ${widget.houseType.label}',
            snippet: 'Adresse : ${widget.address}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
        ),
      );

      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          visible: true,
          points: [
            LatLng(_userLocation.latitude!, _userLocation.longitude!),
            LatLng(widget.latitude, widget.longitude),
          ],
          color: primaryColor,
          width: 8,
          patterns: [
            PatternItem.dash(20),
            PatternItem.gap(10),
          ],
        ),
      );
    });
    // _animateCameraToMarker();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    // _mapCreatedCompleter.complete();
    // _animateCameraToMarker();
  }

  Future<void> _animateCameraToMarker() async {
    if (_mapController == null) return;

    try {
      await _mapCreatedCompleter.future;
      if (_markers.any((marker) => marker.markerId == _houseMarkerId)) {
        await _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(widget.latitude, widget.longitude),
            15,
          ),
        );
        _mapController!.showMarkerInfoWindow(_houseMarkerId);
      }
    } catch (e) {
      print(
          'Erreur lors de l\'animation de la caméra ou de l\'affichage de l\'InfoWindow : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final CameraPosition initialPosition = CameraPosition(
      target: LatLng(widget.latitude, widget.longitude),
      zoom: 15,
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_outlined),
          onPressed: () => Navigator.pop(context),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text(
          'Localisation  (${widget.houseType.label})',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: initialPosition,
            markers: _markers,
            polylines: _polylines,
            onMapCreated: _onMapCreated,
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            ),
          Positioned(
            bottom: 20.0,
            left: 16.0,
            right: 16.0,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8.0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: primaryColor, size: 32.0),
                      const SizedBox(width: 8.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Distance : $_distance km',
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            'Adresse : ${widget.address}',
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
