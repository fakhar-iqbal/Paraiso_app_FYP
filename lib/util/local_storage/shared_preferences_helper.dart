import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  SharedPreferencesHelper._();

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Save user location to SharedPreferences
  static Future<void> saveUserLocation(
      double latitude, double longitude) async {
    await _prefs?.setDouble('user_location_latitude', latitude);
    await _prefs?.setDouble('user_location_longitude', longitude);
  }

  // Retrieve user location from SharedPreferences
  static Future<Map<String, double>?> getUserLocation() async {
    final double? latitude = _prefs?.getDouble('user_location_latitude');
    final double? longitude = _prefs?.getDouble('user_location_longitude');
    if (latitude != null && longitude != null) {
      return {'latitude': latitude, 'longitude': longitude};
    }
    return null;
  }

  // Update user location in SharedPreferences
  static Future<void> updateUserLocation(
      double latitude, double longitude) async {
    await _prefs?.setDouble('user_location_latitude', latitude);
    await _prefs?.setDouble('user_location_longitude', longitude);
  }

  static Future<void> saveCurrentUser(String user) async {
    await _prefs?.setString("user", user);
  }

  static String? getCurrentUser() {
    final String? user = _prefs?.getString("user");
    return user;
  }

  static double? getCurrentLat() {
    final double? latitude = _prefs?.getDouble("user_location_latitude");
    return latitude;
  }

  static double? getCurrentLng() {
    final double? longitude = _prefs?.getDouble("user_location_longitude");
    return longitude;
  }

  static Future<void> deleteCurrentUser() async {
    await _prefs?.remove("user");
  }

  static Future<void> saveResEmail(String email) async {
    await _prefs?.setString("res_email", email);
  }

  static String? getResEmail() {
    final String? email = _prefs?.getString("res_email");
    return email;
  }

  static Future<void> deleteResEmail() async {
    await _prefs?.remove("res_email");
  }

  static Future<void> saveUserSignupChoice(String choice) async {
    await _prefs?.setString("signup_choice", choice);
  }

  static String? getUserSignupChoice() {
    final String? choice = _prefs?.getString("signup_choice");
    return choice;
  }

  static Future<void> deleteUserSignupChoice() async {
    await _prefs?.remove("signup_choice");
  }

  static Future<void> saveCustomerEmail(String email) async {
    await _prefs?.setString("user_email", email);
  }

  static Future<void> saveCustomerType(String type) async {
    await _prefs?.setString("user_type", type);
  }

  static String? getCustomerEmail() {
    final String? email = _prefs?.getString("user_email");
    return email;
  }

  static String? getCustomerType() {
    final String? type = _prefs?.getString("user_type");
    return type;
  }

  static Future<void> deleteCustomerEmail() async {
    await _prefs?.remove("user_email");
  }
}
