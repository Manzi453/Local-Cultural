import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../constants/app_constants.dart';
import '../models/place_model.dart';

class MapViewWidget extends StatefulWidget {
  final Place? place;
  final List<Place> places;
  final Function(Place)? onPlaceSelected;
  final bool isInteractive;

  const MapViewWidget({
    super.key,
    this.place,
    this.places = const [],
    this.onPlaceSelected,
    this.isInteractive = true,
  });

  @override
  State<MapViewWidget> createState() => _MapViewWidgetState();
}

class _MapViewWidgetState extends State<MapViewWidget> {
  GoogleMapController? _controller;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initializeMarkers();
  }

  @override
  void didUpdateWidget(MapViewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.place != widget.place || oldWidget.places != widget.places) {
      _initializeMarkers();
    }
  }

  void _initializeMarkers() {
    _markers = {};
    
    if (widget.place != null) {
      _markers.add(Marker(
        markerId: MarkerId(widget.place!.id),
        position: LatLng(widget.place!.latitude, widget.place!.longitude),
        infoWindow: InfoWindow(
          title: widget.place!.name,
          snippet: widget.place!.address,
        ),
      ));
    }
    
    for (final place in widget.places) {
      _markers.add(Marker(
        markerId: MarkerId(place.id),
        position: LatLng(place.latitude, place.longitude),
        infoWindow: InfoWindow(
          title: place.name,
          snippet: place.address,
        ),
        onTap: () {
          if (widget.onPlaceSelected != null) {
            widget.onPlaceSelected!(place);
          }
        },
      ));
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
    
    // Set initial camera position
    if (widget.place != null) {
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(widget.place!.latitude, widget.place!.longitude),
          AppConstants.defaultZoom,
        ),
      );
    } else if (widget.places.isNotEmpty) {
      // Calculate bounds for all places
      double minLat = widget.places.first.latitude;
      double maxLat = widget.places.first.latitude;
      double minLng = widget.places.first.longitude;
      double maxLng = widget.places.first.longitude;
      
      for (final place in widget.places) {
        if (place.latitude < minLat) minLat = place.latitude;
        if (place.latitude > maxLat) maxLat = place.latitude;
        if (place.longitude < minLng) minLng = place.longitude;
        if (place.longitude > maxLng) maxLng = place.longitude;
      }
      
      controller.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat, minLng),
            northeast: LatLng(maxLat, maxLng),
          ),
          50,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Default to Kigali coordinates
    final LatLng initialPosition = widget.place != null
        ? LatLng(widget.place!.latitude, widget.place!.longitude)
        : LatLng(AppConstants.kigaliLatitude, AppConstants.kigaliLongitude);

    return Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      clipBehavior: Clip.antiAlias,
      child: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: initialPosition,
          zoom: AppConstants.defaultZoom,
        ),
        markers: _markers,
        myLocationEnabled: false,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: widget.isInteractive,
        mapToolbarEnabled: false,
        compassEnabled: true,
      ),
    );
  }

  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

// Simple static map placeholder (for when Google Maps is not configured)
class StaticMapPlaceholder extends StatelessWidget {
  final Place place;
  final double height;

  const StaticMapPlaceholder({
    super.key,
    required this.place,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.map,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            place.name,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            place.address,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              // Launch maps for navigation
              _launchMaps(place.latitude, place.longitude, place.name);
            },
            icon: const Icon(Icons.directions),
            label: const Text('Get Directions'),
          ),
        ],
      ),
    );
  }

  void _launchMaps(double lat, double lng, String name) {
    // This would use url_launcher in the actual implementation
    print('Navigate to: $name at ($lat, $lng)');
  }
}

