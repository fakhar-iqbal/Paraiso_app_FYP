import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class RouteOrderingModule extends StatefulWidget {
  @override
  _RouteOrderingModuleState createState() => _RouteOrderingModuleState();
}

class _RouteOrderingModuleState extends State<RouteOrderingModule> {
  // Map controllers and variables
  GoogleMapController? _mapController;
  Position? _currentLocation;
  LatLng? _selectedDestination;
    LatLng? _initialLocation;

  
  // Firebase and Restaurant variables
  List<RestaurantMarker> _restaurantMarkers = [];
  List<Restaurant> _nearbyRestaurants = [];

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _fetchRestaurantAdmins();
  }
Future<void> _initializeLocation() async {
  try {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception("Location permission denied.");
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _initialLocation = LatLng(position.latitude, position.longitude);
    });
  } catch (e) {
    print("Error initializing location: $e");
    setState(() {
      _initialLocation = LatLng(33.6844, 73.0479); // Fallback location
    });
  }
}
  Future<void> _fetchRestaurantAdmins() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('restaurantAdmins')
          .get();

      _restaurantMarkers = snapshot.docs.map((doc) {
        GeoPoint location = doc['location'];
        return RestaurantMarker(
          name: doc['username'],
          position: LatLng(location.latitude, location.longitude),
          prepDelay: _calculatePrepDelay(doc['prepDelay']),
        );
      }).toList();

      setState(() {});
    } catch (e) {
      print('Error fetching restaurant admins: $e');
    }
  }

  double _calculatePrepDelay(dynamic prepDelayData) {
    if (prepDelayData is String) {
      if (prepDelayData.contains('-')) {
        List<String> parts = prepDelayData.split('-');
        return (double.parse(parts[0]) + double.parse(parts[1])) / 2;
      }
      return double.parse(prepDelayData);
    }
    return 30; // Default fallback
  }

  void _calculateRoute() {
    if (_currentLocation != null && _selectedDestination != null) {
      // Implement route calculation logic
      // Use PolylinePoints to draw route
      // Calculate distances to restaurants
      _findNearbyRestaurants();
    }
  }

void _findNearbyRestaurants() {
  if (_currentLocation == null || _selectedDestination == null) {
    return;
  }

  // Calculate the main route distance
  double totalRouteDistance = Geolocator.distanceBetween(
    _currentLocation!.latitude,
    _currentLocation!.longitude,
    _selectedDestination!.latitude,
    _selectedDestination!.longitude
  ) / 1000; // Convert to kilometers

  // Estimated travel time (assuming average speed of 30 km/h)
  double estimatedTravelTime = (totalRouteDistance / 30) * 60; // in minutes

  // Temporary list to store filtered restaurants
  List<Restaurant> filteredRestaurants = [];

  for (var marker in _restaurantMarkers) {
    // Calculate distance from current location to restaurant
    double restaurantDistance = Geolocator.distanceBetween(
      _currentLocation!.latitude,
      _currentLocation!.longitude,
      marker.position.latitude,
      marker.position.longitude
    ) / 1000; // Convert to kilometers

    // Calculate distance from restaurant to destination
    double restaurantToDestDistance = Geolocator.distanceBetween(
      marker.position.latitude,
      marker.position.longitude,
      _selectedDestination!.latitude,
      _selectedDestination!.longitude
    ) / 1000; // Convert to kilometers

    // Estimated travel time to restaurant (assuming 30 km/h)
    double travelToRestaurant = (restaurantDistance / 30) * 60; // in minutes

    // Check if restaurant is near route
    bool isNearRoute = _isRestaurantNearRoute(
      _currentLocation!.latitude,
      _currentLocation!.longitude,
      _selectedDestination!.latitude,
      _selectedDestination!.longitude,
      marker.position.latitude,
      marker.position.longitude
    );

    // Check if restaurant can be reached within prep time
    bool canReachInPrepTime = 
      travelToRestaurant <= marker.prepDelay && 
      (travelToRestaurant + marker.prepDelay) <= estimatedTravelTime;

    // If restaurant meets criteria, add to filtered list
    if (isNearRoute && canReachInPrepTime) {
      filteredRestaurants.add(Restaurant(
        name: marker.name,
        prepDelay: marker.prepDelay,
        distance: restaurantDistance, // Add distance to restaurant class
        isNearRoute: isNearRoute,
        canReachInPrepTime: canReachInPrepTime
      ));
    }
  }

  // Sort restaurants by distance
  filteredRestaurants.sort((a, b) => a.distance.compareTo(b.distance));

  // Update nearby restaurants
  _nearbyRestaurants = filteredRestaurants;

  setState(() {});
}

// Helper method to check if a restaurant is near the route   
bool _isRestaurantNearRoute(
  double startLat, 
  double startLng, 
  double destLat, 
  double destLng, 
  double restaurantLat, 
  double restaurantLng
) {
  // Use a simplified proximity check
  // Calculate the distance of the restaurant from the route line
  double routeDistance = Geolocator.distanceBetween(
    startLat, startLng, destLat, destLng
  );

  double distanceToRoute = _calculatePointToLineDistance(
    startLat, startLng, 
    destLat, destLng, 
    restaurantLat, restaurantLng
  );

  // Consider restaurant near route if within 2 kilometers
  return distanceToRoute <= 2000; // 2 kilometers
}

