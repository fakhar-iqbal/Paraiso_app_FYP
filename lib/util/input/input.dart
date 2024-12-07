
class InputControlState {
  setValue(value) {}
  resetValue() {}
}

class Input {
  static Map<String, dynamic> values = {};
  static Map<String, InputControlState> inputController = {};

  static set(key, value) {
    values[key] = value;
  }

  static get(key) {
    return values[key];
  }

  static clear(key) {
    values.remove(key);
  }

  static resetValues() {
    inputController.forEach((key, value) {
      value.resetValue();
    });
  }
}

//how will I use this?
// how to instantiate?
// myInput = Input();
// Input.set('email', 'email');
// Input.set('password', 'password');
// Input.set('confirmPassword', 'confirmPassword');
// Input.set('firstName', 'firstName');
// Input.set('lastName', 'lastName');
// now I can use Input.get('email') to get the value of the email
// Input.get('email') will return 'email'
// clear
// Input.clear('email');
// reset
// Input.resetValues();
