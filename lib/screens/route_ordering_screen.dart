// // import 'package:flutter/material.dart';
// // import 'package:firebase_core/firebase_core.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:google_maps_flutter/google_maps_flutter.dart';
// // import 'package:geolocator/geolocator.dart';

// // class RouteOrderingModule extends StatefulWidget {
// //   @override
// //   _RouteOrderingModuleState createState() => _RouteOrderingModuleState();
// // }

// // class _RouteOrderingModuleState extends State<RouteOrderingModule> {
// //   // Map controllers and variables
// //   GoogleMapController? _mapController;
// //   Position? _currentLocation;
// //   LatLng? _selectedDestination;
// //     LatLng? _initialLocation;

  
// //   // Firebase and Restaurant variables
// //   List<RestaurantMarker> _restaurantMarkers = [];
// //   List<Restaurant> _nearbyRestaurants = [];

// //   @override
// //   void initState() {
// //     super.initState();
// //     _initializeLocation();
// //     _fetchRestaurantAdmins();
// //   }
// // Future<void> _initializeLocation() async {
// //   try {
// //     LocationPermission permission = await Geolocator.requestPermission();
// //     if (permission == LocationPermission.denied) {
// //       throw Exception("Location permission denied.");
// //     }

// //     Position position = await Geolocator.getCurrentPosition(
// //       desiredAccuracy: LocationAccuracy.high,
// //     );

// //     setState(() {
// //       _initialLocation = LatLng(position.latitude, position.longitude);
// //     });
// //   } catch (e) {
// //     print("Error initializing location: $e");
// //     setState(() {
// //       _initialLocation = LatLng(33.6844, 73.0479); // Fallback location
// //     });
// //   }
// // }
// //   Future<void> _fetchRestaurantAdmins() async {
// //     try {
// //       QuerySnapshot snapshot = await FirebaseFirestore.instance
// //           .collection('restaurantAdmins')
// //           .get();

// //       _restaurantMarkers = snapshot.docs.map((doc) {
// //         GeoPoint location = doc['location'];
// //         return RestaurantMarker(
// //           name: doc['username'],
// //           position: LatLng(location.latitude, location.longitude),
// //           prepDelay: _calculatePrepDelay(doc['prepDelay']),
// //         );
// //       }).toList();

// //       setState(() {});
// //     } catch (e) {
// //       print('Error fetching restaurant admins: $e');
// //     }
// //   }

// //   double _calculatePrepDelay(dynamic prepDelayData) {
// //     if (prepDelayData is String) {
// //       if (prepDelayData.contains('-')) {
// //         List<String> parts = prepDelayData.split('-');
// //         return (double.parse(parts[0]) + double.parse(parts[1])) / 2;
// //       }
// //       return double.parse(prepDelayData);
// //     }
// //     return 30; // Default fallback
// //   }

// //   void _calculateRoute() {
// //     if (_currentLocation != null && _selectedDestination != null) {
// //       // Implement route calculation logic
// //       // Use PolylinePoints to draw route
// //       // Calculate distances to restaurants
// //       _findNearbyRestaurants();
// //     }
// //   }

// // void _findNearbyRestaurants() {
// //   if (_currentLocation == null || _selectedDestination == null) {
// //     return;
// //   }

// //   // Calculate the main route distance
// //   double totalRouteDistance = Geolocator.distanceBetween(
// //     _currentLocation!.latitude,
// //     _currentLocation!.longitude,
// //     _selectedDestination!.latitude,
// //     _selectedDestination!.longitude
// //   ) / 1000; // Convert to kilometers

// //   // Estimated travel time (assuming average speed of 30 km/h)
// //   double estimatedTravelTime = (totalRouteDistance / 30) * 60; // in minutes

// //   // Temporary list to store filtered restaurants
// //   List<Restaurant> filteredRestaurants = [];

// //   for (var marker in _restaurantMarkers) {
// //     // Calculate distance from current location to restaurant
// //     double restaurantDistance = Geolocator.distanceBetween(
// //       _currentLocation!.latitude,
// //       _currentLocation!.longitude,
// //       marker.position.latitude,
// //       marker.position.longitude
// //     ) / 1000; // Convert to kilometers

