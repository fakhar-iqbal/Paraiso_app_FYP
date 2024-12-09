// // // import 'dart:async';
// // // import 'dart:math';
// // // import 'package:cloud_firestore/cloud_firestore.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:google_maps_flutter/google_maps_flutter.dart';
// // // import 'package:http/http.dart' as http;
// // // import 'dish_screen.dart';

// // // class SelectRestaurantScreen extends StatefulWidget {
// // //   final LatLng currentLocation;
// // //   final String destination;
// // //   const SelectRestaurantScreen({super.key, required this.currentLocation, required this.destination});

// // //   @override
// // //   State<SelectRestaurantScreen> createState() => _SelectRestaurantScreenState();
// // // }

// // // class _SelectRestaurantScreenState extends State<SelectRestaurantScreen> {
// // //   Completer<GoogleMapController> _controller = Completer();
// // //   LatLng? destinationLatLng;
// // //   Set<Marker> _markers = {};
// // //   List<LatLng> _routePoints = [];
  
// // //   // Data from Firestore
// // //   List<Map<String, dynamic>> _restaurantsOnRoute = [];
// // //   String? _selectedRestaurant;
// // //   List<Map<String,dynamic>> _dishes = [];
// // //   String? _selectedDish;

// // //   bool _loading = true;

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _initMapStuff();
// // //   }

// // //   Future<void> _initMapStuff() async {
// // //     // Convert destination to LatLng using some geocoding service
// // //     // For demonstration, let's assume a static lat/long or a dummy geocoding step.
// // //     // In a real app, use a geocoding API or the Google Places API.
// // //     destinationLatLng = await _geocodeDestination(widget.destination);

// // //     // Get route points (mock or from a directions API)
// // //     _routePoints = await _getRoutePoints(widget.currentLocation, destinationLatLng!);

// // //     // Get restaurants from Firestore
// // //     List<Map<String,dynamic>> allRestaurants = await _fetchAllRestaurants();

// // //     // Filter restaurants that are close to the route
// // //     _restaurantsOnRoute = _filterRestaurantsOnRoute(allRestaurants, _routePoints);

// // //     // Add markers
// // //     Set<Marker> markers = {
// // //       Marker(
// // //         markerId: const MarkerId('origin'),
// // //         position: widget.currentLocation,
// // //         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
// // //       ),
// // //       Marker(
// // //         markerId: const MarkerId('destination'),
// // //         position: destinationLatLng!,
// // //         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
// // //       ),
// // //     };

// // //     // Add restaurant markers
// // //     for (var r in _restaurantsOnRoute) {
// // //       markers.add(
// // //         Marker(
// // //           markerId: MarkerId(r['id']),
// // //           position: r['latLng'],
// // //           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
// // //           infoWindow: InfoWindow(title: r['username']),
// // //         )
// // //       );
// // //     }

// // //     setState(() {
// // //       _markers = markers;
// // //       _loading = false;
// // //     });
// // //   }

// // //   Future<LatLng> _geocodeDestination(String destination) async {
// // //     // Dummy: In real scenario, call a geocoding API.
// // //     // Here we just return a static location.
// // //     return LatLng(37.7749, -122.4194); // e.g. San Francisco
// // //   }

// // //   Future<List<LatLng>> _getRoutePoints(LatLng origin, LatLng destination) async {
// // //     // In real scenario, use Directions API to get polyline points.
// // //     // For demonstration: a straight line between origin and destination.
// // //     List<LatLng> points = [origin, destination];
// // //     return points;
// // //   }

// // //   Future<List<Map<String,dynamic>>> _fetchAllRestaurants() async {
// // //     QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('restaurantAdmins').get();
// // //     return snapshot.docs.map((doc) {
// // //       GeoPoint gp = doc.get('location');
// // //       return {
// // //         'id': doc.id,
// // //         'username': doc.get('username'),
// // //         'latLng': LatLng(gp.latitude, gp.longitude)
// // //       };
// // //     }).toList();
// // //   }

// // //   List<Map<String,dynamic>> _filterRestaurantsOnRoute(List<Map<String,dynamic>> all, List<LatLng> route) {
// // //     // Simple heuristic: Check if restaurant is within some distance (e.g. 2km) of any route point.
// // //     const double radiusKm = 2.0;
// // //     return all.where((r) {
// // //       for (var p in route) {
// // //         double distance = _coordinateDistance(p.latitude, p.longitude, r['latLng'].latitude, r['latLng'].longitude);
// // //         if (distance <= radiusKm) {
// // //           return true;
// // //         }
// // //       }
// // //       return false;
// // //     }).toList();
// // //   }

// // //   double _coordinateDistance(lat1, lon1, lat2, lon2) {
// // //     // Haversine formula
// // //     var p = 0.017453292519943295;
// // //     var a = 0.5 - cos((lat2 - lat1) * p)/2 + 
// // //             cos(lat1 * p)*cos(lat2 * p)*(1 - cos((lon2 - lon1)*p))/2;
// // //     return 12742 * asin(sqrt(a));
// // //   }

