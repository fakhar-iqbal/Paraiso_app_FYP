import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:paraiso/screens/restaurant_model.dart';

class RouteOrderingScreen extends StatefulWidget {
  @override
  _RouteOrderingScreenState createState() => _RouteOrderingScreenState();
}

class _RouteOrderingScreenState extends State<RouteOrderingScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Position? _destinationPosition;
  List<Restaurant> _nearbyRestaurants = [];
  Restaurant? _selectedRestaurant;
  MenuItem? _selectedMenuItem;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    _currentPosition = await Geolocator.getCurrentPosition();
    setState(() {});
  }

  void _searchRestaurants() async {
    if (_currentPosition == null || _destinationPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select current and destination locations')),
      );
      return;
    }

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('restaurantAdmins')
        .get();

    setState(() {
      _nearbyRestaurants = querySnapshot.docs
          .map((doc) => Restaurant.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Route-Based Ordering'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: _currentPosition == null
                ? Center(child: CircularProgressIndicator())
                : GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      ),
                      zoom: 14,
                    ),
                    markers: {
                      if (_currentPosition != null)
                        Marker(
                          markerId: MarkerId('currentLocation'),
                          position: LatLng(
                            _currentPosition!.latitude,
                            _currentPosition!.longitude,
                          ),
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueGreen),
                        ),
                      if (_destinationPosition != null)
                        Marker(
                          markerId: MarkerId('destination'),
                          position: LatLng(
                            _destinationPosition!.latitude,
                            _destinationPosition!.longitude,
                          ),
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueRed),
                        ),
                      ..._nearbyRestaurants.map(
                        (restaurant) => Marker(
                          markerId: MarkerId(restaurant.id),
                          position: LatLng(
                            restaurant.latitude,
                            restaurant.longitude,
                          ),
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueOrange),
                        ),
                      ),
                    },
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    Position? destination = await _showDestinationPicker();
                    setState(() {
                      _destinationPosition = destination;
                    });
                  },
                  child: Text('Select Destination'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _searchRestaurants,
                  child: Text('Search Restaurants'),
                ),
                if (_nearbyRestaurants.isNotEmpty) ...[
                  SizedBox(height: 16),
                  DropdownButtonFormField<Restaurant>(
                    decoration: InputDecoration(
                      labelText: 'Select Restaurant',
                      border: OutlineInputBorder(),
                    ),
                    items: _nearbyRestaurants
                        .map((restaurant) => DropdownMenuItem(
                              value: restaurant,
                              child: Text(restaurant.name),
                            ))
                        .toList(),
                    onChanged: (restaurant) {
                      setState(() {
                        _selectedRestaurant = restaurant;
                        _selectedMenuItem = null;
                      });
                    },
                  ),
                  if (_selectedRestaurant != null) ...[
                    SizedBox(height: 16),
                    DropdownButtonFormField<MenuItem>(
                      decoration: InputDecoration(
                        labelText: 'Select Menu Item',
                        border: OutlineInputBorder(),
                      ),
                      items: _selectedRestaurant!.items
                          .map((item) => DropdownMenuItem(
                                value: item,
                                child: Text(
                                  '${item.name} - \$${item.price.toStringAsFixed(2)}',
                                ),
                              ))
                          .toList(),
                      onChanged: (item) {
                        setState(() {
                          _selectedMenuItem = item;
                        });
                      },
                    ),
                    if (_selectedMenuItem != null) ...[
                      SizedBox(height: 16),
                      Text(
                        'Preparation Time: ${_selectedRestaurant!.prepDelay} minutes',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.deepOrangeAccent,
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _proceedToOrder,
                        child: Text('Order Now'),
                      ),
                    ],
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<Position?> _showDestinationPicker() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      return position;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get location')),
      );
      return null;
    }
  }

  void _proceedToOrder() {
    if (_selectedRestaurant != null && _selectedMenuItem != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ordering ${_selectedMenuItem!.name} from ${_selectedRestaurant!.name}',
          ),
        ),
      );
      // Add your order processing logic here
    }
  }
}