// //     // Calculate distance from restaurant to destination
// //     double restaurantToDestDistance = Geolocator.distanceBetween(
// //       marker.position.latitude,
// //       marker.position.longitude,
// //       _selectedDestination!.latitude,
// //       _selectedDestination!.longitude
// //     ) / 1000; // Convert to kilometers

// //     // Estimated travel time to restaurant (assuming 30 km/h)
// //     double travelToRestaurant = (restaurantDistance / 30) * 60; // in minutes

// //     // Check if restaurant is near route
// //     bool isNearRoute = _isRestaurantNearRoute(
// //       _currentLocation!.latitude,
// //       _currentLocation!.longitude,
// //       _selectedDestination!.latitude,
// //       _selectedDestination!.longitude,
// //       marker.position.latitude,
// //       marker.position.longitude
// //     );

// //     // Check if restaurant can be reached within prep time
// //     bool canReachInPrepTime = 
// //       travelToRestaurant <= marker.prepDelay && 
// //       (travelToRestaurant + marker.prepDelay) <= estimatedTravelTime;

// //     // If restaurant meets criteria, add to filtered list
// //     if (isNearRoute && canReachInPrepTime) {
// //       filteredRestaurants.add(Restaurant(
// //         name: marker.name,
// //         prepDelay: marker.prepDelay,
// //         distance: restaurantDistance, // Add distance to restaurant class
// //         isNearRoute: isNearRoute,
// //         canReachInPrepTime: canReachInPrepTime
// //       ));
// //     }
// //   }

// //   // Sort restaurants by distance
// //   filteredRestaurants.sort((a, b) => a.distance.compareTo(b.distance));

// //   // Update nearby restaurants
// //   _nearbyRestaurants = filteredRestaurants;

// //   setState(() {});
// // }

// // // Helper method to check if a restaurant is near the route   
// // bool _isRestaurantNearRoute(
// //   double startLat, 
// //   double startLng, 
// //   double destLat, 
// //   double destLng, 
// //   double restaurantLat, 
// //   double restaurantLng
// // ) {
// //   // Use a simplified proximity check
// //   // Calculate the distance of the restaurant from the route line
// //   double routeDistance = Geolocator.distanceBetween(
// //     startLat, startLng, destLat, destLng
// //   );

// //   double distanceToRoute = _calculatePointToLineDistance(
// //     startLat, startLng, 
// //     destLat, destLng, 
// //     restaurantLat, restaurantLng
// //   );

// //   // Consider restaurant near route if within 2 kilometers
// //   return distanceToRoute <= 2000; // 2 kilometers
// // }

// // // Calculate distance from a point to a line
// // double _calculatePointToLineDistance(
// //   double startLat, 
// //   double startLng, 
// //   double endLat, 
// //   double endLng, 
// //   double pointLat, 
// //   double pointLng
// // ) {
// //   // Haversine formula to calculate point-to-line distance
// //   double A = pointLat - startLat;
// //   double B = pointLng - startLng;
// //   double C = endLat - startLat;
// //   double D = endLng - startLng;

// //   double dot = A * C + B * D;
// //   double lenSq = C * C + D * D;
// //   double param = -1;
  
// //   if (lenSq != 0) {
// //     param = dot / lenSq;
// //   }

// //   double xx, yy;

// //   if (param < 0) {
// //     xx = startLat;
// //     yy = startLng;
// //   } else if (param > 1) {
// //     xx = endLat;
// //     yy = endLng;
// //   } else {
// //     xx = startLat + param * C;
// //     yy = startLng + param * D;
// //   }

// //   return Geolocator.distanceBetween(pointLat, pointLng, xx, yy);
// // }

// // // New class to hold route-specific restaurant information