// Calculate distance from a point to a line
double _calculatePointToLineDistance(
  double startLat, 
  double startLng, 
  double endLat, 
  double endLng, 
  double pointLat, 
  double pointLng
) {
  // Haversine formula to calculate point-to-line distance
  double A = pointLat - startLat;
  double B = pointLng - startLng;
  double C = endLat - startLat;
  double D = endLng - startLng;

  double dot = A * C + B * D;
  double lenSq = C * C + D * D;
  double param = -1;
  
  if (lenSq != 0) {
    param = dot / lenSq;
  }

  double xx, yy;

  if (param < 0) {
    xx = startLat;
    yy = startLng;
  } else if (param > 1) {
    xx = endLat;
    yy = endLng;
  } else {
    xx = startLat + param * C;
    yy = startLng + param * D;
  }

  return Geolocator.distanceBetween(pointLat, pointLng, xx, yy);
}

// New class to hold route-specific restaurant information


  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(title: Text('Route Ordering')),
  //     body: Column(
  //       children: [
  //         // Google Map
  //         Expanded(
  //           flex: 2,
  //           child: GoogleMap(
  //             initialCameraPosition: CameraPosition(
  //               target: _currentLocation != null 
  //                 ? LatLng(_currentLocation!.latitude, _currentLocation!.longitude)
  //                 : LatLng(0, 0),
  //               zoom: 14,
  //             ),
  //             markers: _restaurantMarkers.map((marker) => 
  //               Marker(
  //                 markerId: MarkerId(marker.name),
  //                 position: marker.position,
  //                 icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
  //                 infoWindow: InfoWindow(title: marker.name),
  //               )
  //             ).toSet(),
  //             onMapCreated: (controller) {
  //               _mapController = controller;
  //             },
  //             onTap: (LatLng position) {
  //               setState(() {
  //                 _selectedDestination = position;
  //                 _calculateRoute();
  //               });
  //             },
  //           ),
  //         ),
  //         // Restaurant List
  //         Expanded(
  //           flex: 1,
  //           child: ListView.builder(
  //             itemCount: _nearbyRestaurants.length,
  //             itemBuilder: (context, index) {
  //               final restaurant = _nearbyRestaurants[index];
  //               return ListTile(
  //                 title: Text(restaurant.name),
  //                 subtitle: Text('Prep Time: ${restaurant.prepDelay} mins'),
  //                 onTap: () {
  //                   _showRestaurantMenu(restaurant);
  //                 },
  //               );
  //             },
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text('Route Ordering')),
    body: _initialLocation == null
        ? Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Expanded(
                flex: 2,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _initialLocation!,
                    zoom: 14,
                  ),
                  markers: _restaurantMarkers.map((marker) {
                    return Marker(
                      markerId: MarkerId(marker.name),
                      position: marker.position,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed,
                      ),
                      infoWindow: InfoWindow(title: marker.name),
                    );
                  }).toSet(),
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  onTap: (LatLng position) {
                    setState(() {
                      _selectedDestination = position;
                      _calculateRoute();
                    });
                  },
                ),
              ),
              Expanded(
                flex: 1,
                child: ListView.builder(
                  itemCount: _nearbyRestaurants.length,
                  itemBuilder: (context, index) {
                    final restaurant = _nearbyRestaurants[index];
                    return ListTile(
                      title: Text(restaurant.name),
                      subtitle: Text('Prep Time: ${restaurant.prepDelay} mins'),
                      onTap: () {
                        _showRestaurantMenu(restaurant);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
  );
}
  void _showRestaurantMenu(Restaurant restaurant) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return FutureBuilder(
          future: _fetchRestaurantMenu(restaurant.name),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error loading menu'));
            }
            
            // Implement menu display logic
            return ListView(); // Placeholder
          },
        );
      },
    );
  }

  Future<List<MenuItem>> _fetchRestaurantMenu(String restaurantName) async {
    // Fetch menu items for specific restaurant
    return []; // Placeholder
  }
}

class RestaurantRouteInfo {
  final RestaurantMarker restaurant;
  final double distanceFromStart;
  final double distanceToDestination;
  final double travelTime;
  final bool isNearRoute;
  final bool canReachInPrepTime;

  RestaurantRouteInfo({
    required this.restaurant,
    required this.distanceFromStart,
    required this.distanceToDestination,
    required this.travelTime,
    required this.isNearRoute,
    required this.canReachInPrepTime,
  });
}



// Supporting Classes
class RestaurantMarker {
  final String name;
  final LatLng position;
  final double prepDelay;

  RestaurantMarker({
    required this.name, 
    required this.position, 
    required this.prepDelay,
  });
}

class Restaurant {
  final String name;
  final double prepDelay;
  final double distance;
  final bool isNearRoute;
  final bool canReachInPrepTime;
  final List<MenuItem>? menu;

  Restaurant({
    required this.name, 
    required this.prepDelay,
    this.distance = 0,
    this.isNearRoute = false,
    this.canReachInPrepTime = false,
    this.menu,
  });
}

class MenuItem {
  final String name;
  final double price;

  MenuItem({required this.name, required this.price});
}

