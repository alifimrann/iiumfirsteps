import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';
import '../core/theme.dart';
import '../core/app_state.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  List<Place> _allPlaces = [];
  List<Place> _filteredPlaces = [];
  bool _isLoadingPlaces = true;
  final TextEditingController _searchController = TextEditingController();

  // IIUM Gombak Campus Approximate Center
  final LatLng _center = const LatLng(3.2515, 101.7340);
  final LatLng _mockUserLocation = const LatLng(3.2500, 101.7360); // Mahallah Ali

  void _onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPlaces = _allPlaces;
      } else {
        _filteredPlaces = _allPlaces.where((place) {
          final lowerQuery = query.toLowerCase();
          return place.name.toLowerCase().contains(lowerQuery) ||
                 place.description.toLowerCase().contains(lowerQuery) ||
                 place.category.toLowerCase().contains(lowerQuery);
        }).toList();
      }
    });
  }

  late final VoidCallback _appStateListener;

  @override
  void initState() {
    super.initState();
    _fetchPlaces();
    
    // Get actual user location
    Future.delayed(const Duration(milliseconds: 500), () {
      appState.getUserRealLocation();
    });

    _appStateListener = () {
      if (appState.currentTabIndex == 1) { // If Map Tab is active
        if (appState.selectedMapPlace != null) {
          _mapController.move(LatLng(appState.selectedMapPlace!.lat, appState.selectedMapPlace!.lng), 17.0);
        } else if (appState.selectedMapLecturer != null) {
          _mapController.move(LatLng(appState.selectedMapLecturer!.lat, appState.selectedMapLecturer!.lng), 17.0);
        }
      }
      // Rebuild on state change
      if (mounted) setState(() {});
    };
    appState.addListener(_appStateListener);
  }

  @override
  void dispose() {
    appState.removeListener(_appStateListener);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPlaces() async {
    try {
      final places = await FirestoreService().getPlaces();
      if (mounted) {
        setState(() {
          _allPlaces = places;
          _filteredPlaces = places;
          _isLoadingPlaces = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPlaces = false;
        });
      }
      debugPrint("Error fetching places: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Campus Map'),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search places...',
                    hintStyle: TextStyle(color: AppTheme.textLight),
                    prefixIcon: Icon(LucideIcons.search, size: 20, color: AppTheme.textLight),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  style: const TextStyle(color: AppTheme.textDark, fontSize: 14),
                  onChanged: _onSearch,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 15.0,
              maxZoom: 18.0,
              minZoom: 13.0,
              onTap: (tapPosition, point) {
                appState.clearSelection();
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.iiumfirststeps',
              ),
              if (appState.userLocation != null && (appState.selectedMapLecturer != null || appState.selectedMapPlace != null))
                PolylineLayer(
                  polylines: <Polyline<Object>>[
                    Polyline(
                      points: appState.routePoints.isNotEmpty 
                          ? appState.routePoints 
                          : [
                              appState.userLocation!,
                              if (appState.selectedMapLecturer != null)
                                LatLng(appState.selectedMapLecturer!.lat, appState.selectedMapLecturer!.lng)
                              else
                                LatLng(appState.selectedMapPlace!.lat, appState.selectedMapPlace!.lng),
                            ],
                      strokeWidth: appState.routePoints.isNotEmpty ? 5.0 : 4.0,
                      color: Colors.blueAccent.withValues(alpha: 0.7),
                      pattern: appState.routePoints.isNotEmpty ? const StrokePattern.solid() : const StrokePattern.dotted(),
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  if (_isLoadingPlaces)
                    Marker(
                      point: _center,
                      width: 40.0,
                      height: 40.0,
                      child: const CircularProgressIndicator(),
                    ),
                  ..._filteredPlaces.map((place) {
                    return Marker(
                      point: LatLng(place.lat, place.lng),
                      width: 40.0,
                      height: 40.0,
                      child: GestureDetector(
                        onTap: () {
                          appState.selectPlaceOnMap(place);
                        },
                        child: Icon(
                          LucideIcons.mapPin,
                          color: (appState.selectedMapPlace?.id == place.id) ? Colors.red : AppTheme.primaryGreen,
                          size: (appState.selectedMapPlace?.id == place.id) ? 48 : 40,
                        ),
                      ),
                    );
                  }),
                  if (appState.userLocation != null)
                    Marker(
                      point: appState.userLocation!,
                      width: 40.0,
                      height: 40.0,
                      child: const Icon(LucideIcons.navigation, color: Colors.blue, size: 40),
                    ),
                  if (appState.selectedMapLecturer != null)
                    Marker(
                      point: LatLng(appState.selectedMapLecturer!.lat, appState.selectedMapLecturer!.lng),
                      width: 50.0,
                      height: 50.0,
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.primaryGreen, width: 2),
                            image: DecorationImage(
                              image: appState.selectedMapLecturer!.imageUrl.startsWith('http')
                                  ? NetworkImage(appState.selectedMapLecturer!.imageUrl)
                                  : AssetImage(appState.selectedMapLecturer!.imageUrl) as ImageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Selected place card overlay
          if (appState.selectedMapPlace != null)
            _buildPlaceCard(context, appState.selectedMapPlace!),
            
          // Selected lecturer card overlay
          if (appState.selectedMapLecturer != null)
            _buildLecturerCard(context, appState.selectedMapLecturer!),

          // Floating action buttons for location and routing
          Positioned(
            top: 20,
            right: 20,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'btnLocation',
                  mini: true,
                  backgroundColor: AppTheme.white,
                  child: appState.isLocationLoading 
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(LucideIcons.locate, color: AppTheme.primaryGreen),
                  onPressed: () {
                    appState.getUserRealLocation();
                    if (appState.userLocation != null) {
                      _mapController.move(appState.userLocation!, 17.0);
                    }
                  },
                ),
                if (appState.routePoints.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  FloatingActionButton(
                    heroTag: 'btnClearRoute',
                    mini: true,
                    backgroundColor: Colors.redAccent,
                    child: const Icon(LucideIcons.x, color: AppTheme.white),
                    onPressed: () {
                      appState.clearRoute();
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceCard(BuildContext context, Place place) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      place.name,
                      style: Theme.of(context).textTheme.titleLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x),
                    onPressed: () => appState.clearSelection(),
                  )
                ],
              ),
              const SizedBox(height: 8),
              Text(place.description, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(LucideIcons.clock, size: 16, color: AppTheme.textLight),
                  const SizedBox(width: 4),
                  Text(place.operatingHours, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
              if (place.contactInfo.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(LucideIcons.phone, size: 16, color: AppTheme.textLight),
                    const SizedBox(width: 4),
                    Text(place.contactInfo, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ],
              if (appState.routeDistance != null && appState.routeDuration != null) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.footprints, size: 16, color: Colors.blueAccent),
                        const SizedBox(width: 4),
                        Text(appState.routeDistance!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(LucideIcons.timer, size: 16, color: Colors.blueAccent),
                        const SizedBox(width: 4),
                        Text(appState.routeDuration!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (appState.userLocation == null) {
                      appState.getUserRealLocation().then((_) {
                        if (appState.userLocation != null) {
                          appState.fetchRoute(LatLng(place.lat, place.lng));
                        }
                      });
                    } else {
                      appState.fetchRoute(LatLng(place.lat, place.lng));
                    }
                  },
                  icon: appState.isRouting 
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: AppTheme.white, strokeWidth: 2)) 
                      : const Icon(LucideIcons.navigation),
                  label: Text(appState.isRouting ? 'Calculating...' : 'Start Navigation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: AppTheme.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLecturerCard(BuildContext context, Lecturer lecturer) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: lecturer.imageUrl.startsWith('http')
                            ? NetworkImage(lecturer.imageUrl)
                            : AssetImage(lecturer.imageUrl) as ImageProvider,
                        radius: 24,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lecturer.name,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
                          ),
                          Text(
                            lecturer.department,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.primaryGreen),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x),
                    onPressed: () => appState.clearSelection(),
                  )
                ],
              ),
              const Divider(height: 24),
              _buildInfoRow(context, LucideIcons.mapPin, lecturer.office),
              const SizedBox(height: 8),
              if (lecturer.telephone != null)
                _buildInfoRow(context, LucideIcons.phone, lecturer.telephone!),
              const SizedBox(height: 8),
              _buildInfoRow(context, LucideIcons.book, 'Subjects: ${lecturer.subjects.join(", ")}'),
              if (appState.routeDistance != null && appState.routeDuration != null) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.footprints, size: 16, color: Colors.blueAccent),
                        const SizedBox(width: 4),
                        Text(appState.routeDistance!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(LucideIcons.timer, size: 16, color: Colors.blueAccent),
                        const SizedBox(width: 4),
                        Text(appState.routeDuration!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (appState.userLocation == null) {
                      appState.getUserRealLocation().then((_) {
                        if (appState.userLocation != null) {
                          appState.fetchRoute(LatLng(lecturer.lat, lecturer.lng));
                        }
                      });
                    } else {
                      appState.fetchRoute(LatLng(lecturer.lat, lecturer.lng));
                    }
                  },
                  icon: appState.isRouting 
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: AppTheme.white, strokeWidth: 2)) 
                      : const Icon(LucideIcons.navigation),
                  label: Text(appState.isRouting ? 'Calculating...' : 'Start Navigation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: AppTheme.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textLight),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}