// //   // @override
// //   // Widget build(BuildContext context) {
// //   //   return Scaffold(
// //   //     appBar: AppBar(title: Text('Route Ordering')),
// //   //     body: Column(
// //   //       children: [
// //   //         // Google Map
// //   //         Expanded(
// //   //           flex: 2,
// //   //           child: GoogleMap(
// //   //             initialCameraPosition: CameraPosition(
// //   //               target: _currentLocation != null 
// //   //                 ? LatLng(_currentLocation!.latitude, _currentLocation!.longitude)
// //   //                 : LatLng(0, 0),
// //   //               zoom: 14,
// //   //             ),
// //   //             markers: _restaurantMarkers.map((marker) => 
// //   //               Marker(
// //   //                 markerId: MarkerId(marker.name),
// //   //                 position: marker.position,
// //   //                 icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
// //   //                 infoWindow: InfoWindow(title: marker.name),
// //   //               )
// //   //             ).toSet(),
// //   //             onMapCreated: (controller) {
// //   //               _mapController = controller;
// //   //             },
// //   //             onTap: (LatLng position) {
// //   //               setState(() {
// //   //                 _selectedDestination = position;
// //   //                 _calculateRoute();
// //   //               });
// //   //             },
// //   //           ),
// //   //         ),
// //   //         // Restaurant List
// //   //         Expanded(
// //   //           flex: 1,
// //   //           child: ListView.builder(
// //   //             itemCount: _nearbyRestaurants.length,
// //   //             itemBuilder: (context, index) {
// //   //               final restaurant = _nearbyRestaurants[index];
// //   //               return ListTile(
// //   //                 title: Text(restaurant.name),
// //   //                 subtitle: Text('Prep Time: ${restaurant.prepDelay} mins'),
// //   //                 onTap: () {
// //   //                   _showRestaurantMenu(restaurant);
// //   //                 },
// //   //               );
// //   //             },
// //   //           ),
// //   //         ),
// //   //       ],
// //   //     ),
// //   //   );
// //   // }

// // @override
// // Widget build(BuildContext context) {
// //   return Scaffold(
// //     appBar: AppBar(title: Text('Route Ordering')),
// //     body: _initialLocation == null
// //         ? Center(child: CircularProgressIndicator())
// //         : Column(
// //             children: [
// //               Expanded(
// //                 flex: 2,
// //                 child: GoogleMap(
// //                   initialCameraPosition: CameraPosition(
// //                     target: _initialLocation!,
// //                     zoom: 14,
// //                   ),
// //                   markers: _restaurantMarkers.map((marker) {
// //                     return Marker(
// //                       markerId: MarkerId(marker.name),
// //                       position: marker.position,
// //                       icon: BitmapDescriptor.defaultMarkerWithHue(
// //                         BitmapDescriptor.hueRed,
// //                       ),
// //                       infoWindow: InfoWindow(title: marker.name),
// //                     );
// //                   }).toSet(),
// //                   onMapCreated: (controller) {
// //                     _mapController = controller;
// //                   },
// //                   onTap: (LatLng position) {
// //                     setState(() {
// //                       _selectedDestination = position;
// //                       _calculateRoute();
// //                     });
// //                   },
// //                 ),
// //               ),
// //               Expanded(
// //                 flex: 1,
// //                 child: ListView.builder(
// //                   itemCount: _nearbyRestaurants.length,
// //                   itemBuilder: (context, index) {
// //                     final restaurant = _nearbyRestaurants[index];
// //                     return ListTile(
// //                       title: Text(restaurant.name),
// //                       subtitle: Text('Prep Time: ${restaurant.prepDelay} mins'),
// //                       onTap: () {
// //                         _showRestaurantMenu(restaurant);
// //                       },
// //                     );
// //                   },
// //                 ),
// //               ),
// //             ],
// //           ),
// //   );
// // }
// //   void _showRestaurantMenu(Restaurant restaurant) {
// //     showModalBottomSheet(
// //       context: context,
// //       builder: (context) {
// //         return FutureBuilder(
// //           future: _fetchRestaurantMenu(restaurant.name),
// //           builder: (context, snapshot) {
// //             if (snapshot.connectionState == ConnectionState.waiting) {
// //               return Center(child: CircularProgressIndicator());
// //             }
// //             if (snapshot.hasError) {
// //               return Center(child: Text('Error loading menu'));
// //             }
            
// //             // Implement menu display logic
// //             return ListView(); // Placeholder
// //           },
// //         );
// //       },
// //     );
// //   }

// //   Future<List<MenuItem>> _fetchRestaurantMenu(String restaurantName) async {
// //     // Fetch menu items for specific restaurant
// //     return []; // Placeholder
// //   }
// // }