// // //   Future<void> _fetchDishesForRestaurant(String restaurantId) async {
// // //     QuerySnapshot snapshot = await FirebaseFirestore.instance
// // //       .collection('restaurantAdmins')
// // //       .doc(restaurantId)
// // //       .collection('items')
// // //       .get();
// // //     setState(() {
// // //       _dishes = snapshot.docs.map((doc) {
// // //         return {
// // //           'id': doc.id,
// // //           'name': doc.get('name'),
// // //           'photo': doc.get('photo'),
// // //         };
// // //       }).toList();
// // //     });
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       body: _loading 
// // //         ? const Center(child: CircularProgressIndicator())
// // //         : SafeArea(
// // //           child: Stack(
// // //             children: [
// // //               GoogleMap(
// // //                 initialCameraPosition: CameraPosition(
// // //                   target: widget.currentLocation,
// // //                   zoom: 12,
// // //                 ),
// // //                 markers: _markers,
// // //                 polylines: {
// // //                   Polyline(
// // //                     polylineId: const PolylineId('route'),
// // //                     points: _routePoints,
// // //                     color: Colors.deepOrange,
// // //                     width: 5,
// // //                   )
// // //                 },
// // //                 onMapCreated: (controller) {
// // //                   _controller.complete(controller);
// // //                 },
// // //               ),
// // //               Positioned(
// // //                 bottom: 20,
// // //                 left: 10,
// // //                 right: 10,
// // //                 child: Container(
// // //                   padding: const EdgeInsets.all(16),
// // //                   decoration: BoxDecoration(
// // //                     color: Colors.black54,
// // //                     borderRadius: BorderRadius.circular(12),
// // //                   ),
// // //                   child: Column(
// // //                     mainAxisSize: MainAxisSize.min,
// // //                     children: [
// // //                       if (_restaurantsOnRoute.isNotEmpty)
// // //                         DropdownButtonFormField<String>(
// // //                           dropdownColor: Colors.black,
// // //                           style: const TextStyle(color: Colors.white),
// // //                           decoration: InputDecoration(
// // //                             filled: true,
// // //                             fillColor: Colors.white12,
// // //                             hintText: 'Select Restaurant',
// // //                             hintStyle: const TextStyle(color: Colors.grey),
// // //                             border: OutlineInputBorder(
// // //                               borderRadius: BorderRadius.circular(8),
// // //                               borderSide: BorderSide.none,
// // //                             )
// // //                           ),
// // //                           value: _selectedRestaurant,
// // //                           items: _restaurantsOnRoute.map((res) {
// // //                             return DropdownMenuItem<String>(
// // //                               value: res['id'],
// // //                               child: Text(res['username']),
// // //                             );
// // //                           }).toList(),
// // //                           onChanged: (val) async {
// // //                             setState(() {
// // //                               _selectedRestaurant = val;
// // //                               _selectedDish = null;
// // //                               _dishes.clear();
// // //                             });
// // //                             if (val != null) {
// // //                               await _fetchDishesForRestaurant(val);
// // //                             }
// // //                           },
// // //                         ),
// // //                       const SizedBox(height: 10),
// // //                       if (_dishes.isNotEmpty)
// // //                         DropdownButtonFormField<String>(
// // //                           dropdownColor: Colors.black,
// // //                           style: const TextStyle(color: Colors.white),
// // //                           decoration: InputDecoration(
// // //                             filled: true,
// // //                             fillColor: Colors.white12,
// // //                             hintText: 'Select Dish',
// // //                             hintStyle: const TextStyle(color: Colors.grey),
// // //                             border: OutlineInputBorder(
// // //                               borderRadius: BorderRadius.circular(8),
// // //                               borderSide: BorderSide.none,
// // //                             )
// // //                           ),
// // //                           value: _selectedDish,
// // //                           items: _dishes.map((dish) {
// // //                             return DropdownMenuItem<String>(
// // //                               value: dish['id'],
// // //                               child: Text(dish['name']),
// // //                             );
// // //                           }).toList(),
// // //                           onChanged: (val) {
// // //                             setState(() {
// // //                               _selectedDish = val;
// // //                             });
// // //                           },
// // //                         ),
// // //                       const SizedBox(height: 10),
// // //                       if (_selectedDish != null && _selectedRestaurant != null)
// // //                         ElevatedButton(
// // //                           style: ElevatedButton.styleFrom(
// // //                             backgroundColor: Colors.deepOrange,
// // //                             shape: RoundedRectangleBorder(
// // //                               borderRadius: BorderRadius.circular(8),
// // //                             )
// // //                           ),
// // //                           onPressed: () {
// // //                             final selectedDishData = _dishes.firstWhere((d) => d['id'] == _selectedDish);
// // //                             final selectedRestaurantData = _restaurantsOnRoute.firstWhere((r) => r['id'] == _selectedRestaurant);
// // //                             Navigator.push(
// // //                               context,
// // //                               MaterialPageRoute(
// // //                                 builder: (context) => DishScreen(
// // //                                   dishName: selectedDishData['name'],
// // //                                   dishPhoto: selectedDishData['photo'],
// // //                                   restaurantName: selectedRestaurantData['username'],
// // //                                 ),
// // //                               ),
// // //                             );
// // //                           },
// // //                           child: const Text('View Dish'),
// // //                         )
// // //                     ],
// // //                   ),
// // //                 ),
// // //               )
// // //             ],
// // //           ),
// // //         ),
// // //     );
// // //   }
// // // }

