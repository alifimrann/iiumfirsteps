import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/models.dart';

class AppState extends ChangeNotifier {
  int currentTabIndex = 0;
  Place? selectedMapPlace;
  Lecturer? selectedMapLecturer;
  LatLng? userLocation;
  
  // Routing state
  List<LatLng> routePoints = [];
  String? routeDistance;
  String? routeDuration;
  bool isRouting = false;
  bool isLocationLoading = false;

  void setTabIndex(int index) {
    currentTabIndex = index;
    notifyListeners();
  }

  void selectPlaceOnMap(Place place) {
    selectedMapPlace = place;
    selectedMapLecturer = null;
    currentTabIndex = 1; // Map Tab
    clearRoute();
    notifyListeners();
  }

  void selectLecturerOnMap(Lecturer lecturer) {
    selectedMapLecturer = lecturer;
    selectedMapPlace = null;
    currentTabIndex = 1; // Map Tab
    clearRoute();
    notifyListeners();
  }

  void clearSelection() {
    selectedMapPlace = null;
    selectedMapLecturer = null;
    clearRoute();
    notifyListeners();
  }

  void setUserLocation(LatLng location) {
    userLocation = location;
    notifyListeners();
  }

  void clearRoute() {
    routePoints = [];
    routeDistance = null;
    routeDuration = null;
    isRouting = false;
    notifyListeners();
  }

  Future<void> getUserRealLocation() async {
    isLocationLoading = true;
    notifyListeners();

    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      } 

      // Using low accuracy here to avoid hanging on emulators, but high is better for maps
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      
      userLocation = LatLng(position.latitude, position.longitude);
    } catch (e) {
      debugPrint("Error getting location: $e");
    } finally {
      isLocationLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRoute(LatLng destination) async {
    if (userLocation == null) return;
    
    isRouting = true;
    notifyListeners();

    try {
      final start = userLocation!;
      final end = destination;
      
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/foot/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final routes = data['routes'] as List;
        
        if (routes.isNotEmpty) {
          final route = routes[0];
          
          // distance is in meters, duration is in seconds
          final distanceMeters = route['distance'] as num;
          final durationSeconds = route['duration'] as num;
          
          if (distanceMeters > 1000) {
            routeDistance = '${(distanceMeters / 1000).toStringAsFixed(1)} km';
          } else {
            routeDistance = '${distanceMeters.toStringAsFixed(0)} m';
          }
          
          final minutes = (durationSeconds / 60).ceil();
          routeDuration = '$minutes min';

          final geometry = route['geometry'];
          final coordinates = geometry['coordinates'] as List;
          
          routePoints = coordinates.map((c) => LatLng(c[1] as double, c[0] as double)).toList();
        }
      }
    } catch (e) {
      debugPrint("Error fetching route: $e");
    } finally {
      isRouting = false;
      notifyListeners();
    }
  }
}

final appState = AppState();
