import 'package:get/get.dart';

class ProfileController extends GetxController {
  final RxString _name = 'loading...'.obs;
  final RxString _email = ''.obs;
  final RxString _password = ''.obs;
  final RxString _confirmPassword = ''.obs;
  final RxString _phone = ''.obs;
  final RxString _schoolName = 'loading...'.obs;

  // GETTERS
  String get name => _name.value;

  String get email => _email.value;

  String get password => _password.value;

  String get confirmPassword => _confirmPassword.value;

  String get phone => _phone.value;

  String get schoolName => _schoolName.value;

  // SETTERS
  set name(String value) => _name.value = value;

  set email(String value) => _email.value = value;

  set password(String value) => _password.value = value;

  set confirmPassword(String value) => _confirmPassword.value = value;

  set phone(String value) => _phone.value = value;

  set schoolName(String value) => _schoolName.value = value;
}
