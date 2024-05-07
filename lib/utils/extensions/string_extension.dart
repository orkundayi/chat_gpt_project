extension ValidationExtensions on String {
  bool get isValidEmail => RegExp(r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*(\.[a-zA-Z]{2,})$').hasMatch(this);
  bool get isPhoneNumber => RegExp(r'^[0-9]+$').hasMatch(this);
}