// // import 'dart:async';
// // import 'dart:math';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:flutter/material.dart';
// // import 'package:google_maps_flutter/google_maps_flutter.dart';
// // import 'dish_screen.dart';

// // class SelectRestaurantScreen extends StatefulWidget {
// //   final LatLng currentLocation;
// //   final LatLng destinationLatLng;
// //   final String destinationName;

// //   const SelectRestaurantScreen({
// //     super.key, 
// //     required this.currentLocation, 
// //     required this.destinationLatLng,
// //     required this.destinationName,
// //   });

// //   @override
// //   State<SelectRestaurantScreen> createState() => _SelectRestaurantScreenState();
// // }

// // class _SelectRestaurantScreenState extends State<SelectRestaurantScreen> {
// //   Completer<GoogleMapController> _controller = Completer();
// //   Set<Marker> _markers = {};
// //   List<LatLng> _routePoints = [];
  
// //   List<Map<String, dynamic>> _restaurantsOnRoute = [];
// //   String? _selectedRestaurant;
// //   List<Map<String,dynamic>> _dishes = [];
// //   String? _selectedDish;
// //   bool _loading = true;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _initMapStuff();
// //   }

// //   Future<void> _initMapStuff() async {
// //     _routePoints = await _getRoutePoints(widget.currentLocation, widget.destinationLatLng);

// //     List<Map<String,dynamic>> allRestaurants = await _fetchAllRestaurants();
// //     _restaurantsOnRoute = _filterRestaurantsOnRoute(allRestaurants, _routePoints);

// //     Set<Marker> markers = {
// //       Marker(
// //         markerId: const MarkerId('origin'),
// //         position: widget.currentLocation,
// //         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
// //       ),
// //       Marker(
// //         markerId: const MarkerId('destination'),
// //         position: widget.destinationLatLng,
// //         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
// //         infoWindow: InfoWindow(title: widget.destinationName),
// //       ),
// //     };

// //     for (var r in _restaurantsOnRoute) {
// //       markers.add(
// //         Marker(
// //           markerId: MarkerId(r['id']),
// //           position: r['latLng'],
// //           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
// //           infoWindow: InfoWindow(title: r['username']),
// //         )
// //       );
// //     }

// //     setState(() {
// //       _markers = markers;
// //       _loading = false;
// //     });
// //   }

// //   Future<List<LatLng>> _getRoutePoints(LatLng origin, LatLng destination) async {
// //     // Placeholder: a simple straight line route.
// //     return [origin, destination];
// //   }

// //   Future<List<Map<String,dynamic>>> _fetchAllRestaurants() async {
// //     QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('restaurantAdmins').get();
// //     return snapshot.docs.map((doc) {
// //       GeoPoint gp = doc.get('location');
// //       return {
// //         'id': doc.id,
// //         'username': doc.get('username'),
// //         'latLng': LatLng(gp.latitude, gp.longitude)
// //       };
// //     }).toList();
// //   }

// //   List<Map<String,dynamic>> _filterRestaurantsOnRoute(List<Map<String,dynamic>> all, List<LatLng> route) {
// //     const double radiusKm = 2.0;
// //     return all.where((r) {
// //       for (var p in route) {
// //         double distance = _coordinateDistance(p.latitude, p.longitude, r['latLng'].latitude, r['latLng'].longitude);
// //         if (distance <= radiusKm) {
// //           return true;
// //         }
// //       }
// //       return false;
// //     }).toList();
// //   }

// //   double _coordinateDistance(lat1, lon1, lat2, lon2) {
// //     var p = 0.017453292519943295;
// //     var a = 0.5 - cos((lat2 - lat1) * p)/2 + 
// //             cos(lat1 * p)*cos(lat2 * p)*(1 - cos((lon2 - lon1)*p))/2;
// //     return 12742 * asin(sqrt(a));
// //   }

