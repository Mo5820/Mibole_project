import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final DateTime dateTime;

  const MapScreen({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.dateTime,
  }) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
      ),
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
          _controller.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(widget.latitude, widget.longitude),
                zoom: 15.0,
              ),
            ),
          );
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.latitude, widget.longitude),
          zoom: 15.0,
        ),
        markers: {
          Marker(
            markerId: MarkerId('user-location'),
            position: LatLng(widget.latitude, widget.longitude),
            infoWindow: InfoWindow(
              title: 'Accident Location',
              snippet:
                  '${widget.dateTime.day}/${widget.dateTime.month}/${widget.dateTime.year} ${widget.dateTime.hour}:${widget.dateTime.minute}',
            ),
          ),
        },
      ),
    );
  }
}
