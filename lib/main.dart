import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import 'map.dart';

void main() => runApp(MaterialApp(home: MyApp()));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<double> _accelerometerValues = [];
  List<StreamSubscription<dynamic>> _streamSubscriptions =
  <StreamSubscription<dynamic>>[];
  bool _isAccidentDetected = false;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _streamSubscriptions
        .add(accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometerValues = <double>[event.x, event.y, event.z];
        if (!_isAccidentDetected &&
            (_accelerometerValues[0] > 20 ||
                _accelerometerValues[1] > 20 ||
                _accelerometerValues[2] > 20)) {
          _isAccidentDetected = true;
          _getLocation();

          // Stop the accelerometer subscription
          _streamSubscriptions[0].cancel();
        }
      });
    }));
  }

  void _requestLocationPermission() async {
    final PermissionStatus permissionStatus =
    await Permission.location.request();
    if (permissionStatus != PermissionStatus.granted) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text('Location permission'),
          content:
          Text('Please grant location permission to use this feature.'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Get the current date and time
    DateTime now = DateTime.now();
    String formattedDateTime =
        '${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute}';

    // Show a dialog with the current date and time
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Accident Detected!'),
        content: Text(
            'An accident was detected at $formattedDateTime.\nDo you want to view the location on map?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MapScreen(
                    latitude: position.latitude,
                    longitude: position.longitude,
                    dateTime: now,
                  ),
                ),
              );
            },
            child: Text('Yes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Accident Detection'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Accelerometer: $_accelerometerValues'),
              Text('Is Accident Detected? $_isAccidentDetected'),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }
}