// //   Future<void> _fetchDishesForRestaurant(String restaurantId) async {
// //     QuerySnapshot snapshot = await FirebaseFirestore.instance
// //       .collection('restaurantAdmins')
// //       .doc(restaurantId)
// //       .collection('items')
// //       .get();
// //     setState(() {
// //       _dishes = snapshot.docs.map((doc) {
// //         return {
// //           'id': doc.id,
// //           'name': doc.get('name'),
// //           'photo': doc.get('photo'),
// //         };
// //       }).toList();
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: _loading 
// //         ? const Center(child: CircularProgressIndicator())
// //         : SafeArea(
// //           child: Stack(
// //             children: [
// //               GoogleMap(
// //                 initialCameraPosition: CameraPosition(
// //                   target: widget.currentLocation,
// //                   zoom: 12,
// //                 ),
// //                 markers: _markers,
// //                 polylines: {
// //                   Polyline(
// //                     polylineId: const PolylineId('route'),
// //                     points: _routePoints,
// //                     color: Colors.deepOrange,
// //                     width: 5,
// //                   )
// //                 },
// //                 onMapCreated: (controller) {
// //                   _controller.complete(controller);
// //                 },
// //               ),
// //               Positioned(
// //                 bottom: 20,
// //                 left: 20,
// //                 right: 20,
// //                 child: Container(
// //                   padding: const EdgeInsets.all(16),
// //                   decoration: BoxDecoration(
// //                     color: Colors.black87,
// //                     borderRadius: BorderRadius.circular(12),
// //                   ),
// //                   child: Column(
// //                     mainAxisSize: MainAxisSize.min,
// //                     children: [
// //                       if (_restaurantsOnRoute.isNotEmpty)
// //                         DropdownButtonFormField<String>(
// //                           dropdownColor: Colors.black,
// //                           style: const TextStyle(color: Colors.white),
// //                           decoration: InputDecoration(
// //                             filled: true,
// //                             fillColor: Colors.white12,
// //                             hintText: 'Select Restaurant',
// //                             hintStyle: const TextStyle(color: Colors.grey),
// //                             border: OutlineInputBorder(
// //                               borderRadius: BorderRadius.circular(8),
// //                               borderSide: BorderSide.none,
// //                             )
// //                           ),
// //                           value: _selectedRestaurant,
// //                           items: _restaurantsOnRoute.map((res) {
// //                             return DropdownMenuItem<String>(
// //                               value: res['id'],
// //                               child: Text(res['username']),
// //                             );
// //                           }).toList(),
// //                           onChanged: (val) async {
// //                             setState(() {
// //                               _selectedRestaurant = val;
// //                               _selectedDish = null;
// //                               _dishes.clear();
// //                             });
// //                             if (val != null) {
// //                               await _fetchDishesForRestaurant(val);
// //                             }
// //                           },
// //                         ),
// //                       const SizedBox(height: 10),
// //                       if (_dishes.isNotEmpty)
// //                         DropdownButtonFormField<String>(
// //                           dropdownColor: Colors.black,
// //                           style: const TextStyle(color: Colors.white),
// //                           decoration: InputDecoration(
// //                             filled: true,
// //                             fillColor: Colors.white12,
// //                             hintText: 'Select Dish',
// //                             hintStyle: const TextStyle(color: Colors.grey),
// //                             border: OutlineInputBorder(
// //                               borderRadius: BorderRadius.circular(8),
// //                               borderSide: BorderSide.none,
// //                             )
// //                           ),
// //                           value: _selectedDish,
// //                           items: _dishes.map((dish) {
// //                             return DropdownMenuItem<String>(
// //                               value: dish['id'],
// //                               child: Text(dish['name']),
// //                             );
// //                           }).toList(),
// //                           onChanged: (val) {
// //                             setState(() {
// //                               _selectedDish = val;
// //                             });
// //                           },
// //                         ),
// //                       const SizedBox(height: 10),
// //                       if (_selectedDish != null && _selectedRestaurant != null)
// //                         ElevatedButton(
// //                           style: ElevatedButton.styleFrom(
// //                             backgroundColor: Colors.deepOrange,
// //                             shape: RoundedRectangleBorder(
// //                               borderRadius: BorderRadius.circular(8),
// //                             )
// //                           ),
// //                           onPressed: () {
// //                             final selectedDishData = _dishes.firstWhere((d) => d['id'] == _selectedDish);
// //                             final selectedRestaurantData = _restaurantsOnRoute.firstWhere((r) => r['id'] == _selectedRestaurant);
// //                             Navigator.push(
// //                               context,
// //                               MaterialPageRoute(
// //                                 builder: (context) => DishScreen(
// //                                   dishName: selectedDishData['name'],
// //                                   dishPhoto: selectedDishData['photo'],
// //                                   restaurantName: selectedRestaurantData['username'],
// //                                 ),
// //                               ),
// //                             );
// //                           },
// //                           child: const Text('View Dish'),
// //                         )
// //                     ],
// //                   ),
// //                 ),
// //               )
// //             ],
// //           ),
// //         ),
// //     );
// //   }
// // }


// import 'dart:async';
// import 'dart:convert';
// import 'dart:math';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'dish_screen.dart';

// class SelectRestaurantScreen extends StatefulWidget {
//   final LatLng currentLocation;
//   final LatLng destinationLatLng;
//   final String destinationName;

//   const SelectRestaurantScreen({
//     Key? key, 
//     required this.currentLocation, 
//     required this.destinationLatLng,
//     required this.destinationName,
//   }) : super(key: key);

//   @override
//   State<SelectRestaurantScreen> createState() => _SelectRestaurantScreenState();
// }

// class _SelectRestaurantScreenState extends State<SelectRestaurantScreen> {
//   Completer<GoogleMapController> _controller = Completer();
//   Set<Marker> _markers = {};
//   List<LatLng> _routePoints = [];
  
