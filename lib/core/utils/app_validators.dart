class AppValidators {
  AppValidators._();

  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// Returns `true` when [email] has a valid basic email format.
  static bool isValidEmail(String email) {
    return _emailRegex.hasMatch(email.trim());
  }

  /// Returns `true` when [password] is at least 8 characters and includes both letters and digits.
  static bool isStrongPassword(String password) {
    return password.length >= 8 &&
        RegExp(r'[A-Za-z]').hasMatch(password) &&
        RegExp(r'\d').hasMatch(password);
  }
}