// // class RestaurantRouteInfo {
// //   final RestaurantMarker restaurant;
// //   final double distanceFromStart;
// //   final double distanceToDestination;
// //   final double travelTime;
// //   final bool isNearRoute;
// //   final bool canReachInPrepTime;

// //   RestaurantRouteInfo({
// //     required this.restaurant,
// //     required this.distanceFromStart,
// //     required this.distanceToDestination,
// //     required this.travelTime,
// //     required this.isNearRoute,
// //     required this.canReachInPrepTime,
// //   });
// // }



// // // Supporting Classes
// // class RestaurantMarker {
// //   final String name;
// //   final LatLng position;
// //   final double prepDelay;

// //   RestaurantMarker({
// //     required this.name, 
// //     required this.position, 
// //     required this.prepDelay,
// //   });
// // }

// // class Restaurant {
// //   final String name;
// //   final double prepDelay;
// //   final double distance;
// //   final bool isNearRoute;
// //   final bool canReachInPrepTime;
// //   final List<MenuItem>? menu;

// //   Restaurant({
// //     required this.name, 
// //     required this.prepDelay,
// //     this.distance = 0,
// //     this.isNearRoute = false,
// //     this.canReachInPrepTime = false,
// //     this.menu,
// //   });
// // }

// // class MenuItem {
// //   final String name;
// //   final double price;