//   List<Map<String, dynamic>> _restaurantsOnRoute = [];
//   String? _selectedRestaurant;
//   List<Map<String,dynamic>> _dishes = [];
//   String? _selectedDish;
//   bool _loading = true;

//   // Replace with your Directions API key
//   final String _directionsApiKey = "AIzaSyBdyI-UDzUS-ekazlKktQpPDLeyVQ4jJa4";

//   @override
//   void initState() {
//     super.initState();
//     _initMapStuff();
//   }

//   Future<void> _initMapStuff() async {
//     _routePoints = await _getRoutePoints(widget.currentLocation, widget.destinationLatLng);

//     List<Map<String,dynamic>> allRestaurants = await _fetchAllRestaurants();
//     _restaurantsOnRoute = _filterRestaurantsOnRoute(allRestaurants, _routePoints);

//     Set<Marker> markers = {
//       Marker(
//         markerId: const MarkerId('origin'),
//         position: widget.currentLocation,
//         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
//       ),
//       Marker(
//         markerId: const MarkerId('destination'),
//         position: widget.destinationLatLng,
//         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
//         infoWindow: InfoWindow(title: widget.destinationName),
//       ),
//     };

//     for (var r in _restaurantsOnRoute) {
//       markers.add(
//         Marker(
//           markerId: MarkerId(r['id']),
//           position: r['latLng'],
//           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
//           infoWindow: InfoWindow(title: r['username']),
//         )
//       );
//     }

//     setState(() {
//       _markers = markers;
//       _loading = false;
//     });
//   }

//   Future<List<LatLng>> _getRoutePoints(LatLng origin, LatLng destination) async {
//     final directionUrl = Uri.parse(
//       "https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$_directionsApiKey"
//     );

