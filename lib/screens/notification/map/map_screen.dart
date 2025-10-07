// ignore_for_file: avoid_print, deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:habitatgn/models/dailyRental/daily_rental.dart';
import 'package:habitatgn/utils/appcolors.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

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

class _LocationMapScreenState extends State<LocationMapScreen>
    with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  LocationData? _userLocation;
  late Location _location;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  String _distance = '';
  String _duration = '';
  bool _isLoading = true;
  bool _permissionDenied = false;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _location = Location();
    _setupAnimations();
    _initializeMap();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 100.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  Future<void> _initializeMap() async {
    await _getUserLocation();
    _addHouseMarker();
    _animationController.forward();
  }

  Future<void> _getUserLocation() async {
    try {
      // Vérifier si le service de localisation est activé
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          _showLocationServiceDialog();
          return;
        }
      }

      // Vérifier les permissions
      PermissionStatus permission = await _location.hasPermission();
      if (permission == PermissionStatus.denied) {
        permission = await _location.requestPermission();
        if (permission != PermissionStatus.granted) {
          setState(() {
            _permissionDenied = true;
            _isLoading = false;
          });
          return;
        }
      }

      // Obtenir la localisation
      _userLocation = await _location.getLocation();
      if (_userLocation != null) {
        _calculateDistance();
        _addUserMarker();
        _addRoutePolyline();
        _fitMarkersOnScreen();
      }
    } catch (e) {
      print('Erreur lors de la récupération de la localisation : $e');
      _showError('Impossible d\'obtenir votre localisation');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _calculateDistance() {
    if (_userLocation == null) return;

    final distanceInMeters = Geolocator.distanceBetween(
      _userLocation!.latitude!,
      _userLocation!.longitude!,
      widget.latitude,
      widget.longitude,
    );

    setState(() {
      _distance = (distanceInMeters / 1000).toStringAsFixed(1);
      // Estimation approximative du temps de trajet (vitesse moyenne 30 km/h en ville)
      final durationInMinutes = (distanceInMeters / 1000) * 2;
      _duration = durationInMinutes < 60
          ? '${durationInMinutes.round()} min'
          : '${(durationInMinutes / 60).toStringAsFixed(1)}h';
    });
  }

  void _addHouseMarker() {
    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId('houseLocation'),
          position: LatLng(widget.latitude, widget.longitude),
          infoWindow: InfoWindow(
            title: widget.houseType.label,
            snippet: widget.address,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    });
  }

  void _addUserMarker() {
    if (_userLocation == null) return;

    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId('userLocation'),
          position: LatLng(_userLocation!.latitude!, _userLocation!.longitude!),
          infoWindow: const InfoWindow(
            title: 'Votre position',
            snippet: 'Vous êtes ici',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    });
  }

  void _addRoutePolyline() {
    if (_userLocation == null) return;

    setState(() {
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          visible: true,
          points: [
            LatLng(_userLocation!.latitude!, _userLocation!.longitude!),
            LatLng(widget.latitude, widget.longitude),
          ],
          color: primaryColor,
          width: 4,
          patterns: [
            PatternItem.dash(20),
            PatternItem.gap(10),
          ],
        ),
      );
    });
  }

  void _fitMarkersOnScreen() {
    if (_mapController == null || _userLocation == null) return;

    final bounds = LatLngBounds(
      southwest: LatLng(
        _userLocation!.latitude! < widget.latitude
            ? _userLocation!.latitude!
            : widget.latitude,
        _userLocation!.longitude! < widget.longitude
            ? _userLocation!.longitude!
            : widget.longitude,
      ),
      northeast: LatLng(
        _userLocation!.latitude! > widget.latitude
            ? _userLocation!.latitude!
            : widget.latitude,
        _userLocation!.longitude! > widget.longitude
            ? _userLocation!.longitude!
            : widget.longitude,
      ),
    );

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100.0),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_userLocation != null) {
      _fitMarkersOnScreen();
    }
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.location_off_outlined,
                color: Colors.orange[600],
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Service de localisation',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        content: Text(
          'Le service de localisation est désactivé. Activez-le pour voir votre position sur la carte.',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Plus tard',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              _getUserLocation();
            },
            child: Text(
              'Réessayer',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> _openInGoogleMaps() async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=${widget.latitude},${widget.longitude}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      _showError('Impossible d\'ouvrir Google Maps');
    }
  }

  Future<void> _getDirections() async {
    if (_userLocation == null) {
      _showError('Position utilisateur non disponible');
      return;
    }

    final url =
        'https://www.google.com/maps/dir/?api=1&origin=${_userLocation!.latitude},${_userLocation!.longitude}&destination=${widget.latitude},${widget.longitude}&travelmode=driving';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      _showError('Impossible d\'ouvrir les directions');
    }
  }

  @override
  Widget build(BuildContext context) {
    final CameraPosition initialPosition = CameraPosition(
      target: LatLng(widget.latitude, widget.longitude),
      zoom: 15,
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_outlined),
          color: Colors.grey[700],
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Localisation',
          style: GoogleFonts.poppins(
            color: Colors.grey[800],
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey[200],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.open_in_new_outlined,
              color: Colors.grey[700],
            ),
            onPressed: _openInGoogleMaps,
            tooltip: 'Ouvrir dans Google Maps',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Carte
          GoogleMap(
            initialCameraPosition: initialPosition,
            markers: _markers,
            polylines: _polylines,
            onMapCreated: _onMapCreated,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
            rotateGesturesEnabled: true,
            scrollGesturesEnabled: true,
            tiltGesturesEnabled: true,
            zoomGesturesEnabled: true,
          ),

          // Indicateur de chargement
          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: primaryColor,
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Chargement de la carte...',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Message d'erreur de permission
          if (_permissionDenied && !_isLoading)
            Positioned(
              top: 20,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_off_outlined,
                      color: Colors.orange[600],
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Permission refusée',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: Colors.orange[800],
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Activez la localisation pour voir votre position',
                            style: GoogleFonts.poppins(
                              color: Colors.orange[700],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Informations en bas
          AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return Positioned(
                bottom: _slideAnimation.value + 20,
                left: 16,
                right: 16,
                child: _buildInfoCard(),
              );
            },
          ),

          // Bouton de recentrage
          if (_userLocation != null)
            Positioned(
              top: 20,
              right: 16,
              child: FloatingActionButton.small(
                onPressed: _fitMarkersOnScreen,
                backgroundColor: Colors.white,
                foregroundColor: primaryColor,
                elevation: 4,
                child: const Icon(Icons.center_focus_strong_outlined),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // En-tête
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.location_on_outlined,
                  color: primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.houseType.label,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      widget.address,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (_distance.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildDistanceInfo(
                      'Distance',
                      '$_distance km',
                      Icons.straighten_outlined,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: Colors.grey[300],
                  ),
                  Expanded(
                    child: _buildDistanceInfo(
                      'Temps estimé',
                      _duration,
                      Icons.access_time_outlined,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Boutons d'action
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _openInGoogleMaps,
                  icon: const Icon(Icons.map_outlined, size: 18),
                  label: Text(
                    'Google Maps',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: BorderSide(color: primaryColor.withOpacity(0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              if (_userLocation != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _getDirections,
                    icon: const Icon(Icons.directions_outlined, size: 18),
                    label: Text(
                      'Itinéraire',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceInfo(String label, String value, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 6),
        Column(
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