// //   MenuItem({required this.name, required this.price});
// // }

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class RestaurantScanScreen extends StatefulWidget {
//   const RestaurantScanScreen({Key? key}) : super(key: key);

//   @override
//   _RestaurantScanScreenState createState() => _RestaurantScanScreenState();
// }

// class _RestaurantScanScreenState extends State<RestaurantScanScreen> {
//   String? selectedRestaurant;
//   String? selectedDish;
//   List<String> restaurants = [];
//   List<String> dishes = [];
//   bool isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _fetchRestaurants();
//   }

//   Future<void> _fetchRestaurants() async {
//     setState(() => isLoading = true);
//     try {
//       final restaurantsCollection = FirebaseFirestore.instance.collection('restaurantAdmins');
//       final snapshot = await restaurantsCollection.get();
//       setState(() {
//         restaurants = snapshot.docs.map((doc) => doc['username'] as String).toList();
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching restaurants: $e'))
//       );
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   Future<void> _fetchDishes(String restaurantName) async {
//     setState(() => isLoading = true);
//     try {
//       final restaurantDoc = await FirebaseFirestore.instance
//           .collection('restaurantAdmins')
//           .where('username', isEqualTo: restaurantName)
//           .get();

//       if (restaurantDoc.docs.isNotEmpty) {
//         final itemsCollection = restaurantDoc.docs.first.reference.collection('items');
//         final snapshot = await itemsCollection.get();
//         setState(() {
//           dishes = snapshot.docs.map((doc) => doc['name'] as String).toList();
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching dishes: $e'))
//       );
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Restaurant Scan'),
//         centerTitle: true,
//       ),
//       body: Stack(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 // Static Google Maps View
//                 Container(
//                   height: 200,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(15),
//                     border: Border.all(color: Colors.deepPurple, width: 2),
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(15),
//                     child: GoogleMap(
//                       initialCameraPosition: CameraPosition(
//                         target: LatLng(37.7749, -122.4194), // San Francisco coordinates
//                         zoom: 12,
//                       ),
//                       mapType: MapType.normal,
//                       zoomControlsEnabled: false,
//                     ),
//                   ),
//                 ),

//                 SizedBox(height: 20),

//                 // Restaurant Dropdown
//                 DropdownButtonFormField<String>(
//                   decoration: InputDecoration(
//                     hintText: 'Select Restaurant',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   value: selectedRestaurant,
//                   items: restaurants.map((restaurant) {
//                     return DropdownMenuItem(
//                       value: restaurant,
//                       child: Text(restaurant),
//                     );
//                   }).toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       selectedRestaurant = value;
//                       selectedDish = null;
//                       dishes = [];
//                     });
//                     if (value != null) {
//                       _fetchDishes(value);
//                     }
//                   },
//                 ),

//                 SizedBox(height: 20),

//                 // Dish Dropdown
//                 if (selectedRestaurant != null)
//                   DropdownButtonFormField<String>(
//                     decoration: InputDecoration(
//                       hintText: 'Select Dish',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     value: selectedDish,
//                     items: dishes.map((dish) {
//                       return DropdownMenuItem(
//                         value: dish,
//                         child: Text(dish),
//                       );
//                     }).toList(),
//                     onChanged: (value) {
//                       if (value != null) {
//                         Navigator.push(
//                           context, 
//                           MaterialPageRoute(
//                             builder: (context) => DishDetailScreen(
//                               restaurantName: selectedRestaurant!, 
//                               dishName: value
//                             )
//                           )
//                         );
//                       }
//                     },
//                   ),
//               ],
//             ),
//           ),

//           // Loading Indicator
//           if (isLoading)
//             Positioned.fill(
//               child: Container(
//                 color: Colors.black54,
//                 child: Center(
//                   child: CircularProgressIndicator(
//                     valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// class DishDetailScreen extends StatefulWidget {
//   final String restaurantName;
//   final String dishName;

//   const DishDetailScreen({
//     Key? key, 
//     required this.restaurantName, 
//     required this.dishName
//   }) : super(key: key);

//   @override
//   _DishDetailScreenState createState() => _DishDetailScreenState();
// }

// class _DishDetailScreenState extends State<DishDetailScreen> {
//   Future<DocumentSnapshot?> _fetchDishDetails() async {
//     try {
//       final restaurantDoc = await FirebaseFirestore.instance
//           .collection('restaurantAdmins')
//           .where('username', isEqualTo: widget.restaurantName)
//           .get();

//       if (restaurantDoc.docs.isNotEmpty) {
//         final itemsCollection = restaurantDoc.docs.first.reference.collection('items');
//         final dishSnapshot = await itemsCollection
//           .where('name', isEqualTo: widget.dishName)
//           .get();

//         return dishSnapshot.docs.isNotEmpty ? dishSnapshot.docs.first : null;
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching dish details: $e'))
//       );
//     }
//     return null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.dishName),
//         centerTitle: true,
//       ),
//       body: FutureBuilder<DocumentSnapshot?>(
//         future: _fetchDishDetails(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(
//               child: CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
//               )
//             );
//           }

//           if (!snapshot.hasData) {
//             return Center(
//               child: Text(
//                 'Dish not found', 
//                 style: Theme.of(context).textTheme.titleLarge,
//               )
//             );
//           }

//           final dishData = snapshot.data!.data() as Map<String, dynamic>;

//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               // Dish Photo
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Container(
//                   height: 250,
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(15),
//                     border: Border.all(color: Colors.deepPurple, width: 2),
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(15),
//                     child: CachedNetworkImage(
//                       imageUrl: dishData['photo'],
//                       fit: BoxFit.cover,
//                       placeholder: (context, url) => Center(
//                         child: CircularProgressIndicator(
//                           valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
//                         )
//                       ),
//                       errorWidget: (context, url, error) => Icon(
//                         Icons.error, 
//                         color: Colors.red, 
//                         size: 50
//                       ),
//                     ),
//                   ),
//                 ),
//               ),

//               SizedBox(height: 20),

//               // Dish Name
//               Text(
//                 widget.dishName, 
//                 style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),

//               SizedBox(height: 20),

//               // Add to Cart Button
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 child: ElevatedButton(
//                   onPressed: () {
//                     // Implement add to cart functionality
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text('Added to cart!'),
//                         backgroundColor: Colors.deepPurple,
//                       )
//                     );
//                   },
//                   child: Text(
//                     'Add to Cart', 
//                     style: TextStyle(
//                       fontSize: 16, 
//                       fontWeight: FontWeight.bold
//                     )
//                   ),
//                   style: ElevatedButton.styleFrom(
//                     minimumSize: Size(double.infinity, 50),
//                     backgroundColor: Colors.deepPurple,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }


// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:http/http.dart' as http;
// import 'select_restaurant_screen.dart';

// class MainScreen extends StatefulWidget {
//   const MainScreen({super.key});

//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }

// class _MainScreenState extends State<MainScreen> {
//   Completer<GoogleMapController> _controller = Completer();
//   LatLng? _currentPosition;

//   final TextEditingController _destinationController = TextEditingController();

//   List<dynamic> _placePredictions = [];
//   bool _showPredictions = false;

//   // Replace with your actual API key
//   final String _apiKey = "AIzaSyBdyI-UDzUS-ekazlKktQpPDLeyVQ4jJa4";

//   LatLng? _selectedDestinationLatLng;
//   String? _selectedDestinationName;

//   @override
//   void initState() {
//     super.initState();
//     _determinePosition();
//   }

//   Future<void> _determinePosition() async {
//     Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//     setState(() {
//       _currentPosition = LatLng(position.latitude, position.longitude);
//     });
//   }

//   Future<void> _autoCompleteSearch(String input) async {
//     if (input.isEmpty) {
//       setState(() {
//         _placePredictions = [];
//         _showPredictions = false;
//       });
//       return;
//     }

//     final url = Uri.parse(
//       "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$_apiKey&location=${_currentPosition!.latitude},${_currentPosition!.longitude}&radius=50000"
//     );

//     final response = await http.get(url);
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       if (data['status'] == 'OK') {
//         setState(() {
//           _placePredictions = data['predictions'];
//           _showPredictions = _placePredictions.isNotEmpty;
//         });
//       } else {
//         setState(() {
//           _placePredictions = [];
//           _showPredictions = false;
//         });
//       }
//     } else {
//       setState(() {
//         _placePredictions = [];
//         _showPredictions = false;
//       });
//     }
//   }

//   Future<void> _selectPrediction(dynamic prediction) async {
//     final placeId = prediction['place_id'];
//     final detailsUrl = Uri.parse(
//       "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$_apiKey"
//     );

//     final response = await http.get(detailsUrl);
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       if (data['status'] == 'OK') {
//         final lat = data['result']['geometry']['location']['lat'];
//         final lng = data['result']['geometry']['location']['lng'];
//         final name = data['result']['name'];

//         setState(() {
//           _selectedDestinationLatLng = LatLng(lat, lng);
//           _selectedDestinationName = name;
//           _destinationController.text = name;
//           _showPredictions = false;
//           _placePredictions = [];
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: (_currentPosition == null) 
//         ? const Center(child: CircularProgressIndicator())
//         : Stack(
//             children: [
//               GoogleMap(
//                 myLocationEnabled: true,
//                 myLocationButtonEnabled: false,
//                 initialCameraPosition: CameraPosition(
//                   target: _currentPosition!,
//                   zoom: 14,
//                 ),
//                 markers: {
//                   Marker(
//                     markerId: const MarkerId('currentLocation'),
//                     position: _currentPosition!,
//                     icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
//                   ),
//                 },
//                 onMapCreated: (controller) {
//                   _controller.complete(controller);
//                 },
//               ),
//               Positioned(
//                 top: 50,
//                 left: 20,
//                 right: 20,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   decoration: BoxDecoration(
//                     color: Colors.black.withOpacity(0.8),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Column(
//                     children: [
//                       TextField(
//                         controller: _destinationController,
//                         style: const TextStyle(color: Colors.white),
//                         decoration: InputDecoration(
//                           hintText: 'Where to?',
//                           hintStyle: const TextStyle(color: Colors.grey),
//                           prefixIcon: const Icon(Icons.search, color: Colors.white),
//                           filled: true,
//                           fillColor: Colors.white12,
//                           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide.none,
//                           ),
//                         ),
//                         onChanged: (value) {
//                           _autoCompleteSearch(value);
//                         },
//                       ),
//                       if (_showPredictions)
//                         Container(
//                           margin: const EdgeInsets.only(top: 8),
//                           decoration: BoxDecoration(
//                             color: Colors.black87,
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: ListView.builder(
//                             shrinkWrap: true,
//                             itemCount: _placePredictions.length,
//                             itemBuilder: (context, index) {
//                               final p = _placePredictions[index];
//                               return ListTile(
//                                 leading: const Icon(Icons.location_on, color: Colors.deepOrange),
//                                 title: Text(
//                                   p['description'],
//                                   style: const TextStyle(color: Colors.white),
//                                 ),
//                                 onTap: () => _selectPrediction(p),
//                               );
//                             },
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//               if (_selectedDestinationLatLng != null)
//                 Positioned(
//                   bottom: 100,
//                   left: 20,
//                   right: 20,
//                   child: Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.black54,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: ElevatedButton(
//                       onPressed: () {
//                         if (_selectedDestinationLatLng != null && _selectedDestinationName != null) {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => SelectRestaurantScreen(
//                                 currentLocation: _currentPosition!,
//                                 destinationLatLng: _selectedDestinationLatLng!,
//                                 destinationName: _selectedDestinationName!,
//                               ),
//                             ),
//                           );
//                         }
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.deepOrange,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12)
//                         )
//                       ),
//                       child: const Text('Scan for Restaurants'),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//     );
//   }
// }


import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'select_restaurant_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Completer<GoogleMapController> _controller = Completer();
  LatLng? _currentPosition;

  final TextEditingController _destinationController = TextEditingController();

  List<dynamic> _placePredictions = [];
  bool _showPredictions = false;

  // Replace with your actual API key
  final String _apiKey = "AIzaSyBdyI-UDzUS-ekazlKktQpPDLeyVQ4jJa4";

  LatLng? _selectedDestinationLatLng;
  String? _selectedDestinationName;

  bool get _isDestinationSelected => _selectedDestinationLatLng != null && _selectedDestinationName != null;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });
  }

  Future<void> _autoCompleteSearch(String input) async {
    if (input.isEmpty || _isDestinationSelected) {
      setState(() {
        _placePredictions = [];
        _showPredictions = false;
      });
      return;
    }

    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$_apiKey&location=${_currentPosition!.latitude},${_currentPosition!.longitude}&radius=50000"
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        setState(() {
          _placePredictions = data['predictions'];
          _showPredictions = _placePredictions.isNotEmpty;
        });
      } else {
        setState(() {
          _placePredictions = [];
          _showPredictions = false;
        });
      }
    } else {
      setState(() {
        _placePredictions = [];
        _showPredictions = false;
      });
    }
  }

  Future<void> _selectPrediction(dynamic prediction) async {
    final placeId = prediction['place_id'];
    final detailsUrl = Uri.parse(
      "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$_apiKey"
    );

    final response = await http.get(detailsUrl);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final lat = data['result']['geometry']['location']['lat'];
        final lng = data['result']['geometry']['location']['lng'];
        final name = data['result']['name'];

        setState(() {
          _selectedDestinationLatLng = LatLng(lat, lng);
          _selectedDestinationName = name;
          _destinationController.text = name;
          // Clear predictions after selection
          _showPredictions = false;
          _placePredictions = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (_currentPosition == null) 
        ? const Center(child: CircularProgressIndicator())
        : Stack(
            children: [
              GoogleMap(
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                initialCameraPosition: CameraPosition(
                  target: _currentPosition!,
                  zoom: 14,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('currentLocation'),
                    position: _currentPosition!,
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                  ),
                },
                onMapCreated: (controller) {
                  _controller.complete(controller);
                },
              ),
              Positioned(
                top: 50,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _destinationController,
                        style: const TextStyle(color: Colors.white),
                        enabled: !_isDestinationSelected, // disable typing after a place is selected
                        decoration: InputDecoration(
                          hintText: 'Where to?',
                          hintStyle: const TextStyle(color: Colors.grey),
                          prefixIcon: const Icon(Icons.search, color: Colors.white),
                          filled: true,
                          fillColor: Colors.white12,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) {
                          _autoCompleteSearch(value);
                        },
                      ),
                      if (_showPredictions)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _placePredictions.length,
                            itemBuilder: (context, index) {
                              final p = _placePredictions[index];
                              return ListTile(
                                leading: const Icon(Icons.location_on, color: Colors.deepOrange),
                                title: Text(
                                  p['description'],
                                  style: const TextStyle(color: Colors.white),
                                ),
                                onTap: () => _selectPrediction(p),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (_isDestinationSelected)
                Positioned(
                  bottom: 100,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_selectedDestinationLatLng != null && _selectedDestinationName != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SelectRestaurantScreen(
                                currentLocation: _currentPosition!,
                                destinationLatLng: _selectedDestinationLatLng!,
                                destinationName: _selectedDestinationName!,
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)
                        )
                      ),
                      child: const Text('Scan for Restaurants', style: TextStyle(color: Colors.white),),
                    ),
                  ),
                ),
            ],
          ),
    );
  }
}