//     final response = await http.get(directionUrl);
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       if (data['status'] == 'OK' && (data['routes'] as List).isNotEmpty) {
//         final route = data['routes'][0];
//         final overviewPolyline = route['overview_polyline']['points'];
//         return _decodePolyline(overviewPolyline);
//       }
//     }

//     // If for some reason the Directions API call fails, fallback to a straight line
//     return [origin, destination];
//   }

//   List<LatLng> _decodePolyline(String encoded) {
//     List<LatLng> points = [];
//     int index = 0;
//     int len = encoded.length;
//     int lat = 0;
//     int lng = 0;
    
//     while (index < len) {
//       int b, shift = 0, result = 0;
//       do {
//         b = encoded.codeUnitAt(index++) - 63;
//         result |= (b & 0x1f) << shift;
//         shift += 5;
//       } while (b >= 0x20);
      
//       int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
//       lat += dlat;
      
//       shift = 0;
//       result = 0;
//       do {
//         b = encoded.codeUnitAt(index++) - 63;
//         result |= (b & 0x1f) << shift;
//         shift += 5;
//       } while (b >= 0x20);
      
//       int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
//       lng += dlng;

//       points.add(LatLng(lat / 1E5, lng / 1E5));
//     }
//     return points;
//   }

//   Future<List<Map<String,dynamic>>> _fetchAllRestaurants() async {
//     QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('restaurantAdmins').get();
//     print(snapshot.docs.map((doc) {
//       GeoPoint gp = doc.get('location');
//       return {
//         'id': doc.id,
//         'username': doc.get('username'),
//         'latLng': LatLng(gp.latitude, gp.longitude)
//       };
//     }).toList());
//     return snapshot.docs.map((doc) {
//       GeoPoint gp = doc.get('location');
//       return {
//         'id': doc.id,
//         'username': doc.get('username'),
//         'latLng': LatLng(gp.latitude, gp.longitude)
//       };
//     }).toList();
//   }

//   List<Map<String,dynamic>> _filterRestaurantsOnRoute(List<Map<String,dynamic>> all, List<LatLng> route) {
//     const double radiusKm = 0.8;
    
//     return all.where((r) {
//       for (var p in route) {
//         double distance = _coordinateDistance(p.latitude, p.longitude, r['latLng'].latitude, r['latLng'].longitude);
//         if (distance <= radiusKm) {
//           return true;
//         }
//       }
//       return false;
//     }).toList();
//   }

//   double _coordinateDistance(lat1, lon1, lat2, lon2) {
//     // Haversine formula
//     var p = 0.017453292519943295;
//     var a = 0.5 - cos((lat2 - lat1) * p)/2 + 
//             cos(lat1 * p)*cos(lat2 * p)*(1 - cos((lon2 - lon1)*p))/2;
//     return 12742 * asin(sqrt(a));
//   }

//   Future<void> _fetchDishesForRestaurant(String restaurantId) async {
//     QuerySnapshot snapshot = await FirebaseFirestore.instance
//       .collection('restaurantAdmins')
//       .doc(restaurantId)
//       .collection('items')
//       .get();
//     setState(() {
//       _dishes = snapshot.docs.map((doc) {
//         return {
//           'id': doc.id,
//           'name': doc.get('name'),
//           'photo': doc.get('photo'),
//         };
//       }).toList();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _loading 
//         ? const Center(child: CircularProgressIndicator())
//         : SafeArea(
//           child: Stack(
//             children: [
//               GoogleMap(
//                 initialCameraPosition: CameraPosition(
//                   target: widget.currentLocation,
//                   zoom: 12,
//                 ),
//                 markers: _markers,
//                 polylines: {
//                   Polyline(
//                     polylineId: const PolylineId('route'),
//                     points: _routePoints,
//                     color: Colors.deepOrange,
//                     width: 5,
//                   )
//                 },
//                 onMapCreated: (controller) {
//                   _controller.complete(controller);
//                 },
//               ),
//               Positioned(
//                 bottom: 20,
//                 left: 20,
//                 right: 20,
//                 child: Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.black87,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       if (_restaurantsOnRoute.isNotEmpty)
//                         DropdownButtonFormField<String>(
//                           dropdownColor: Colors.black,
//                           style: const TextStyle(color: Colors.white),
//                           decoration: InputDecoration(
//                             filled: true,
//                             fillColor: Colors.white12,
//                             hintText: 'Select Restaurant',
//                             hintStyle: const TextStyle(color: Colors.grey),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8),
//                               borderSide: BorderSide.none,
//                             )
//                           ),
//                           value: _selectedRestaurant,
//                           items: _restaurantsOnRoute.map((res) {
//                             return DropdownMenuItem<String>(
//                               value: res['id'],
//                               child: Text(res['username']),
//                             );
//                           }).toList(),
//                           onChanged: (val) async {
//                             setState(() {
//                               _selectedRestaurant = val;
//                               _selectedDish = null;
//                               _dishes.clear();
//                             });
//                             if (val != null) {
//                               await _fetchDishesForRestaurant(val);
//                             }
//                           },
//                         ),
//                       const SizedBox(height: 10),
//                       if (_dishes.isNotEmpty)
//                         DropdownButtonFormField<String>(
//                           dropdownColor: Colors.black,
//                           style: const TextStyle(color: Colors.white),
//                           decoration: InputDecoration(
//                             filled: true,
//                             fillColor: Colors.white12,
//                             hintText: 'Select Dish',
//                             hintStyle: const TextStyle(color: Colors.grey),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8),
//                               borderSide: BorderSide.none,
//                             )
//                           ),
//                           value: _selectedDish,
//                           items: _dishes.map((dish) {
//                             return DropdownMenuItem<String>(
//                               value: dish['id'],
//                               child: Text(dish['name']),
//                             );
//                           }).toList(),
//                           onChanged: (val) {
//                             setState(() {
//                               _selectedDish = val;
//                             });
//                           },
//                         ),
//                       const SizedBox(height: 10),
//                       if (_selectedDish != null && _selectedRestaurant != null)
//                         ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.deepOrange,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             )
//                           ),
//                           onPressed: () {
//                             final selectedDishData = _dishes.firstWhere((d) => d['id'] == _selectedDish);
//                             final selectedRestaurantData = _restaurantsOnRoute.firstWhere((r) => r['id'] == _selectedRestaurant);
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => DishScreen(
//                                   dishName: selectedDishData['name'],
//                                   dishPhoto: selectedDishData['photo'],
//                                   restaurantName: selectedRestaurantData['username'],
//                                 ),
//                               ),
//                             );
//                           },
//                           child: const Text('View Dish'),
//                         )
//                     ],
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//     );
//   }
// }


import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:paraiso/screens/place_order.dart';

class SelectRestaurantScreen extends StatefulWidget {
  final LatLng currentLocation;
  final LatLng destinationLatLng;
  final String destinationName;

  const SelectRestaurantScreen({
    Key? key, 
    required this.currentLocation, 
    required this.destinationLatLng,
    required this.destinationName,
  }) : super(key: key);

  @override
  State<SelectRestaurantScreen> createState() => _SelectRestaurantScreenState();
}

class _SelectRestaurantScreenState extends State<SelectRestaurantScreen> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  List<LatLng> _routePoints = [];
  
  List<Map<String, dynamic>> _restaurantsOnRoute = [];
  String? _selectedRestaurant;
  List<Map<String,dynamic>> _dishes = [];
  String? _selectedDish;
  bool _loading = true;

  // Replace with your Directions API key
  final String _directionsApiKey = "AIzaSyBdyI-UDzUS-ekazlKktQpPDLeyVQ4jJa4";

  @override
  void initState() {
    super.initState();
    _initMapStuff();
  }

  Future<void> _initMapStuff() async {
    _routePoints = await _getRoutePoints(widget.currentLocation, widget.destinationLatLng);

    List<Map<String,dynamic>> allRestaurants = await _fetchAllRestaurants();
    _restaurantsOnRoute = _filterRestaurantsOnRoute(allRestaurants, _routePoints);

    Set<Marker> markers = {
      Marker(
        markerId: const MarkerId('origin'),
        position: widget.currentLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
      Marker(
        markerId: const MarkerId('destination'),
        position: widget.destinationLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(title: widget.destinationName),
      ),
    };

    for (var r in _restaurantsOnRoute) {
      markers.add(
        Marker(
          markerId: MarkerId(r['id']),
          position: r['latLng'],
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: r['name'] ?? r['username']),
        )
      );
    }

    setState(() {
      _markers = markers;
      _loading = false;
    });
  }

  Future<List<LatLng>> _getRoutePoints(LatLng origin, LatLng destination) async {
    final directionUrl = Uri.parse(
      "https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$_directionsApiKey"
    );

    final response = await http.get(directionUrl);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK' && (data['routes'] as List).isNotEmpty) {
        final route = data['routes'][0];
        final overviewPolyline = route['overview_polyline']['points'];
        return _decodePolyline(overviewPolyline);
      }
    }

    // If for some reason the Directions API call fails, fallback to a straight line
    return [origin, destination];
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;
    
    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;
      
      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  Future<List<Map<String,dynamic>>> _fetchAllRestaurants() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('restaurantAdmins').get();

    // We'll safely check for optional fields:
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      GeoPoint gp = data['location'];
      return {
        'id': doc.id,
        'username': data['username'],
        'name': data.containsKey('name') ? data['name'] : data['username'],
        'latLng': LatLng(gp.latitude, gp.longitude),
        'logo': data.containsKey('logo') ? data['logo'] : '',
      };
    }).toList();
  }

  List<Map<String,dynamic>> _filterRestaurantsOnRoute(List<Map<String,dynamic>> all, List<LatLng> route) {
    const double radiusKm = 0.8;
    return all.where((r) {
      for (var p in route) {
        double distance = _coordinateDistance(p.latitude, p.longitude, r['latLng'].latitude, r['latLng'].longitude);
        if (distance <= radiusKm) {
          return true;
        }
      }
      return false;
    }).toList();
  }

  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    // Haversine formula
    var p = 0.017453292519943295;
    var a = 0.5 - cos((lat2 - lat1) * p)/2 + 
            cos(lat1 * p)*cos(lat2 * p)*(1 - cos((lon2 - lon1)*p))/2;
    return 12742 * asin(sqrt(a));
  }

  Future<void> _fetchDishesForRestaurant(String restaurantId) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('restaurantAdmins')
      .doc(restaurantId)
      .collection('items')
      .get();
    setState(() {
      _dishes = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'addOns': data['addOns'] ?? [],
          'availability': data['availability'] ?? true,
          'description': data['description'] ?? '',
          'discount': data['discount'] ?? '',
          'discountedPrice': data['discountedPrice'] ?? 0,
          'free': data['free'] ?? {},
          'itemId': data['itemId'] ?? '',
          'lastUpdated': data['lastUpdated'],
          'name': data['name'] ?? '',
          'photo': data['photo'] ?? '',
          'prepDelay': data['prepDelay'] ?? '',
          'prices': data['prices'] ?? {},
          'rewards': data['rewards'] ?? 0,
          'sizes': data['sizes'] ?? [],
          'type': data['type'] ?? '',
          'workingHrs': data['workingHrs'] ?? '',
        };
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading 
        ? const Center(child: CircularProgressIndicator())
        : SafeArea(
          child: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: widget.currentLocation,
                  zoom: 12,
                ),
                markers: _markers,
                polylines: {
                  Polyline(
                    polylineId: const PolylineId('route'),
                    points: _routePoints,
                    color: Colors.blue.shade900,
                    width: 5,
                  )
                },
                onMapCreated: (controller) {
                  _controller.complete(controller);
                },
              ),
              // Positioned(
              //   bottom: 20,
              //   left: 20,
              //   right: 20,
              //   child: Container(
              //     padding: const EdgeInsets.all(16),
              //     decoration: BoxDecoration(
              //       color: Colors.black54,
              //       borderRadius: BorderRadius.circular(12),
              //     ),
              //     child: Column(
              //       mainAxisSize: MainAxisSize.min,
              //       children: [
              //         if (_restaurantsOnRoute.isNotEmpty)
              //           DropdownButtonFormField<String>(
              //             dropdownColor: Colors.black,
              //             style: const TextStyle(color: Colors.white),
              //             decoration: InputDecoration(
              //               filled: true,
              //               fillColor: Colors.white12,
              //               hintText: 'Select Restaurant',
              //               hintStyle: const TextStyle(color: Colors.grey),
              //               border: OutlineInputBorder(
              //                 borderRadius: BorderRadius.circular(8),
              //                 borderSide: BorderSide.none,
              //               )
              //             ),
              //             value: _selectedRestaurant,
              //             items: _restaurantsOnRoute.map((res) {
              //               return DropdownMenuItem<String>(
              //                 value: res['id'],
              //                 child: Text(res['name'] ?? res['username']),
              //               );
              //             }).toList(),
              //             onChanged: (val) async {
              //               setState(() {
              //                 _selectedRestaurant = val;
              //                 _selectedDish = null;
              //                 _dishes.clear();
              //               });
              //               if (val != null) {
              //                 await _fetchDishesForRestaurant(val);
              //               }
              //             },
              //           ),
              //         const SizedBox(height: 10),
              //         if (_dishes.isNotEmpty)
              //           DropdownButtonFormField<String>(
              //             dropdownColor: Colors.black,
              //             style: const TextStyle(color: Colors.white),
              //             decoration: InputDecoration(
              //               filled: true,
              //               fillColor: Colors.white12,
              //               hintText: 'Select Dish',
              //               hintStyle: const TextStyle(color: Colors.grey),
              //               border: OutlineInputBorder(
              //                 borderRadius: BorderRadius.circular(8),
              //                 borderSide: BorderSide.none,
              //               )
              //             ),
              //             value: _selectedDish,
              //             items: _dishes.map((dish) {
              //               return DropdownMenuItem<String>(
              //                 value: dish['id'],
              //                 child: Text(dish['name']),
              //               );
              //             }).toList(),
              //             onChanged: (val) {
              //               setState(() {
              //                 _selectedDish = val;
              //               });
              //             },
              //           ),
              //         const SizedBox(height: 10),
              //         if (_selectedDish != null && _selectedRestaurant != null)
              //           ElevatedButton(
              //             style: ElevatedButton.styleFrom(
              //               backgroundColor: Colors.deepOrange,
              //               shape: RoundedRectangleBorder(
              //                 borderRadius: BorderRadius.circular(8),
              //               )
              //             ),
              //             onPressed: () {
              //               final selectedDishData = _dishes.firstWhere((d) => d['id'] == _selectedDish);
              //               final selectedRestaurantData = _restaurantsOnRoute.firstWhere((r) => r['id'] == _selectedRestaurant);

              //               // Prepare data for PlaceOrder
              //               final restaurantId = selectedRestaurantData['id'];
              //               final restaurantName = selectedRestaurantData['name'] ?? selectedRestaurantData['username'];
              //               final foodItem = selectedDishData; 
              //               final restaurantImage = selectedRestaurantData['logo'];
              //               final addOns = selectedDishData['addOns'] ?? [];

              //               Navigator.push(
              //                 context,
              //                 MaterialPageRoute(
              //                   builder: (context) => PlaceOrder(
              //                     restaurantId: restaurantId,
              //                     restaurantName: restaurantName,
              //                     foodItem: foodItem,
              //                     restaurantImage: restaurantImage,
              //                     addOns: addOns,
              //                   ),
              //                 ),
              //               );
              //             },
              //             child: const Text('Place Order'),
              //           )
              //       ],
              //     ),
              //   ),
              // )
              Positioned(
  bottom: 20,
  left: 20,
  right: 20,
  child: Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.grey[900],
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black54,
          blurRadius: 8,
          offset: Offset(0, 4),
        )
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start, 
      children: [
        Text(
          'Select Your Restaurant & Dish',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        if (_restaurantsOnRoute.isNotEmpty)
          DropdownButtonFormField<String>(
            dropdownColor: Colors.grey[850],
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[800],
              hintText: 'Select Restaurant',
              hintStyle: const TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
            value: _selectedRestaurant,
            items: _restaurantsOnRoute.map((res) {
              return DropdownMenuItem<String>(
                value: res['id'],
                child: Text(res['name'] ?? res['username']),
              );
            }).toList(),
            onChanged: (val) async {
              setState(() {
                _selectedRestaurant = val;
                _selectedDish = null;
                _dishes.clear();
              });
              if (val != null) {
                await _fetchDishesForRestaurant(val);
              }
            },
          ),
        if (_restaurantsOnRoute.isNotEmpty) const SizedBox(height: 10),
        if (_dishes.isNotEmpty)
          DropdownButtonFormField<String>(
            dropdownColor: Colors.grey[850],
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[800],
              hintText: 'Select Dish',
              hintStyle: const TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
            value: _selectedDish,
            items: _dishes.map((dish) {
              return DropdownMenuItem<String>(
                value: dish['id'],
                child: Text(dish['name']),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                _selectedDish = val;
              });
            },
          ),
        if (_dishes.isNotEmpty) const SizedBox(height: 10),
        if (_selectedDish != null && _selectedRestaurant != null)
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade800,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                )
              ),
              onPressed: () {
                final selectedDishData = _dishes.firstWhere((d) => d['id'] == _selectedDish);
                final selectedRestaurantData = _restaurantsOnRoute.firstWhere((r) => r['id'] == _selectedRestaurant);

                // Prepare data for PlaceOrder
                final restaurantId = selectedRestaurantData['id'];
                final restaurantName = selectedRestaurantData['name'] ?? selectedRestaurantData['username'];
                final foodItem = selectedDishData; 
                final restaurantImage = selectedRestaurantData['logo'];
                final addOns = selectedDishData['addOns'] ?? [];

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlaceOrder(
                      restaurantId: restaurantId,
                      restaurantName: restaurantName,
                      foodItem: foodItem,
                      restaurantImage: restaurantImage,
                      addOns: addOns,
                    ),
                  ),
                );
              },
              child: const Text('Place Order',style: TextStyle(color: Colors.white),),
            ),
          )
      ],
    ),
  ),
)

            ],
          ),
        ),
    );
  }
}
