class Validators {
  Validators._();

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? email(String? value) {
    final String text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Please enter your email';
    }
    if (!_emailPattern.hasMatch(text)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().length < 2) {
      return 'Please enter your name';
    }
    return null;
  }

  static String? requiredPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    return null;
  }

  static String? newPassword(String? value) {
    if (value == null || value.length < 8) {
      return 'Use at least 8 characters';
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(value) ||
        !RegExp(r'[0-9]').hasMatch(value)) {
      return 'Use both letters and numbers';
    }
    return null;
  }
}
